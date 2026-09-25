import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.demand import infer_demand


def test_bug_task_becomes_bug_fix():
    d = infer_demand("Fix the authentication bug", "T-1")
    assert d.task_type == "bug_fix"
    assert d.risk == "high"
    assert d.needs_tests


def test_keywords_match_whole_words_only():
    assert infer_demand("Fix the build step", "T-1").task_type == "bug_fix"
    assert infer_demand("Update linux install guide", "T-1").task_type == "code"
    assert infer_demand("Fix author name", "T-1").risk == "medium"


def test_stopwords_are_not_relevance_terms():
    d = infer_demand("Fix the parser and the lexer", "T-1")
    assert "the" not in d.required_terms
    assert "and" not in d.required_terms
    assert "parser" in d.required_terms
