# The Opt Struct

A struct around a hash

## Example 1

Can work mostly like a regular struct, while accepting options

```ruby
MyClass = OptStruct.new(:foo, :bar)

MyClass.new
# => argument error

MyClass.new "foo", "bar"
# => #<MyClass>

i = MyClass.new "foo", "bar", yin: "yang"
i.options
# => {yin: "yang"}
i.fetch(:yin)
# => "yang"
```

## Example 2

Passing a hash promotes the keys (`:foo` below) to an `option` giving it getter/setter methods on the class. The value becomes the default. This is equivalent and can be combined with using the `option` macro.

If an option is required it needs to be called out as such using `required`.

```ruby
class MyClass < OptStruct.new(foo: "bar")
  required :yin
  option :bar, default: "foo"
end

MyClass.new
# => missing keyword argument :yin

i = MyClass.new yin: "yang"
# => #<MyClass>
i.foo
# => "bar"
i.bar
# => "foo"
i.foo = "foo"
i.options
# => {foo: "foo", bar: "foo", yin: "yang"}
```

## Example 3

Works as a plain old mixin as well.

```ruby
class MyClass
  include OptStruct
  required :foo
end

MyClass.new
# => missing keyword argument :foo

MyClass.new(foo: "bar").foo
# => "bar"
```

## Example 4

Options passed to `new` can be passed to `build` when used in module form.

```ruby
class MyClass
  include OptStruct.build(:foo, bar: nil)
end

MyClass.new
# => argument error

i = MyClass.new("something", bar: "foo")
[i.foo, i.bar]
# => ["something", "foo"]
```
