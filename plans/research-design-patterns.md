# Design patterns: a proposal for discussion

Status: proposal. Nothing here is a rule yet. The user decides.

| Pattern | Category | Use when | Debt | Source |
| --- | --- | --- | --- | --- |
| Factory Method | Creational | A subclass must decide which concrete product the base code creates. | medium | https://refactoring.guru/design-patterns/factory-method |
| Abstract Factory | Creational | Code must build whole families of matched products. | high | https://refactoring.guru/design-patterns/abstract-factory |
| Builder | Creational | A constructor takes many optional parameters. | medium | https://refactoring.guru/design-patterns/builder |
| Prototype | Creational | Copying an object must not depend on its concrete class. | medium | https://refactoring.guru/design-patterns/prototype |
| Singleton | Creational | One instance must exist, and no substitute works. | high | https://refactoring.guru/design-patterns/singleton |
| Adapter | Structural | An existing class has the right behavior but the wrong interface. | low | https://refactoring.guru/design-patterns/adapter |
| Bridge | Structural | A class varies along two independent dimensions at once. | high | https://refactoring.guru/design-patterns/bridge |
| Composite | Structural | The data really is a tree, and leaves and nodes share operations. | medium | https://refactoring.guru/design-patterns/composite |
| Decorator | Structural | Behavior must stack on one object at run time. | medium | https://refactoring.guru/design-patterns/decorator |
| Facade | Structural | Callers need a small door into a large subsystem. | low | https://refactoring.guru/design-patterns/facade |
| Flyweight | Structural | Measured memory use fails because objects duplicate state. | high | https://refactoring.guru/design-patterns/flyweight |
| Proxy | Structural | Access to a real object needs lazy loading, caching, or a check. | medium | https://refactoring.guru/design-patterns/proxy |
| Chain of Responsibility | Behavioral | A request passes through handlers whose order changes at run time. | high | https://refactoring.guru/design-patterns/chain-of-responsibility |
| Command | Behavioral | An operation must be queued, logged, or undone. | medium | https://refactoring.guru/design-patterns/command |
| Interpreter | Behavioral | A small language needs a grammar and an evaluator. | high | https://en.wikipedia.org/wiki/Interpreter_pattern |
| Iterator | Behavioral | Callers must walk a collection without seeing its storage. | low | https://refactoring.guru/design-patterns/iterator |
| Mediator | Behavioral | Many components talk to each other directly and tangle. | medium | https://refactoring.guru/design-patterns/mediator |
| Memento | Behavioral | State must be snapshotted and restored without exposing fields. | medium | https://refactoring.guru/design-patterns/memento |
| Observer | Behavioral | An unknown, changing set of listeners reacts to an event. | high | https://refactoring.guru/design-patterns/observer |
| State | Behavioral | A real state machine drives behavior through many states. | medium | https://refactoring.guru/design-patterns/state |
| Strategy | Behavioral | One step has several interchangeable algorithms. | low | https://refactoring.guru/design-patterns/strategy |
| Template Method | Behavioral | Several classes share one algorithm and differ in a few steps. | high | https://refactoring.guru/design-patterns/template-method |
| Visitor | Behavioral | New operations keep arriving over a stable class hierarchy. | high | https://refactoring.guru/design-patterns/visitor |

Verification note: the refactoring.guru catalog lists 22 patterns. The Gang of Four
book lists 23. The catalog drops Interpreter, and that page returns 404. The
Interpreter row above cites Wikipedia instead.

## 1. Patterns worth a rule

- Adapter: it names a boundary, so a reader sees where foreign code stops. Fowler's
  Gateway makes the same point: wrap access to an external system in one object
  (https://martinfowler.com/eaaCatalog/gateway.html).
- Facade: it shrinks what a caller must hold in mind to one small interface.
- Iterator: it removes repeated traversal code, and most languages already build it in.
- Strategy: it replaces one large conditional with named, separate choices.

Each of these four removes reading work at the point of use. The other patterns mostly
move work somewhere else instead.

## 2. Patterns to avoid by default

Candidates: Abstract Factory, Bridge, Chain of Responsibility, Flyweight, Interpreter,
Observer, Singleton, Template Method, Visitor.

This is the YAGNI conflict, and it should be named as such. Each one adds flexibility
that may never be needed. Fowler calls this the cost of carry, and writes that
"any extensibility point that's never used isn't just wasted effort, it's likely to get in
your way as well" (https://martinfowler.com/bliki/Yagni.html).

Two further points from primary sources support the list:

- Singleton hides global mutable state, which the existing State section already forbids.
  Erich Gamma said he favors dropping it, because "its use is almost always a design smell"
  (https://www.informit.com/articles/article.aspx?p=1404056).
- Observer and Chain of Responsibility hide control flow. Fowler warns that inversion of
  control "tends to be hard to understand and leads to problems when you are trying to
  debug" (https://martinfowler.com/articles/injection.html).

Counterpoint, stated fairly: each pattern is correct when its condition is already true.
Flyweight is right after a memory measurement fails. Visitor is right when the hierarchy is
stable and operations keep arriving. A rule should not ban them outright.

## 3. Open question for the user

Should a rules file mention design patterns at all? I recommend no, because the code
quality rules already cover the reader cost that patterns change. If you want one line,
forbid Singleton as hidden global state and stop there.
