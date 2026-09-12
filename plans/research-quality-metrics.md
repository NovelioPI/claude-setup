# Code Quality Metrics, Ranked by Fit to Cognitive Debt

| Metric | Measures | Fits cognitive debt | Threshold | Tool | Source |
|---|---|---|---|---|---|
| Cognitive Complexity | Breaks in linear reading flow, with an extra charge per nesting level | strong | 15 | `complexipy` | [white paper](https://www.sonarsource.com/docs/CognitiveComplexity.pdf) |
| Max nesting depth | The deepest stack of nested blocks in a function | strong | 5 | `ruff` PLR1702 | [ruff settings](https://docs.astral.sh/ruff/settings/#lint_pylint_max-nested-blocks) |
| Cyclomatic Complexity | Decision points plus one | weak | 10 | `ruff` C901, `radon cc`, `mccabe`, `xenon` | [McCabe 1976](https://doi.org/10.1109/TSE.1976.233837) |
| Branch count | Branches in one function | weak | 12 | `ruff` PLR0912 | [ruff settings](https://docs.astral.sh/ruff/settings/#lint_pylint_max-branches) |
| Statement count | Statements in one function | weak | 50 | `ruff` PLR0915 | [ruff settings](https://docs.astral.sh/ruff/settings/#lint_pylint_max-statements) |
| Parameter count | Parameters in one function signature | weak | 5 | `ruff` PLR0913 | [ruff settings](https://docs.astral.sh/ruff/settings/#lint_pylint_max-args) |
| NPath | Acyclic execution paths, multiplied across blocks | weak | 200 | none for Python | [Nejmeh 1988](https://doi.org/10.1145/42372.42379) |
| SLOC | Source lines of code | weak | none stated | `radon raw` | [radon](https://radon.readthedocs.io/en/latest/intro.html) |
| Halstead Volume | Distinct and total operators and operands | no | none stated | `radon hal`, `wily` | [radon](https://radon.readthedocs.io/en/latest/intro.html) |
| Halstead Difficulty, Effort, Time, Bugs | Formulas derived from the Volume counts | no | none stated | `radon hal` | [radon](https://radon.readthedocs.io/en/latest/intro.html) |
| Maintainability Index | One formula over Halstead Volume, cyclomatic complexity, LOC, comments | no | 85 and 65 (original scale); 20 and 10 (radon scale) | `radon mi`, `wily`, `xenon` | [SEI CMU/SEI-97-HB-001, p. 231](https://resources.sei.cmu.edu/asset_files/Handbook/1997_002_001_16523.pdf) |

Threshold notes, each checked against the owner:

- The Cognitive Complexity white paper states no threshold. The 15 comes from
  SonarSource's own rule S3776, where
  [`DEFAULT_THRESHOLD = 15`](https://github.com/SonarSource/sonar-python/blob/master/python-checks/src/main/java/org/sonar/python/checks/CognitiveComplexityFunctionCheck.java).
  `complexipy` uses 15 as its default too. I verified this: a function scoring
  15 passes, and one scoring 16 exits non-zero.
- McCabe wrote that 10 "seems like a reasonable, but not magical, upper limit".
  He also allowed an exception for a large case statement.
  [NIST SP 500-235, section 2.5](https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication500-235.pdf)
  repeats the limit of 10 and permits 15 for experienced teams.
- The NPath limit of 200 is the default in
  [PMD's NPathComplexity rule](https://docs.pmd-code.org/latest/pmd_rules_java_design.html#npathcomplexity).
  I could not open Nejmeh's paper to confirm he named that number.
- The SEI guide gives the Maintainability Index formula but states no threshold.
  The 85 and 65 bands come from the Coleman and Oman line of work.
  [radon](https://radon.readthedocs.io/en/latest/commandline.html) rescales the
  value to 0-100 and then ranks A at 100-20, B at 19-10, C at 9-0.
- The SEI formula subtracts the comment term. radon adds it. The variants are
  not interchangeable.

## 1. Evidence

**Cognitive Complexity: mixed, and the best evidence of any metric here.**
Muñoz Barón, Wyrich and Wagner ran a meta-analysis over 10 studies, 427 code
snippets and about 24,000 understandability ratings. Cognitive Complexity
correlated with comprehension time at r = 0.54, 95% CI [0.24, 0.75]. It
correlated with subjective understandability ratings at r = -0.29, CI [-0.49,
-0.06]. It showed no correlation with task correctness, r = -0.13, CI [-0.45,
0.21], nor with physiological measures, r = 0.00. Source:
[An Empirical Validation of Cognitive Complexity](https://arxiv.org/abs/2007.12520),
ESEM 2020.
Lavazza, Abualkishik, Liu and Morasca disagree on the size of the gain. They
conclude the measure "does not appear to fulfill the promise of being a
significant improvement over previously proposed" measures. Source:
[JSS 197, 2023](https://doi.org/10.1016/j.jss.2022.111561). I could reach only
the indexed abstract, not the full text.
Plain statement: the metric predicts reading time, not reading accuracy.

**Cyclomatic Complexity: no independent support.** Jay, Hale, Smith, Hale, Kraft
and Ward analysed over 1.2 million source files from SourceForge in C, C++ and
Java. Lines of code alone predict roughly 90% of the variance in cyclomatic
complexity. They conclude that cyclomatic complexity "can be said to have
absolutely no explanatory power of its own". Source:
[JSEA 2, 2009, 137-143](https://www.scirp.org/journal/paperinformation?paperid=779).
McCabe's own claim was about test effort, not about reading effort. The paper
counts minimum test cases for branch coverage. That claim still holds.

**NPath: no evidence found.** I found no replication of Nejmeh's AT&T data and
no later study linking NPath to maintenance cost.

**Halstead metrics: no support for the derived formulas.** The raw counts of
operators and operands are well defined. The Effort, Time and Bugs formulas rest
on a psychological theory that failed review. The canonical critique is Shen,
Conte and Dunsmore, "Software Science Revisited: A Critical Analysis of the
Theory and Its Empirical Support", IEEE TSE 9(2), 1983, 155-165,
[DOI](https://doi.org/10.1109/TSE.1983.236730). I could not open the full text;
every copy I tried returned 403. Treat `bugs = V/3000` as an unvalidated
estimate.

**Maintainability Index: no support for the calibration.** The SEI guide says the
coefficients came from Hewlett-Packard systems and adds: "It is advisable to test
the coefficients for proper fit with each major system to which the MI is
applied." No tool that ships the formula does that. Arie van Deursen sets out the
specific problems: the derivation was never published, the calibration used small
C and Pascal programs, no significance testing was reported, and all three inputs
already track size. Source:
[Think Twice Before Using the Maintainability Index](https://avandeursen.com/2014/08/29/think-twice-before-using-the-maintainability-index/).

**Nesting depth, branch count, statement count, parameter count: no evidence
found.** These are conventions from linter defaults, not study results. Nesting
depth earns a `strong` rating only because Cognitive Complexity charges nesting
directly, and Cognitive Complexity has the evidence above.

**SLOC: weak but honest.** Size predicts defect count in many studies. Size does
not tell you whether a reader can hold the code in mind.

## 2. Gaming risk

| Metric | How a writer satisfies the number and raises cognitive debt |
|---|---|
| Maintainability Index | Add comment lines. The comment term raises the score with no change to the code. |
| Halstead Volume | Reuse one variable for two jobs. Fewer distinct operands lowers Volume and hides intent. |
| Halstead Bugs, Effort | Same as Volume. These are pure functions of the operand and operator counts. |
| Cyclomatic Complexity | Push branches into a helper, or replace a flat chain with nested conditions. |
| NPath | Split one function into two. The product collapses while the reader still crosses both. |
| Branch count | Replace branches with a dictionary lookup whose values hide the same logic. |
| Statement count | Merge statements onto one line, or chain calls to reach a value. |
| SLOC | Delete blank lines and comments, or write long expressions. |
| Nesting depth | Extract the inner block into a one-use helper with no name that explains it. |
| Cognitive Complexity | Extract a single-use helper. The metric ignores the method structure by design. |

**Worst three: the Maintainability Index, Halstead Volume, and Cyclomatic
Complexity.** The first two move on comment count and on name reuse, which are
not reading cost. The third is the most dangerous of the three, because it points
the writer the wrong way.

I measured this on two files. `deep.py` nests five `if` statements. `flat.py`
holds six sibling `if` statements. Cyclomatic complexity scores the flat file
worse, 7 against 6. Cognitive Complexity scores the nested file worse, 15 against
6. The house rule "Return early with a guard clause instead of nesting
conditions" agrees with Cognitive Complexity and contradicts cyclomatic
complexity. Nesting increments are triangular: 1, 3, 6, 10, 15, 21 for depths one
through six.

Note also that `ruff` and `radon` disagree on cyclomatic values for the same
function. On my sample `ruff` reported 4 and `radon` reported 5. Do not compare
numbers across tools.

## 3. Checkable in a hook

No metric tool is installed on this machine. `uv` and `uvx` are present, so every
command below runs from the `uvx` cache. Warm runs on one file took 0.13 s for
`complexipy`, 0.12 s for `ruff`, and 0.17 s for `radon`. All are fast enough for
a PostToolUse hook on a single changed file.

Assume `$FILE` holds the changed path, taken from the hook's JSON on standard
input.

**Cognitive Complexity, default 15, exits 1 when over:**

```bash
uvx complexipy --plain --failed --max-complexity-allowed 15 "$FILE"
```

**Cyclomatic Complexity, exits 1 when over:**

```bash
uvx ruff check --isolated --select C901 \
  --config "lint.mccabe.max-complexity = 10" "$FILE"
```

**Nesting depth, branches, statements, parameters, returns; exits 1 when over:**

```bash
uvx ruff check --isolated --preview \
  --select PLR1702,PLR0912,PLR0915,PLR0913,PLR0911 "$FILE"
```

PLR1702 needs `--preview`. Without it `ruff` prints a warning and skips the rule.

**Cyclomatic Complexity by rank, exits 1 when over:**

```bash
uvx xenon --max-absolute B --max-modules A --max-average A "$FILE"
```

**Maintainability Index and Halstead, report only:**

```bash
uvx radon mi -s "$FILE"
uvx radon hal -f "$FILE"
```

Risk: `radon` exits 0 even when it reports a violation. To gate on `radon`, test
whether the filtered output is empty:

```bash
out=$(uvx radon cc -s -n C "$FILE"); [ -n "$out" ] && exit 2
```

**Not checkable in a per-file hook:**

- NPath. No maintained Python tool computes it. I checked `radon`, `ruff`,
  `mccabe`, `xenon`, `wily` and `lizard`. `lizard` reports only NLOC, CCN, token
  count and parameter count.
- `wily`. It indexes a git history, so it needs a built cache and a repository.
  Its own `wily diff` is documented as a pre-commit hook, not a per-edit hook.
  Note that the wily documentation claims a cognitive complexity operator. The
  released package, version 1.25.0, does not have one. Its operators are
  `cyclomatic`, `maintainability`, `raw` and `halstead`. I confirmed this by
  grepping the installed package.

## 4. Recommendation

Add exactly two numbers to `rules/code-quality.md`: Cognitive Complexity at 15
per function, and maximum nesting depth at 5, because both charge the reader for
nesting and both match the guard-clause rule already in the file. Leave out the
Maintainability Index and every Halstead metric, because their calibration was
never published and a writer raises the score by adding comments. Leave
cyclomatic complexity out as a rule, since lines of code explain about 90% of it,
and keep `ruff` C901 at its default 10 only as a cheap secondary alarm.
