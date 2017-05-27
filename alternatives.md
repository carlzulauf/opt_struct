# Alternative Gems

Before I create this gem I should check to see if something out there solves the problem just as well or close enough to obviate the need for this.

### Searching for [hash_struct](https://rubygems.org/search?utf8=%E2%9C%93&query=hash_struct) on rubygems.

## [hash_struct](https://rubygems.org/gems/hash_struct)

Single file implementation: https://github.com/botanicus/hash_struct/blob/master/lib/hash_struct.rb

Very simple. Arguments passed to `HashStruct.new` become `attr_accessor`. Reverse inheritance: expects modules to be mixed into HashStruct or descendant. Guess it's sort of like a plugin system.

⛔

## [hash_with_struct_access](https://rubygems.org/gems/hash_with_struct_access)

Recursively expose simple hash keys as methods. Sort of like Hashie. Implementation is much simpler than expected. Extends `Hash`.

Uses method_missing and explicitly freezes hashes it touches.

⛔

## [hash_initialized_struct](https://rubygems.org/gems/hash_initialized_struct)

Same interface as Struct, but resulting class takes hash in initializer. All keys are required. Any extra keys cause errors.

Extreme strictness is not very struct-like. No values are required on a struct.

For some reason uses a class, but treats it like a module by aliasing `.new`.

⛔

### Moving on to some logical choices

## [virtus](https://github.com/solnic/virtus.git)

Large, complex dependency with many superfluous features including type casting.

If it can achieve the API goal without generating heavy-weight objects it may be worth a try.

It looks like it would take as much work to make virtus match the desired API as it would to create the API from scratch.

Author admits it mixes concerns and wants users to move replace it with three gems. One of them is `dry-struct`. Checking that out.

⛔

## [dry-struct](http://dry-rb.org/gems/dry-struct/)

Uses `dry-types` and seems awfully concerned with type enforcement.

Ability to coerce values is super nice and it has a simpler interface than Virtus for this chore.

Starring this gem. Solves a different problem than OptStruct intends to solve, but appears to solve it rather well.

⛔

### Searching for [struct](https://rubygems.org/search?utf8=%E2%9C%93&query=struct) on rubygems.

## [key_struct](https://github.com/ronen/key_struct)

Like the use of `[]` to build the struct.

Converts hash used to initialize into instance variables and relies on regular accessors.

Has the ability to re-produce the incoming hash.

Fairly small and simple implementation. Allows for default values to be set.

Instances are comparable. Nice.

No ability to to define non-keyword arguments. No module-like usage.

⛔

## [attribute_struct](https://rubygems.org/gems/attribute_struct)

More like a builder tool than a struct. Bare words used within are converted to hash keys, and can be nested, allowing you to create complex hash structures easily.

Nice, but unrelated to the concerns of OptStruct.

Another starred gem.

⛔

## [object_struct](https://rubygems.org/gems/object_struct)

Abandoned. Pulled from github.

⛔

## [immutable-struct](https://github.com/stitchfix/immutable-struct)

Interesting, but not sure how I feel about enforcing immutability.

API is more flexible than some others, but takes the approach of mostly matching Struct while accepting a hash as the only initializing argument.

Array coercion syntax is particularly weird. Might be an interesting approach for defining optional arguments, however.

⛔

## [immutable_struct](https://github.com/iconara/immutable_struct)

Matches Struct API, but removes setters. Resulting struct can be initialized with arguments or with a hash with keys that match the argument names.

Parameters aren't required, but can be made required using `.strict` toggle.

No module usage. No defaults. Immutability isn't necessary for this use case, and probably not even desired. OptStruct might want to support immutability as an optional feature.

⛔

## [method_struct](https://github.com/basecrm/method_struct)

Advertised as a refactoring tool.

It's kind of a nice way to setup interactors. `new+perform` just becomes `call`. Class level method passes down to `call` on the instance method with arguments available as getters.

Maybe a special subclass of OptStruct could allow this `call/call` or `perform/perform` shortcut for interactor/action type classes.

Good example of providing a `do` interface to build the class. Forgot Struct allows this. Should be supported.

⛔

## [classy_struct](https://github.com/amikula/classy_struct)

Kind of like OpenStruct, but more efficient as searched for keys are made methods on the class, so future instances already have the accessors.

⛔

## [better_struct](https://github.com/exAspArk/better_struct)

Another OpenStruct alternative claiming to be faster. This one also attempts to normalize non-underscore style string keys and some other fancy stuff.

⛔

## [finer_struct](https://github.com/notahat/finer_struct)

Sort of like OpenStruct with optional argument enforcement and immutability.

Had my hopes up when the author wrote about solving the needs of Struct and OpenStruct. Really doesn't do that.

⛔

## [closed_struct](https://rubygems.org/gems/closed_struct)

Like an angry less forgiving OpenStruct. No thanks.

⛔

## [type_struct](https://github.com/ksss/type_struct)

Struct with type enforcement. Meh.

⛔

## [simple_struct](https://github.com/deadlyicon/simple_struct)

Ditches Enumerable for an even lighter weight Struct than the stdlib.

⛔

## Conclusion

Some of these come close and provide important lessons. However, none do quite what I'd like from OptStruct.
