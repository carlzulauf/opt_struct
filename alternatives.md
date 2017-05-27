# Alternative Gems

Before I create this gem I should check to see if something out there solves the problem just as well or close enough to obviate the need for this.

Searching for [hash_struct](https://rubygems.org/search?utf8=%E2%9C%93&query=hash_struct) on rubygems.

## [hash_struct](https://rubygems.org/gems/hash_struct)

Single file implementation: https://github.com/botanicus/hash_struct/blob/master/lib/hash_struct.rb

Very simple. Arguments passed to `HashStruct.new` become `attr_accessor`. Reverse inheritance.

Not a good alternative to OptHash, though good example of keeping things simple.

⛔

## [hash_with_struct_access](https://rubygems.org/gems/hash_with_struct_access)

Recursively expose simple hash keys as methods. Sort of like Hashie. Implementation is much simpler than expected. Extends `Hash`.

Uses method_missing and explicitly freezes hashes it touches.

⛔

## [hash_initialized_struct](https://rubygems.org/gems/hash_initialized_struct)
