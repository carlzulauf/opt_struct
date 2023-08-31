require "opt_struct/class_methods"
require "opt_struct/module_methods"
require "opt_struct/instance_methods"

module OptStruct

  RESERVED_WORDS = [
    :class, :options,
    *OptStruct::InstanceMethods.instance_methods,
    *OptStruct::InstanceMethods.protected_instance_methods,
    *OptStruct::InstanceMethods.private_instance_methods,
  ].freeze

  # Default value object allows us to distinguish unspecified defaults from nil
  DEFAULT = Object.new

  def self._inject_struct(target, source, args = [], **defaults, &callback)
    existing = source.instance_variable_get(:@_opt_structs)
    structs = Array(existing).dup

    if args.any? || defaults.any? || block_given?
      structs << [args, defaults, callback]
    end

    target.instance_variable_set(:@_opt_structs, structs) if existing || structs.any?

    if target.is_a?(Class)
      target.instance_exec do
        extend ClassMethods
        attr_reader :options
        include InstanceMethods
      end
      structs.each do |s_args, s_defaults, s_callback|
        target.expect_arguments *s_args if s_args.any?
        target.options **s_defaults     if s_defaults.any?
        target.class_exec(&s_callback)  if s_callback
      end
    else
      target.singleton_class.prepend ModuleMethods
    end
    target
  end

  def self.included(klass)
    _inject_struct(klass, self)
    super(klass)
  end

  def self.prepended(klass)
    _inject_struct(klass, self)
    super(klass)
  end

  def self.new(*args, **defaults, &callback)
    _inject_struct(Class.new, self, args.map(&:to_sym), **defaults, &callback)
  end

  def self.build(*args, **defaults, &callback)
    _inject_struct(Module.new, self, args.map(&:to_sym), **defaults, &callback)
  end
end
