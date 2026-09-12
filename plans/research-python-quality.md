# Python Code Quality Research

| Rule | Base rule | Status | Source |
|---|---|---|---|
| Use a comprehension only to build a collection. | Functions | gap | https://peps.python.org/pep-0202/ |
| Do not run a side effect inside a comprehension. | Functions | gap | https://docs.python.org/3/glossary.html#term-list-comprehension |
| Write a `for` loop when a comprehension needs two or more `for` clauses. | Functions | gap | https://docs.python.org/3/tutorial/datastructures.html#nested-list-comprehensions |
| Prefer a builtin such as `zip(*matrix)` to a nested comprehension. | Functions | gap | https://docs.python.org/3/tutorial/datastructures.html#nested-list-comprehensions |
| Do not use a list, dict, or set as a default argument value. | State | gap | https://docs.python.org/3/faq/programming.html#why-are-default-values-shared-between-objects |
| Default to `None`, then build the container inside the function. | State | gap | https://docs.python.org/3/faq/programming.html#why-are-default-values-shared-between-objects |
| Use `field(default_factory=list)` for a dataclass field with a mutable default. | Data objects | gap | https://docs.python.org/3/library/dataclasses.html#mutable-default-values |
| Use a frozen dataclass for a value object with named fields. | Data objects | covered | https://docs.python.org/3/library/dataclasses.html#dataclasses.dataclass |
| Use `NamedTuple` only when a caller indexes or unpacks the value. | Data objects | gap | https://docs.python.org/3/library/collections.html#collections.namedtuple |
| Do not use `NamedTuple` when a plain tuple must not compare equal. | Data objects | gap | https://docs.python.org/3/library/collections.html#collections.namedtuple |
| Use a dataclass, not a `NamedTuple`, when a subclass adds fields. | standalone | gap | https://peps.python.org/pep-0557/ |
| Use `TypedDict` only for a dict that crosses an external boundary. | Types | gap | https://docs.python.org/3/library/typing.html#typing.TypedDict |
| Do not expect `TypedDict` to check anything at run time. | Types | gap | https://docs.python.org/3/library/typing.html#typing.TypedDict |
| Open a file, a lock, or a connection with `with`. | Resources | covered | https://docs.python.org/3/library/contextlib.html |
| Write a setup and teardown pair with `@contextmanager`, not a class. | Resources | gap | https://docs.python.org/3/library/contextlib.html#contextlib.contextmanager |
| Use `ExitStack` when the input decides how many resources open. | Resources | gap | https://docs.python.org/3/library/contextlib.html#contextlib.ExitStack |
| Use `closing()` for a third-party object that only offers `close()`. | Resources | gap | https://docs.python.org/3/library/contextlib.html#contextlib.closing |
| Use `suppress()` only for one named error you can ignore safely. | Errors | gap | https://docs.python.org/3/library/contextlib.html#contextlib.suppress |
| Return a generator when the data is large or unbounded. | standalone | gap | https://docs.python.org/3/howto/functional.html#generator-expressions-and-list-comprehensions |
| Do not build a list when the caller iterates once. | standalone | gap | https://docs.python.org/3/howto/functional.html#generator-expressions-and-list-comprehensions |
| Return a list when the caller needs `len()` or a second pass. | standalone | gap | https://docs.python.org/3/howto/functional.html#generator-expressions-and-list-comprehensions |
| Name the exception class you catch. Do not write bare `except:`. | Errors | gap | https://peps.python.org/pep-0008/#programming-recommendations |
| Keep the `try` block to the smallest code that can raise. | Errors | gap | https://peps.python.org/pep-0008/#programming-recommendations |
| Put the follow-on code in an `else` clause, not in `try`. | Errors | gap | https://docs.python.org/3/tutorial/errors.html#handling-exceptions |
| Write `raise NewError(...) from err` when you convert an exception. | Errors | gap | https://docs.python.org/3/tutorial/errors.html#exception-chaining |
| Derive a custom exception from `Exception` and end its name with `Error`. | Errors | gap | https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions |
| Try the operation and catch the error instead of pre-checking. | Errors | gap | https://docs.python.org/3/glossary.html#term-EAFP |
| Do not add `__slots__` unless the program creates very many instances. | standalone | gap | https://docs.python.org/3/glossary.html#term-__slots__ |
| Use `@dataclass(slots=True)` instead of a hand-written `__slots__`. | standalone | gap | https://docs.python.org/3/library/dataclasses.html#dataclasses.dataclass |
| Do not inherit from two parent classes that both declare nonempty slots. | Inheritance | gap | https://docs.python.org/3/reference/datamodel.html#notes-on-using-slots |
| Do not set a class attribute with the same name as a slot. | standalone | gap | https://docs.python.org/3/reference/datamodel.html#notes-on-using-slots |
| Define `__eq__` and `__hash__` together, or use a frozen dataclass. | Data objects | gap | https://docs.python.org/3/reference/datamodel.html#object.__hash__ |
| Do not define `__hash__` on a class you mutate. | Data objects | gap | https://docs.python.org/3/reference/datamodel.html#object.__hash__ |
| Compare with `is` and `is not` against `None`. | standalone | gap | https://peps.python.org/pep-0008/#programming-recommendations |
| Check a type with `isinstance()`, not with `type(x) == T`. | Types | gap | https://peps.python.org/pep-0008/#programming-recommendations |
| Use an f-string for string interpolation. | standalone | gap | https://peps.python.org/pep-0498/ |
| Do not use an f-string in a logging call. Pass `%s` arguments. | Logging | gap | https://docs.python.org/3/howto/logging.html#logging-variable-data |
| Join a list of strings. Do not use `+=` in a loop. | standalone | gap | https://docs.python.org/3/faq/programming.html#what-is-the-most-efficient-way-to-concatenate-many-strings-together |
| Use `str.startswith()` and `str.endswith()`, not a slice comparison. | standalone | gap | https://peps.python.org/pep-0008/#programming-recommendations |
| Use `pathlib.Path` for a filesystem path, not an `os.path` string. | standalone | gap | https://docs.python.org/3/library/pathlib.html#comparison-to-the-os-and-os-path-modules |
| Read a whole small file with `Path.read_text()`. | Resources | gap | https://docs.python.org/3/library/pathlib.html#pathlib.Path.read_text |
| Use `enumerate()` instead of `range(len(items))`. | standalone | gap | https://docs.python.org/3/library/functions.html#enumerate |
| Use `zip(a, b, strict=True)` when both iterables must match in length. | standalone | gap | https://docs.python.org/3/library/functions.html#zip |
| Prefer an assignment statement to `:=` when both work. | standalone | gap | https://peps.python.org/pep-0572/ |
| Do not use `:=` when it makes the evaluation order unclear. | standalone | gap | https://peps.python.org/pep-0572/ |
| Use `match` to destructure a nested value, not to replace a short `if`. | standalone | gap | https://peps.python.org/pep-0635/ |
| Use a class pattern instead of `isinstance()` plus attribute reads. | Inheritance | gap | https://peps.python.org/pep-0635/ |
| Spell a callback as `Callable[[Arg], Ret]` from `collections.abc`. | Types | gap | https://docs.python.org/3/library/typing.html#annotating-callable-objects |
| Use a `Protocol` with `__call__` for a keyword or variadic callback. | Types | gap | https://docs.python.org/3/library/typing.html#annotating-callable-objects |
| Use `Callable[..., T]` only when the argument list is truly free. | Types | gap | https://docs.python.org/3/library/typing.html#annotating-callable-objects |
| Write `def f[T](x: T) -> T` instead of a module-level `TypeVar`. | Types | gap | https://peps.python.org/pep-0695/ |
| Use a `Protocol` instead of an ABC when the interface shares no code. | Inheritance | gap | https://peps.python.org/pep-0544/ |
| Use a builtin generic such as `list[int]`, not `typing.List`. | Types | covered | https://peps.python.org/pep-0585/ |
| Use `Literal` or `StrEnum` for a fixed set of strings. | Types | covered | https://docs.python.org/3/library/enum.html#enum.StrEnum |
| Raise an exception for an input check. Do not use `assert`. | Errors | covered | https://peps.python.org/pep-0008/#programming-recommendations |
| Write a one-line docstring that names the effect, not the signature. | Comments and docstrings | covered | https://peps.python.org/pep-0257/ |
| PEP 257 asks for a docstring on every public module, class, and function. | Comments and docstrings | conflicts | https://peps.python.org/pep-0257/ |
| Bind a function with `def`. Do not assign a lambda to a name. | Functions | gap | https://peps.python.org/pep-0008/#programming-recommendations |
| Mark a non-public name with one leading underscore. | Module boundaries | gap | https://docs.python.org/3/tutorial/classes.html#private-variables |
| Use two leading underscores only to avoid a subclass name clash. | Module boundaries | gap | https://docs.python.org/3/tutorial/classes.html#private-variables |
| Apply `functools.wraps` in every decorator you write. | standalone | gap | https://docs.python.org/3/library/functools.html#functools.wraps |
| Use `cached_property` for an expensive value on an unchanging object. | standalone | gap | https://docs.python.org/3/library/functools.html#functools.cached_property |
| Do not put `lru_cache` on a function with a side effect. | State | gap | https://docs.python.org/3/library/functools.html#functools.lru_cache |
| Use `__init_subclass__` instead of writing a custom metaclass. | Inheritance | gap | https://peps.python.org/pep-0487/ |
| Do not use `from x import *`. | Module boundaries | covered | https://peps.python.org/pep-0008/#imports |
| Use the `logging` module outside a CLI entry point. | Logging | covered | https://docs.python.org/3/howto/logging.html |

## Idioms and cognitive debt

### Idioms that lower cognitive debt

- A comprehension that maps or filters one sequence. The reader sees the whole
  transform on one line. Source: https://peps.python.org/pep-0202/
- A `with` statement. The scope shows where the resource closes.
  Source: https://docs.python.org/3/library/contextlib.html
- An f-string. The value sits next to the placeholder.
  Source: https://peps.python.org/pep-0498/
- `enumerate()` and `zip()`. They name the index and the pair.
  Source: https://docs.python.org/3/library/functions.html#enumerate
- `pathlib.Path`. The object carries the path operations.
  Source: https://docs.python.org/3/library/pathlib.html#comparison-to-the-os-and-os-path-modules
- A frozen dataclass. One declaration gives fields, equality, and a hash.
  Source: https://docs.python.org/3/library/dataclasses.html#dataclasses.dataclass
- A `Protocol`. It states the interface without forcing an inheritance link.
  Source: https://peps.python.org/pep-0544/
- A generator for a large stream. The reader holds one item, not a whole list.
  Source: https://docs.python.org/3/howto/functional.html#generator-expressions-and-list-comprehensions

### Idioms that raise cognitive debt

- A custom metaclass. The reader must track the code, the metaclass hint, the
  metaclass, the class, and the instances at the same time.
  Source: https://peps.python.org/pep-0487/
- Multiple inheritance. The method resolution order changes with the base list,
  and every case creates a diamond through `object`.
  Source: https://docs.python.org/3/tutorial/classes.html#multiple-inheritance
- Dynamic attribute access through `__getattr__`. It runs only when normal lookup
  fails, so an instance attribute silently hides it.
  Source: https://docs.python.org/3/reference/datamodel.html#object.__getattr__
- A decorator that omits `functools.wraps`. The name and the docstring of the
  wrapped function disappear.
  Source: https://docs.python.org/3/library/functools.html#functools.wraps
- `__slots__`. The docs call the technique tricky and reserve it for rare cases.
  Source: https://docs.python.org/3/glossary.html#term-__slots__
- A nested comprehension. The tutorial replaces its own nested example with a
  builtin call.
  Source: https://docs.python.org/3/tutorial/datastructures.html#nested-list-comprehensions
- A dense walrus expression. PEP 572 asks you to restructure it into statements.
  Source: https://peps.python.org/pep-0572/
- A bare `except:`. It catches `SystemExit` and `KeyboardInterrupt` and hides
  other faults.
  Source: https://peps.python.org/pep-0008/#programming-recommendations

## Source notes

- refactoring.guru gave almost no Python-specific advice. Several technique pages
  show PHP or Java code under a Python label.
- The refactoring.guru Singleton page recommends a metaclass. That advice opposes
  PEP 487 and raises cognitive debt.
- alysivji/notes is a book summary. Every claim above traces to a PEP or to the
  Python documentation instead.
