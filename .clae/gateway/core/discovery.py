from __future__ import annotations

import ast
import hashlib
import re
from collections.abc import Iterable
from pathlib import Path

EXCLUDED_DIRS = {
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    ".venv",
    "venv",
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    "dist",
    "build",
    "coverage",
    ".tox",
    "target",
    "vendor",
}
CODE_EXTS = {
    ".py",
    ".pyi",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".go",
    ".rs",
    ".java",
    ".kt",
    ".swift",
    ".sql",
}
TEST_HINTS = ("test", "tests", "spec", "__tests__")
DOC_SUFFIXES = {".md", ".mdx", ".rst", ".adoc"}


def iter_files(root: Path) -> Iterable[Path]:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in EXCLUDED_DIRS for part in path.parts):
            continue
        try:
            path.relative_to(root / ".clae" / "runtime")
            continue
        except ValueError:
            pass
        yield path


def keywords(text: str) -> set[str]:
    return {x.lower() for x in re.findall(r"[A-Za-z_][A-Za-z0-9_]{2,}", text)}


def python_symbols(path: Path, text: str) -> list[tuple[str, int, int]]:
    try:
        tree = ast.parse(text)
    except SyntaxError:
        return []
    result: list[tuple[str, int, int]] = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            start = getattr(node, "lineno", 1)
            end = getattr(node, "end_lineno", start)
            result.append((node.name, start, end))
    return result


def generic_symbols(text: str) -> list[tuple[str, int, int]]:
    patterns = [
        r"\b(?:function|class|interface|type|func|struct)\s+([A-Za-z_][A-Za-z0-9_]*)",
        r"\b(?:def)\s+([A-Za-z_][A-Za-z0-9_]*)",
    ]
    out = []
    lines = text.splitlines()
    for i, line in enumerate(lines, 1):
        for pattern in patterns:
            m = re.search(pattern, line)
            if m:
                out.append((m.group(1), i, min(i + 60, len(lines))))
    return out


def stable_id(kind: str, path: str, suffix: str = "") -> str:
    raw = f"{kind}:{path}:{suffix}".encode()
    return hashlib.sha1(raw).hexdigest()[:12]


def build_index(root: Path) -> dict:
    files = []
    symbols = []
    for path in iter_files(root):
        rel = str(path.relative_to(root)).replace("\\", "/")
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        stat = path.stat()
        files.append(
            {
                "path": rel,
                "suffix": path.suffix,
                "size": stat.st_size,
                "mtime": stat.st_mtime,
                "tokens": max(1, len(text) // 4),
                "keywords": sorted(keywords(rel + " " + text))[:500],
            }
        )
        syms = (
            python_symbols(path, text)
            if path.suffix == ".py"
            else generic_symbols(text)
            if path.suffix in CODE_EXTS
            else []
        )
        for name, start, end in syms:
            symbols.append(
                {
                    "id": stable_id("symbol", rel, name),
                    "path": rel,
                    "symbol": name,
                    "start": start,
                    "end": end,
                }
            )
    return {"version": 1, "files": files, "symbols": symbols}


def discover_candidates(root: Path, demand, task_artifacts: list[Path]) -> list:
    import time

    from .models import ContextCandidate

    now = time.time()
    terms = set(demand.required_terms)
    candidates = []
    seen = set()

    def add(candidate):
        if candidate.source in seen and candidate.kind not in {"code", "test"}:
            return
        candidates.append(candidate)
        seen.add(candidate.source)

    # Explicit task artifacts are hard context.
    for artifact in task_artifacts:
        if not artifact.exists():
            continue
        rel = (
            str(artifact.relative_to(root)).replace("\\", "/")
            if artifact.is_relative_to(root)
            else str(artifact)
        )
        kind = "task"
        if artifact.name == "facts.md":
            kind = "doc"
        if artifact.name == "plan.md":
            kind = "doc"
        text = artifact.read_text(encoding="utf-8", errors="ignore")
        add(
            ContextCandidate(
                id=stable_id("artifact", rel),
                kind=kind,
                source=rel,
                title=artifact.name,
                estimated_tokens=max(80, min(1200, len(text) // 4)),
                authority=1.0,
                freshness=1.0,
                relevance=1.0,
                dependency=1.0,
                confidence=1.0,
                hard=True,
            )
        )

    for path in iter_files(root):
        rel = str(path.relative_to(root)).replace("\\", "/")
        if rel.startswith(".clae/runtime/"):
            continue
        if ".claude/work/" in rel:
            continue
        if rel.startswith(".claude/rules/"):
            continue
        if rel == ".claude/CLAUDE.md":
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        words = keywords(rel + " " + text[:16000])
        overlap_count = len(terms & words)
        relevance = min(1.0, 0.08 + 0.11 * overlap_count)
        if rel.endswith("CLAUDE.md") or rel.startswith(".claude/rules/"):
            relevance = max(relevance, 0.85)
        is_test = any(part.lower() in TEST_HINTS for part in path.parts) or any(
            x in path.name.lower() for x in TEST_HINTS
        )
        is_doc = path.suffix in DOC_SUFFIXES
        is_code = path.suffix in CODE_EXTS
        if not (is_code or is_doc):
            continue
        kind = "test" if is_test else "doc" if is_doc else "code"
        if kind == "code" and not demand.task_type in {
            "code",
            "bug_fix",
            "test",
            "design",
        }:
            relevance *= 0.6
        if kind == "test" and demand.needs_tests:
            relevance = max(relevance, 0.65 if overlap_count else 0.16)
        if kind == "doc" and demand.needs_docs:
            relevance = max(relevance, 0.7 if overlap_count else 0.18)
        if relevance < 0.12:
            continue
        stat = path.stat()
        freshness = 1.0 / (1.0 + max(0.0, (now - stat.st_mtime) / 86400 / 90))
        authority = 0.95 if is_code else 0.85 if kind == "test" else 0.7
        if rel.startswith(".claude/rules/"):
            authority = 0.9
        estimated_tokens = max(120, min(2600, len(text) // 4))
        add(
            ContextCandidate(
                id=stable_id(kind, rel),
                kind=kind,
                source=rel,
                title=path.name,
                estimated_tokens=estimated_tokens,
                authority=authority,
                freshness=freshness,
                relevance=relevance,
                dependency=0.9 if is_test else 0.55,
                confidence=0.85,
                hard=False,
                metadata={"level": "L2"},
            )
        )

        # Prefer L1 symbol candidates for code. They are cheaper than whole-file candidates
        # and give the materializer a bounded line window.
        if kind == "code":
            symbols = (
                python_symbols(path, text)
                if path.suffix == ".py"
                else generic_symbols(text)
                if path.suffix in CODE_EXTS
                else []
            )
            for name, start, end in symbols:
                name_terms = keywords(name)
                symbol_overlap = len(terms & name_terms)
                if symbol_overlap == 0 and overlap_count == 0:
                    continue
                span_lines = max(1, end - start + 1)
                symbol_tokens = max(80, min(900, span_lines * 12))
                symbol_rel = min(1.0, relevance + 0.15 * symbol_overlap)
                candidates.append(
                    ContextCandidate(
                        id=stable_id("symbol", rel, name),
                        kind="code",
                        source=rel,
                        title=f"{path.name}:{name}",
                        estimated_tokens=symbol_tokens,
                        authority=authority,
                        freshness=freshness,
                        relevance=symbol_rel,
                        dependency=0.8,
                        confidence=0.9,
                        hard=False,
                        line_start=start,
                        line_end=end,
                        symbol=name,
                        metadata={"level": "L1", "parent": stable_id(kind, rel)},
                    )
                )

    # Language rules become hard only when there is matching code in the candidate pool.
    suffixes = {Path(c.source).suffix for c in candidates if c.kind in {"code", "test"}}
    lang_map = {
        ".py": "python",
        ".ts": "typescript",
        ".tsx": "typescript",
        ".js": "typescript",
        ".jsx": "typescript",
        ".go": "go",
        ".sql": "sql",
    }
    for suffix in suffixes:
        name = lang_map.get(suffix)
        if not name:
            continue
        rule = root / ".claude" / "rules" / "languages" / f"{name}.md"
        if rule.exists():
            rel = str(rule.relative_to(root)).replace("\\", "/")
            text = rule.read_text(encoding="utf-8", errors="ignore")
            candidates.append(
                ContextCandidate(
                    id=stable_id("rule", rel),
                    kind="rule",
                    source=rel,
                    title=rule.name,
                    estimated_tokens=max(120, len(text) // 4),
                    authority=0.95,
                    freshness=1.0,
                    relevance=0.95,
                    dependency=0.95,
                    confidence=1.0,
                    hard=True,
                )
            )

    clean = root / ".claude" / "rules" / "clean-code.md"
    if clean.exists() and any(c.kind == "code" for c in candidates):
        rel = str(clean.relative_to(root)).replace("\\", "/")
        text = clean.read_text(encoding="utf-8", errors="ignore")
        candidates.append(
            ContextCandidate(
                id=stable_id("rule", rel),
                kind="rule",
                source=rel,
                title=clean.name,
                estimated_tokens=max(120, len(text) // 4),
                authority=0.95,
                freshness=1.0,
                relevance=0.9,
                dependency=0.9,
                confidence=1.0,
                hard=True,
            )
        )

    return candidates
