# The Opt Struct [![Build Status][travis-image]][travis-link]

A struct around a hash. Great for encapsulating actions with complex configuration, like interactor/action classes.

```ruby
gem "opt_struct"
```

# Examples

## Creating an OptStruct

```ruby
class User < OptStruct.new
  required :email, :name
  option :role, default: "member"

  def formatted_email
    %{"#{name}" <#{email}>}
  end
end
```

## Using an OptStruct

```ruby
user = User.new(email: "admin@user.com", name: "Ms. Admin", role: "admin")

# option accessors are available
user.name
# => "Ms. Admin"
user.formatted_email
# => "\"Ms. Admin\" <admin@user.com>"
user.name = "Amber Admin"
# => "Amber Admin"

# values are also accessible through the `#options` Hash
user.options
# => {:email=>"admin@user.com", :name=>"Amber Admin", :role=>"admin"}
user.options.fetch(:role)
# => "admin"
```

# Documentation

## Use As Inheritable Class

`OptStruct.new` returns an instance of `Class` that can be inherited or initialized directly.

The following are functionally equivalent

```ruby
class User < OptStruct.new
  required :email
  option :name
end
```

```ruby
User = OptStruct.new do
  required :email
  option :name
end
```

`OptStruct` classes can safely have descendants with their own isolated options.

```ruby
class AdminUser < User
  required :token
end

User.new(email: "regular@user.com")
# => #<User:0x0... @options={:email=>"regular@user.com"}>

AdminUser.new(email: "admin@user.com")
# ArgumentError: missing required keywords: [:token]

AdminUser.new(email: "admin@user.com", token: "a2236843f0227af2")
# => #<AdminUser:0x0... @options={:email=>"admin@user.com", :token=>"..."}>
```

## Use As Mixin Module

`OptStruct.build` returns an instance of `Module` that can be included into a class or another module.

The following are functionally equivalent

```ruby
module Visitable
  include OptStruct.build
  options :expected_at, :arrived_at, :departed_at
end

class AuditLog
  include Visitable
end
```

```ruby
Visitable = OptStruct.build { options :expected_at, :arrived_at, :departed_at }

class AuditLog
  include Visitable
end
```

These examples result in an `AuditLog` class with identical behavior, but no explicit `Visitable` module.

```ruby
class AuditLog
  include OptStruct.build
  options :expected_at, :arrived_at, :departed_at
end
```

```ruby
class AuditLog
  include(OptStruct.build do
    options :expected_at, :arrived_at, :departed_at
  end)
end
```

## Optional Arguments

Optional arguments are simply accessor methods for values expected to be in the `#options` Hash. Optional arguments can be defined in multiple ways.

All of the examples in this section are functionally equivalent.

```ruby
class User < OptStruct.new
  option :email
  option :role, default: "member"
end
```

```ruby
class User < OptStruct.new
  options :email, role: "member"
end
```

```ruby
class User < OptStruct.new
  options email: nil, role: "member"
end
```

Passing a Hash to `.new` or `.build` is equivalent to passing the same hash to `options`

```ruby
User = OptStruct.new(email: nil, role: "member")
```

Default blocks can also be used and are late evaluated on the each struct instance.

```ruby
class User < OptStruct.new
  option :email, default: -> { nil }
  option :role, -> { "member" }
end
```

```ruby
class User < OptStruct.new
  options :email, role: -> { "member" }
end
```

```ruby
class User < OptStruct.new
  option :email, nil
  option :role, -> { default_role }

  private

  def default_role
    "member"
  end
end
```

Default symbols are treated as method calls if the struct `#respond_to?` the method.

```ruby
class User < OptStruct.new
  options :email, :role => :default_role

  def default_role
    "member"
  end
end
```

## Required Arguments

Required arguments are just like optional arguments, except they are also added to the `.required_keys` collection, which is checked when an OptStruct is initialized. If the `#options` Hash does not contain all `.required_keys` then an `ArgumentError` is raised.

The following examples are functionally equivalent.

```ruby
class Student < OptStruct.new
  required :name
end
```

```ruby
class Student < OptStruct.new
  option :name, required: true
end
```

```ruby
class Student < OptStruct.new
  option :name
  required_keys << :name
end
```

### Expected Arguments

OptStructs can accept non-keyword arguments if the struct knows to expect them.

For code like this to work...

```ruby
user = User.new("admin@user.com", "admin")
user.email # => "admin@user.com"
user.role  # => "admin"
```

... the OptStruct needs to have some `.expected_arguments`.

The following `User` class examples are functionally equivalent and allow the code above to function.

```ruby
User = OptStruct.new(:email, :role)
```

```ruby
class User < OptStruct.new(:email)
  expect_argument :role
end
```

```ruby
class User
  include OptStruct.build(:email, :role)
end
```

```ruby
class User
  include OptStruct.build
  expect_arguments :email, :role
end
```

```ruby
class User < OptStruct.new(:email)
  expected_arguments << :role
end
```

Expected arguments are similar to required arguments, except they are in `.expected_arguments` collection, which is checked when an OptStruct is initialized.

Expected arguments can also be supplied using keywords. An `ArgumentError` is only raised if the expected argument is not in the list of arguments passed to `OptStruct#new` **and** the argument is not present in the `#options` Hash.

The following examples will initialize any of the `User` class examples above without error.

```ruby
User.new(email: "example@user.com", role: "member")
User.new("example@user.com", role: "member")
User.new(role: "member", email: "example@user.com")
```

## The `#options` Hash

All OptStruct arguments are read from and stored in a single `Hash` instance. This Hash can be accessed directly using the `options` method.

```ruby
Person = OptStruct.new(:name)
Person.new(name: "John", age: 32).options
# => {:name=>"John", :age=>32}
```

Feel free to write your own accessor methods for things like dependent options or other complex/private behavior.

```ruby
class Person < OptStruct.new
  option :given_name
  option :family_name

  def name
    options.fetch(:name) { "#{given_name} #{family_name}" }
  end
end
```

## On Initialization

All of the following examples are functionally equivalent.

OptStruct classes are initialized in an `initialize` method (in `OptStruct::InstanceMethods`) like most classes. Also, like most classes, you can override `initialize` as long as you remember to call `super` properly to retain `OptStruct` functionality.

```ruby
class UserReportBuilder < OptStruct.new(:user)
  attr_reader :report

  def initialize(*)
    super
    @report = []
  end
end
```

`OptStruct` also provides initialization callbacks to make hooking into and customizing the initialization of OptStruct classes easier and require less code.

```ruby
class UserReportBuilder < OptStruct.new(:user)
  attr_reader :report
  init { @report = [] }
end
```

```ruby
class UserReportBuilder < OptStruct.new(:user)
  attr_reader :report

  around_init do |instance|
    instance.call
    @report = []
  end
end
```

Available callbacks

* `around_init`
* `before_init`
* `init`
* `after_init`

## Inheritance, Expanded

See `spec/inheritance_spec.rb` for examples of just how crazy you can get.
