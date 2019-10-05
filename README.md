# The Opt Struct [![Build Status][travis-image]][travis-link]

[travis-image]: https://travis-ci.org/carlzulauf/opt_struct.svg?branch=master
[travis-link]: http://travis-ci.org/carlzulauf/opt_struct

A struct around a hash. Great for encapsulating actions with complex configuration, like interactor/action classes.

```ruby
gem "opt_struct"
```

## Example 1

Can work mostly like a regular struct, while accepting options

```ruby
MyClass = OptStruct.new(:foo, :bar)

MyClass.new
# => argument error

MyClass.new "foo", "bar"
# => #<MyClass>

MyClass.new foo: "foo", bar: "bar"
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
  required :yin # equivalent to: `option :yin, required: true`
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

## Example 5

Both `build` and `new` accept a block.

```ruby
PersonClass = OptStruct.new do
  required :first_name
  option :last_name

  def name
    [first_name, last_name].compact.join(" ")
  end
end

t = PersonClass.new(first_name: "Trish")
# => #<PersonClass>
t.name
# => "Trish"
t.last_name = "Smith"
t.name
# => "Trish Smith"

CarModule = OptStruct.build do
  required :make, :model
  options year: -> { Date.today.year }, transmission: :default_transmission

  def default_transmission
    "Automatic"
  end

  def name
    [year, make, model].compact.join(" ")
  end
end

class CarClass
  include CarModule
end

c = CarClass.new(make: "Infiniti", model: "G37", year: 2012)
c.name
# => "2012 Infinit G37"

c = CarClass.new(model: "WRX", make: "Subaru", year: nil)
c.name
# => "Subaru WRX"

c = CarClass.new(model: "BRZ", make: "Subaru")
c.name
# => "2017 Subaru BRZ"
```
