# Research: C and C++ code quality

This file lists the C and C++ rules that a reader must judge, because no linter can decide them.

Each row traces to a page fetched on 12 September 2026. The `From` column names the
source rule. The `Status` column compares the row to `rules/code-quality.md`. It names the `###`
section when the base file already states the rule. The `C only` column marks a
row that applies to C alone.

| Rule | From | Status | C only | Source |
|---|---|---|---|---|
| Tie every resource to an object whose destructor releases it. | CppCG R.1 | covered (Resources) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r1-manage-resources-automatically-using-resource-handles-and-raii-resource-acquisition-is-initialization |
| Treat a raw pointer as non-owning. Mark an owner with a smart pointer. | CppCG R.3 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r3-a-raw-pointer-a-t-is-non-owning |
| Treat a raw reference as non-owning. | CppCG R.4 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r4-a-raw-reference-a-t-is-non-owning |
| Never transfer ownership through a raw pointer or a raw reference. | CppCG I.11 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i11-never-transfer-ownership-by-a-raw-pointer-t-or-reference-t |
| Give a class one fixed owner for each resource it holds. | Google Ownership | gap | no | https://google.github.io/styleguide/cppguide.html#Ownership_and_Smart_Pointers |
| Prefer a scoped object. Put an object on the heap only for a reason. | CppCG R.5 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r5-prefer-scoped-objects-dont-heap-allocate-unnecessarily |
| Prefer `unique_ptr` to `shared_ptr` unless two owners really exist. | CppCG R.21 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r21-prefer-unique_ptr-over-shared_ptr-unless-you-need-to-share-ownership |
| Take a smart pointer parameter only to state a lifetime effect. | CppCG R.30 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r30-take-smart-pointers-as-parameters-only-to-explicitly-express-lifetime-semantics |
| Take `T*` or `T&` when the function only reads or writes the object. | CppCG F.7 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f7-for-general-use-take-t-or-t-arguments-rather-than-smart-pointers |
| Break a cycle of `shared_ptr` with a `weak_ptr`. | CppCG R.24 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r24-use-stdweak_ptr-to-break-cycles-of-shared_ptrs |
| Decide for each raw pointer or reference member whether it owns its object. | CppCG C.32 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c32-if-a-class-has-a-raw-pointer-t-or-reference-t-consider-whether-it-might-be-owning |
| Release every resource a class acquires in that class's destructor. | CppCG C.31 | covered (Resources) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c31-all-resources-acquired-by-a-class-must-be-released-by-the-classs-destructor |
| Hand a raw allocation to a manager object in the same statement. | CppCG R.12 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r12-immediately-give-the-result-of-an-explicit-resource-allocation-to-a-manager-object |
| Do one explicit resource allocation in one statement. | CppCG R.13 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r13-perform-at-most-one-explicit-resource-allocation-in-a-single-expression-statement |
| Do not pass a pointer or a reference taken from an aliased smart pointer. | CppCG R.37 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r37-do-not-pass-a-pointer-or-reference-obtained-from-an-aliased-smart-pointer |
| Do not let an iterator, a pointer, or a reference outlive its container element. | CERT CTR51-CPP | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-cpp-coding-standard/rules/containers-ctr/ctr51-cpp |
| Allocate and free memory in one module, at one level of abstraction. | CERT MEM00-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/memory-management-mem/mem00-c |
| Store a new value in a pointer right after you free it. | CERT MEM01-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/memory-management-mem/mem01-c |
| Write one pointer validation function and call it everywhere. | CERT MEM10-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/memory-management-mem/mem10-c |
| Avoid a large stack allocation. | CERT MEM05-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/memory-management-mem/mem05-c |
| Pick one error-handling strategy for the project before you write code. | CppCG E.1 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e1-develop-an-error-handling-strategy-early-in-a-design |
| Build the error strategy around the invariant each type keeps. | CppCG E.4 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e4-design-your-error-handling-strategy-around-invariants |
| Throw an exception when a function cannot do its assigned task. | CppCG E.2 | covered (Errors) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e2-throw-an-exception-to-signal-that-a-function-cant-perform-its-assigned-task |
| Let a constructor establish the invariant, and throw when it cannot. | CppCG E.5 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e5-let-a-constructor-establish-an-invariant-and-throw-if-it-cannot |
| Use an exception for an error only, never for ordinary control flow. | CppCG E.3 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e3-use-exceptions-for-error-handling-only |
| Do not catch an exception in a function that cannot act on it. | CppCG E.17 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e17-dont-try-to-catch-every-exception-in-every-function |
| Keep explicit `try` and `catch` rare. Let a destructor do the cleanup. | CppCG E.18 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e18-minimize-the-use-of-explicit-trycatch |
| Define a purpose-built exception type. Do not throw a built-in type. | CppCG E.14 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e14-use-purpose-designed-user-defined-types-as-exceptions-not-built-in-types |
| Never let an exception leave a destructor. | CppCG C.36 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c36-a-destructor-must-not-fail |
| When you cannot throw, put cleanup in a scope-exit object. | CppCG E.19 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e19-use-a-final_action-object-to-express-cleanup-if-no-suitable-resource-handle-is-available |
| When you cannot throw, simulate RAII rather than free the resource by hand. | CppCG E.25 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e25-if-you-cant-throw-exceptions-simulate-raii-for-resource-management |
| When you cannot throw, use an error code in every function, not in some. | CppCG E.27 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e27-if-you-cant-throw-exceptions-use-error-codes-systematically |
| Do not report an error through global state such as `errno`. | CppCG E.28 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e28-avoid-error-handling-based-on-global-state-eg-errno |
| Do not use an in-band error indicator such as a sentinel return value. | CERT ERR02-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/error-handling-err/err02-c |
| Pick a termination strategy before you write the first error path. | CERT ERR04-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/error-handling-err/err04-c |
| Let library code detect an error without deciding how to handle it. | CERT ERR05-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/error-handling-err/err05-c |
| Read the value that a library call returns, or say why you ignore it. | CERT EXP12-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/expressions-exp/exp12-c |
| Detect and handle an error that a standard library function reports. | CERT ERR33-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/rules/error-handling-err/err33-c |
| Make an interface explicit. Do not hide a dependency in a global. | CppCG I.1 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i1-make-interfaces-explicit |
| Make an interface precisely and strongly typed. | CppCG I.4 | covered (Types) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i4-make-interfaces-precisely-and-strongly-typed |
| Mark a pointer parameter that must never be null. | CppCG I.12 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i12-declare-a-pointer-that-must-not-be-null-as-not_null |
| Pass a range as one span object, not as a bare pointer. | CppCG I.13 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i13-do-not-pass-an-array-as-a-single-pointer |
| Prefer a span parameter to a pointer and a length pair. | CppCG R.14 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#r14-avoid--parameters-prefer-span |
| State the precondition of a function. | CppCG I.5 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i5-state-preconditions-if-any |
| State the postcondition of a function. | CppCG I.7 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i7-state-postconditions |
| Keep the number of function arguments low. | CppCG I.23 | covered (Functions) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i23-keep-the-number-of-function-arguments-low |
| Validate every parameter a public function takes. | CERT API00-C | covered (Types) | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/application-programming-interfaces-api/api00-c |
| Give related functions the same shape and the same error report. | CERT API03-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/application-programming-interfaces-api/api03-c |
| Pass the buffer size next to every array parameter. | CERT API02-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/application-programming-interfaces-api/api02-c |
| Hide a struct's representation behind an opaque type. | CERT DCL12-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/declarations-and-initialization-dcl/dcl12-c |
| Return a value instead of writing through an output parameter. | CppCG F.20 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f20-for-out-output-values-prefer-return-values-to-output-parameters |
| Return a named struct when a function produces two or more values. | CppCG F.21 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f21-to-return-multiple-out-values-prefer-returning-a-struct |
| Prefer a named struct to a pair or a tuple when the fields have meanings. | Google Structs vs. Tuples | gap | no | https://google.github.io/styleguide/cppguide.html#Structs_vs._Tuples |
| Pass a cheap-to-copy input by value and anything else by reference to const. | CppCG F.16 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f16-for-in-parameters-pass-cheaply-copied-types-by-value-and-others-by-reference-to-const |
| Pass an in-out parameter by reference to non-const. | CppCG F.17 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f17-for-in-out-parameters-pass-by-reference-to-non-const |
| Use `T*` rather than `T&` when "no argument" is a valid call. | CppCG F.60 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f60-prefer-t-over-t-when-no-argument-is-a-valid-option |
| Pass a pointer or a reference to const unless the callee writes through it. | CppCG Con.3 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#con3-by-default-pass-pointers-and-references-to-consts |
| Prefer a concrete type to a class hierarchy. | CppCG C.10 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c10-prefer-concrete-types-over-class-hierarchies |
| Make a concrete value type regular: copy, compare, and assign like `int`. | CppCG C.11 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c11-make-concrete-types-regular |
| Use `class` when an invariant exists and `struct` when the fields vary freely. | CppCG C.2 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c2-use-class-if-the-class-has-an-invariant-use-struct-if-the-data-members-can-vary-independently |
| Define a constructor when the class holds an invariant. | CppCG C.40 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c40-define-a-constructor-if-a-class-has-an-invariant |
| Make a constructor produce a fully initialized object. | CppCG C.41 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c41-a-constructor-should-create-a-fully-initialized-object |
| Do not use two-phase initialization with a separate `Init()` call. | CppCG NR.5 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nr5-dont-use-two-phase-initialization |
| Avoid work in a constructor that can fail with no way to report it. | Google Constructors | gap | no | https://google.github.io/styleguide/cppguide.html#Doing_Work_in_Constructors |
| Do not make a data member const or a reference in a copyable type. | CppCG C.12 | conflicts (Data objects) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c12-dont-make-data-members-const-or-references-in-a-copyable-or-movable-type |
| Avoid a trivial getter and setter. Make the data member public instead. | CppCG C.131 | conflicts (Data objects) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c131-avoid-trivial-getters-and-setters |
| Make a function a member only when it needs the class representation. | CppCG C.4 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c4-make-a-function-a-member-only-if-it-needs-direct-access-to-the-representation-of-a-class |
| Expose as few members as the class can work with. | CppCG C.9 | covered (Module boundaries) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c9-minimize-exposure-of-members |
| A copy operation must not change the source object. | CERT OOP58-CPP | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-cpp-coding-standard/rules/object-oriented-programming-oop/oop58-cpp |
| Prefer composition to inheritance. Make inheritance public when you use it. | Google Inheritance | covered (Inheritance) | no | https://google.github.io/styleguide/cppguide.html#Inheritance |
| Make a base class that acts as an interface a pure abstract class. | CppCG C.121 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c121-if-a-base-class-is-used-as-an-interface-make-it-a-pure-abstract-class |
| Do not make a function virtual without a reason you can name. | CppCG C.132 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c132-dont-make-a-function-virtual-without-reason |
| Access a polymorphic object through a pointer or a reference. | CppCG C.145 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c145-access-polymorphic-objects-through-pointers-and-references |
| Prefer a virtual function to a cast down the class hierarchy. | CppCG C.153 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c153-prefer-virtual-function-to-casting |
| Prefer a virtual `clone` to public copying for a polymorphic class. | CppCG C.130 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c130-for-making-deep-copies-of-polymorphic-classes-prefer-a-virtual-clone-function-instead-of-public-copy-constructionassignment |
| Use multiple inheritance only to combine distinct interfaces. | CppCG C.135 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c135-use-multiple-inheritance-to-represent-multiple-distinct-interfaces |
| Define a non-member function for a symmetric operator. | CppCG C.161 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c161-use-non-member-functions-for-symmetric-operators |
| Overload an operator only for its conventional meaning. | CppCG C.167 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c167-use-an-operator-for-an-operation-with-its-conventional-meaning |
| Do not define a user-defined literal. | Google Operator Overloading | gap | no | https://google.github.io/styleguide/cppguide.html#Operator_Overloading |
| Avoid an implicit conversion operator. | CppCG C.164 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#c164-avoid-implicit-conversion-operators |
| Use an overload only when the call site says which one runs. | Google Function Overloading | gap | no | https://google.github.io/styleguide/cppguide.html#Function_Overloading |
| Give a default argument only when its value never changes. | Google Default Arguments | gap | no | https://google.github.io/styleguide/cppguide.html#Default_Arguments |
| Prefer immutable data. Declare an object const or constexpr by default. | CppCG P.10, Con.1 | covered (Data objects) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#con1-by-default-make-objects-immutable |
| Keep a scope small. Declare a name where you first have a value. | CppCG ES.5, ES.22 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es5-keep-scopes-small |
| Do not use one variable for two unrelated purposes. | CppCG ES.26 | covered (State) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es26-dont-use-a-variable-for-two-unrelated-purposes |
| Avoid a singleton. Pass the object as a parameter instead. | CppCG I.3 | covered (State) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i3-avoid-singletons |
| Avoid a global object with a complex constructor. | CppCG I.22 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#i22-avoid-complex-initialization-of-global-objects |
| Forbid a static object whose destructor does work. | Google Static Variables | gap | no | https://google.github.io/styleguide/cppguide.html#Static_and_Global_Variables |
| Prefer a stack array type to a raw C array. | CppCG ES.27 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es27-use-stdarray-or-stack_array-for-arrays-on-the-stack |
| Write a program as if it already runs in many threads. | CppCG CP.1 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp1-assume-that-your-code-will-run-as-part-of-a-multi-threaded-program |
| Share as little writable data between threads as the design allows. | CppCG CP.3 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp3-minimize-explicit-sharing-of-writable-data |
| Define a mutex next to the data it guards. | CppCG CP.50 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp50-define-a-mutex-together-with-the-data-it-guards-use-synchronized_valuet-where-possible |
| Take and release a lock with an RAII guard, never by hand. | CppCG CP.20 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp20-use-raii-never-plain-lockunlock |
| Take and release a lock in the same module, at the same level of abstraction. | CERT CON01-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/concurrency-con/con01-c |
| Never call unknown code, such as a callback, while you hold a lock. | CppCG CP.22 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp22-never-call-unknown-code-while-holding-a-lock-eg-a-callback |
| Do not block while you hold a lock. | CERT CON05-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/concurrency-con/con05-c |
| Take several mutexes in one scoped lock, never one after another. | CppCG CP.21 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp21-use-stdlock-or-stdscoped_lock-to-acquire-multiple-mutexes |
| Think in tasks, not in threads. | CppCG CP.4 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp4-think-in-terms-of-tasks-rather-than-threads |
| Do not use `volatile` to synchronize threads. | CppCG CP.8 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp8-dont-try-to-use-volatile-for-synchronization |
| Do not detach a thread. Join it in a scope. | CppCG CP.26 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp26-dont-detach-a-thread |
| Do not write lock-free code unless you can name why a lock fails. | CppCG CP.100 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp100-dont-use-lock-free-programming-unless-you-absolutely-have-to |
| Do not write your own double-checked locking. | CppCG CP.110 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#cp110-do-not-write-your-own-double-checked-locking-for-initialization |
| Return early with a guard clause instead of nesting conditions. | CppCG F.56 | covered (Functions) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#f56-avoid-unnecessary-condition-nesting |
| Turn a loop that computes a predicate into a named predicate function. | LLVM Predicate Loops | gap | no | https://llvm.org/docs/CodingStandards.html#turn-predicate-loops-into-predicate-functions |
| Avoid a complicated expression. Split it into named steps. | CppCG ES.40 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es40-avoid-complicated-expressions |
| Do not depend on the order in which function arguments evaluate. | CppCG ES.44 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es44-dont-depend-on-order-of-evaluation-of-function-arguments |
| Keep `break` and `continue` rare inside a loop. | CppCG ES.77 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es77-minimize-the-use-of-break-and-continue-in-loops |
| Prefer a `switch` to an `if` chain when you test one value. | CppCG ES.70 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es70-prefer-a-switch-statement-to-an-if-statement-when-there-is-a-choice |
| Write a `default` case for the common case only, not to silence a warning. | CppCG ES.79 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es79-use-default-to-handle-common-cases-only |
| Write a loop termination condition that holds for every input. | CERT MSC21-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/miscellaneous-msc/msc21-c |
| Do not collect cleanup at the end of a function and jump there with `goto`. | CppCG NR.6 | conflicts (see Conflicts) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nr6-dont-place-all-cleanup-actions-at-the-end-of-a-function-and-goto-exit |
| Use a `goto` chain to release resources on an error exit. | CERT MEM12-C | conflicts (see Conflicts) | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/memory-management-mem/mem12-c |
| Prefer the standard library to hand-written code. | CppCG ES.1, SL.1 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es1-prefer-the-standard-library-to-other-libraries-and-to-handcrafted-code |
| Prefer a suitable abstraction to a raw language feature. | CppCG ES.2 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es2-prefer-suitable-abstractions-to-direct-use-of-language-features |
| Use type deduction only when it makes the code clearer to a new reader. | Google Type deduction | gap | no | https://google.github.io/styleguide/cppguide.html#Type_deduction |
| Use `auto` only when the type name already appears on the same line. | CppCG ES.11 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es11-use-auto-to-avoid-redundant-repetition-of-type-names |
| Watch for a copy that `auto` hides. Write `auto&` when you mean a reference. | LLVM auto copies | gap | no | https://llvm.org/docs/CodingStandards.html#beware-unnecessary-copies-with-auto |
| Write `std::move` only when you move an object into another scope. | CppCG ES.56 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#es56-write-stdmove-only-when-you-need-to-explicitly-move-an-object-to-another-scope |
| Use a template to raise the level of abstraction, not to save typing. | CppCG T.1 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t1-use-templates-to-raise-the-level-of-abstraction-of-code |
| Constrain every template parameter with a concept. | CppCG T.10 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t10-specify-concepts-for-all-template-arguments |
| Ask a template for only the properties it really uses. | CppCG T.41 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t41-require-only-essential-properties-in-a-templates-concepts |
| Avoid template metaprogramming unless you can name the problem it solves. | CppCG T.120 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t120-use-template-metaprogramming-only-when-you-really-need-to |
| Avoid type erasure where a concrete type works. | CppCG T.49 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t49-where-possible-avoid-type-erasure |
| Do not turn a class hierarchy into a template without a reason. | CppCG T.80 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t80-do-not-naively-templatize-a-class-hierarchy |
| Keep a template's context dependencies few. | CppCG T.60 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t60-minimize-a-templates-context-dependencies |
| Do not specialize a function template. Write an overload instead. | CppCG T.144 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t144-dont-specialize-function-templates |
| Do not write code inside a template that only one type can use. | CppCG T.143 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#t143-dont-write-unintentionally-non-generic-code |
| Keep an internal header private to its library. | LLVM Internal Headers | gap | no | https://llvm.org/docs/CodingStandards.html#keep-internal-headers-private |
| Separate stable code from code that still changes. | CppCG A.1 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#a1-separate-stable-code-from-less-stable-code |
| Let libraries form a layered order with no cycle. | CppCG A.4, LLVM | gap | no | https://llvm.org/docs/CodingStandards.html#library-layering |
| Use a namespace to express logical structure, not to shorten a name. | CppCG SF.20 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#sf20-use-namespaces-to-express-logical-structure |
| Include the header you need. Do not write a forward declaration instead. | Google Forward Declarations | gap | no | https://google.github.io/styleguide/cppguide.html#Forward_Declarations |
| Do not say in a comment what the code already says. | CppCG NL.1 | covered (Comments and docstrings) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nl1-dont-say-in-comments-what-can-be-clearly-stated-in-code |
| State intent in a comment, not mechanism. | CppCG NL.2 | covered (Comments and docstrings) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nl2-state-intent-in-comments |
| Keep a comment short. | CppCG NL.3 | covered (Comments and docstrings) | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nl3-keep-comments-crisp |
| Name a non-obvious call-site argument in a short comment. | Google Implementation Comments | gap | no | https://google.github.io/styleguide/cppguide.html#Implementation_Comments |
| Make a name's length match the length of its scope. | CppCG NL.7, ES.7 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nl7-make-the-length-of-a-name-roughly-proportional-to-the-length-of-its-scope |
| Do not encode type information in a name. | CppCG NL.5 | gap | no | https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#nl5-avoid-encoding-type-information-in-names |
| Find and delete code that has no effect or that never runs. | CERT MSC07-C, MSC12-C | covered (Unused code) | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/miscellaneous-msc |
| Prefer an inline or a static function to a function-like macro. | CERT PRE00-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/preprocessor-pre/pre00-c |
| Do not use a macro to define part of a public interface. | Google Macros | gap | no | https://google.github.io/styleguide/cppguide.html#Preprocessor_Macros |
| Use an assertion for a diagnostic test of an internal invariant. | CERT MSC11-C | covered (Errors) | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/error-handling-err |
| Use `size_t` for any value that holds the size of an object. | CERT INT01-C | gap | no | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/integers-int/int01-c |
| Adopt one plan for managing strings across the whole program. | CERT STR01-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/characters-and-strings-str/str01-c |
| Point at a string literal with a pointer to const. | CERT STR05-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/characters-and-strings-str/str05-c |
| Declare a pointer parameter const when the function does not write through it. | CERT DCL13-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/declarations-and-initialization-dcl/dcl13-c |
| Return an empty array rather than a null pointer. | CERT MSC19-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/miscellaneous-msc/msc19-c |
| Do not call a deprecated or an obsolescent library function. | CERT MSC24-C | gap | yes | https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/miscellaneous-msc/msc24-c |
| Encapsulate each resource in a class whose destructor never throws. | cppreference RAII | covered (Resources) | no | https://en.cppreference.com/w/cpp/language/raii.html |

## Conflicts

Four rows contradict a rule that the base file already states, or contradict each other.

### C.12 against "Data objects"

The base file says: make a value object immutable by default. The direct C++ reading of
that rule is a class with `const` data members. C.12 forbids it. A `const` or reference
member makes a type copy-constructible but not copy-assignable. The type then breaks every
standard container that needs assignment.

The C++ form of immutability is a private member plus a const accessor. A `const`
object at the point of use also works. It is not a `const` member. The Python file has no matching
problem, because a frozen dataclass stays assignable as a whole.

### C.131 against "Data objects"

The base file says: return a read-only view of a collection, and expose add and remove
methods. C.131 says a trivial getter and setter add no meaning, so the data may as well be
public. C.2 and the Google guide agree: a type with no invariant should be a `struct` with
public fields.

The two rules agree once you split the case. A type with an invariant hides its data. A
type with no invariant exposes it. The base file states only the first half.

### NR.6 against CERT MEM12-C

The C++ Core Guidelines call the `goto exit` cleanup chain error-prone and a pre-exception
technique. CERT recommends the same chain for C.

Both sides are right for their language. C++ has destructors, so a scope-exit object does
the job. C has no destructor, so the `goto` chain is the least repetitive option left. The
rules file should state the C++ rule and the C rule separately.

### CERT MSC11-C against "Errors"

This is a near miss, not a real conflict. The base file reserves an assertion for an
internal invariant, which is what MSC11-C asks for. The tension sits elsewhere. The Core Guidelines I.6 rule asks for `Expects()` on a
precondition. LLVM asks you to assert liberally. Neither replaces a raised error on external input, so the base rule
stands.

## Linting

Run these three tools. Together they replace every mechanical rule this file left out.

```
clang-format -i --style=file <files>
clang-tidy --checks='-*,bugprone-*,cppcoreguidelines-*,misc-*,modernize-*,performance-*,readability-*,cert-*' <files>
cc -std=c2x -Wall -Wextra -Wshadow -Wconversion -fsanitize=address,undefined <files>
```

| Rule the tool replaces | Tool and check |
|---|---|
| Always initialize an object | `cppcoreguidelines-init-variables` |
| Define or delete all five special members together | `cppcoreguidelines-special-member-functions` |
| Give a polymorphic base a public virtual or protected destructor | `cppcoreguidelines-virtual-class-destructor` |
| Mark a single-argument constructor explicit | `cppcoreguidelines-explicit-constructor` |
| Do not slice a derived object | `cppcoreguidelines-slicing` |
| Do not call a virtual function in a constructor or a destructor | `clang-analyzer-optin.cplusplus.VirtualCall` |
| Avoid a non-const global variable | `cppcoreguidelines-avoid-non-const-global-variables` |
| Name a magic number as a constant | `cppcoreguidelines-avoid-magic-numbers` |
| Avoid `malloc` and `free` in C++ | `cppcoreguidelines-no-malloc` |
| Use `make_unique` and `make_shared` | `modernize-make-unique`, `modernize-make-shared` |
| Do not read a moved-from object | `bugprone-use-after-move` |
| Avoid adjacent parameters a caller can swap | `bugprone-easily-swappable-parameters` |
| Avoid a C-style cast and a const cast | `cppcoreguidelines-pro-type-cstyle-cast`, `cppcoreguidelines-pro-type-const-cast` |
| Prefer an enum class to a plain enum or a macro | `cppcoreguidelines-use-enum-class`, `cppcoreguidelines-macro-to-enum` |
| Avoid `goto` and `do`-`while` | `cppcoreguidelines-avoid-goto`, `cppcoreguidelines-avoid-do-while` |
| Do not make a data member public or protected in a class | `cppcoreguidelines-non-private-member-variables-in-classes` |
| Cap cognitive complexity for one function | `readability-function-cognitive-complexity` |
| Do not write `else` after a `return` | `readability-else-after-return` |
| Declare a local const when nothing writes it | `misc-const-correctness` |
| Do not write `using namespace` in a header | `google-build-using-namespace` |
| Give an internal definition internal linkage | `misc-use-internal-linkage` |
| Include what you use; break a header cycle | `misc-include-cleaner`, `misc-header-include-cycle` |
| Throw by value and catch by reference | `misc-throw-by-value-catch-by-reference` |
| Parenthesize every macro parameter | `bugprone-macro-parentheses` |
| Wrap a multi-statement macro in `do`-`while` | `bugprone-multiple-statement-macro` |
| Use a range-based `for` loop | `modernize-loop-convert` |
| Use `nullptr` and `override` | `modernize-use-nullptr`, `modernize-use-override` |
| Avoid two names that look alike | `misc-confusable-identifiers` |
| Write a member initializer list in declaration order | `-Wreorder` |
| Do not shadow a name in a nested scope | `-Wshadow` |
| Do not mix signed and unsigned arithmetic | `-Wsign-compare`, `-Wconversion` |
| Do not return a pointer or a reference to a local | `-Wreturn-local-addr` |
| Do not read freed memory; do not leak memory | AddressSanitizer, LeakSanitizer |
| Do not rely on undefined behavior at run time | UndefinedBehaviorSanitizer |
| Every layout and naming rule | `clang-format`, `readability-identifier-naming` |

CERT MSC00-C states the underlying rule: compile cleanly at a high warning level.
Source: https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/recommendations/miscellaneous-msc/msc00-c

## Notes on sources

### URLs that moved

Both CERT URLs in the task brief now redirect. They are no longer the live location.

| Old URL | New URL | Status |
|---|---|---|
| `https://wiki.sei.cmu.edu/confluence/display/c/` | `https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/` | 301 |
| `https://wiki.sei.cmu.edu/confluence/display/cplusplus/` | `https://cmu-sei.github.io/secure-coding-standards/sei-cert-cpp-coding-standard/` | 301 |

The old host refused a direct connection. No URL returned 404. The new site is a
single-page application, so each rule page must be fetched on its own. Every CERT URL in
the table was checked against
`https://cmu-sei.github.io/secure-coding-standards/sitemap.xml`.

### Where the sources disagree

| Question | C++ Core Guidelines | Google | LLVM |
|---|---|---|---|
| Exceptions | Use them; E.2 and NR.3 | Do not use them | Do not use them |
| RTTI and `dynamic_cast` | Use `dynamic_cast` for hierarchy navigation, C.146 | Avoid RTTI | Do not use RTTI |
| Forward declaration | Not addressed as a ban | Avoid it; include the header | Include as little as possible |
| Cleanup on error in C | NR.6 rejects the `goto` chain | Not addressed | Not addressed |

Sources: https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#e2-throw-an-exception-to-signal-that-a-function-cant-perform-its-assigned-task ,
https://google.github.io/styleguide/cppguide.html#Exceptions ,
https://llvm.org/docs/CodingStandards.html#do-not-use-rtti-or-exceptions

The exception split is the largest disagreement in the pair. It decides the whole error
section. The base file already picks the Core Guidelines side. So the rules file should keep
the "no exceptions" path as the C fallback.

### What the research could not confirm

- MISRA C and MISRA C++ sell their standards. No free authoritative rule text exists, so
  no MISRA row appears above. Only paraphrases circulate, and a paraphrase is not a source.
- refactoring.guru lists C++ on its catalog page but ships no C++ code samples for the
  refactoring techniques. Its material is language-neutral and already sits in
  `plans/research-refactorings.md`. Source: https://refactoring.guru/refactoring/techniques
- cppreference documents language behavior, not style. Only its RAII page states a rule.
  Source: https://en.cppreference.com/w/cpp/language/raii.html
- The judgment filter used the Core Guidelines' own Enforcement sections. 207 of its 514
  rules carry an empty enforcement note or the marker `???`. Those rules are the judgment
  set this file draws from.

## Counts

| Measure | Count |
|---|---|
| Total rows | 149 |
| gap | 127 |
| covered | 18 |
| conflicts | 4 |
| C only | 12 |

Counts read at the source: 514 numbered rules in the C++ Core Guidelines.
The CERT C and CERT C++ standards list 637 rule and recommendation titles.
The clang-tidy check list holds 591 checks.

## Decision

Written to `rules/code-quality-cpp.md` on 2026-09-12, 236 lines.

The 127 `gap` rows became rules. The other 22 rows resolved as below.

| Group | Rows | Outcome |
|---|---|---|
| `covered`, and the base statement needs no C or C++ form | 14 | Dropped. The base file already carries the rule. |
| `covered`, and the language changes the form | 4 | Rewritten. RAII, throwing on a failed task, `const` by default, and stating intent in a comment. |
| `conflicts` | 4 | Resolved below. |

Named drops inside the `gap` set:

| Row | Outcome | Reason |
|---|---|---|
| Do not define a user-defined literal | dropped | Only the Google guide states it, and it fires on almost no code. |
| Use type deduction only when it makes the code clearer | merged | The `auto` rule states the same test with a checkable trigger. |
| Prefer a span parameter to a pointer and a length pair | merged | Merged into the rule that forbids passing an array as one pointer. |
| Decide for each raw pointer member whether it owns its object | merged | Merged into the ownership rules at the top of `Resources`. |

Conflict resolutions written into the rules file:

| Conflict | Resolution |
|---|---|
| C.12 against `Data objects` | `Data objects` now states the C++ form: a private member plus a const accessor, never a `const` member. |
| C.131 against `Data objects` | Split by invariant. A type with an invariant hides its data. A type without one exposes it. |
| NR.6 against CERT MEM12-C | The `goto` cleanup chain sits in `### C only`, with a risk line that forbids it in C++. |
| CERT MSC11-C against `Errors` | No change. The base rule already matches, as the Conflicts section found. |

The `Complexity` section has no C or C++ form, because
`readability-function-cognitive-complexity` enforces it mechanically.
