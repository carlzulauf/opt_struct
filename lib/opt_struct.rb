module OptStruct
  def self.inject_struct(target_klass, &more_block)
    target_klass.instance_exec do
      extend ClassMethods
      attr_reader :options
      include InstanceMethods
    end
    target_klass.instance_exec(&more_block) if block_given?
    target_klass
  end

  def self.included(klass)
    inject_struct(klass)
  end

  def self.new(*args, **defaults)
    check_for_invalid_args(args)
    args.map!(&:to_sym)
    inject_struct(Class.new) do
      expect_arguments *args
      options defaults
    end
  end

  def self.build(*args, **defaults)
    check_for_invalid_args(args)
    args.map!(&:to_sym)
    Module.new do
      @arguments = args
      @defaults = defaults

      def self.arguments
        @arguments
      end

      def self.defaults
        @defaults
      end

      def self.included(klass)
        mod = self
        OptStruct.inject_struct(klass) do
          expect_arguments *mod.arguments
          options mod.defaults
        end
      end
    end
  end

  private

  def self.check_for_invalid_args(args)

  end

  module InstanceMethods
    def initialize(*values, **options)
      @options = self.class.defaults.merge(options)
      steal_arguments_from_options
      assign_arguments(values)
      check_arguments(values)
      check_required_keys
    end

    def fetch(*a, &b)
      options.fetch(*a, &b)
    end

    private

    def steal_arguments_from_options
      expected_arguments.each do |arg|
        send("#{arg}=", options.delete(arg)) if options.key?(arg)
      end
    end

    def assign_arguments(values)
      values.each_with_index do |value, i|
        send("#{expected_arguments[i]}=", value)
      end
    end

    def check_arguments(args)
      expected = expected_arguments.count
      actual = expected_arguments.count do |arg|
        instance_variable_defined?("@#{arg}")
      end
      unless actual == expected
        raise ArgumentError, "only #{actual} of #{expected} required arguments present"
      end
    end

    def check_required_keys
      missing = self.class.required_keys.select { |key| !options.key?(key) }
      if missing.any?
        raise ArgumentError, "missing required keywords: #{missing.inspect}"
      end
    end

    def expected_arguments
      self.class.expected_arguments
    end
  end

  module ClassMethods
    def inherited(subclass)
      instance_variables.each do |v|
        subclass.send(:instance_variable_set, v, instance_variable_get(v).dup)
      end
    end

    def required_keys
      @required_keys ||= []
    end

    def required(*keys)
      required_keys.concat keys
      option_accessor *keys
    end

    def option_reader(*keys)
      keys.each do |key|
        define_method(key) { options[key] }
      end
    end

    def option_writer(*keys)
      keys.each do |key|
        define_method("#{key}=") { |value| options[key] = value }
      end
    end

    def option_accessor(*keys)
      option_reader *keys
      option_writer *keys
    end

    def option(key, default = nil, **options)
      default = options[:default] if options.key?(:default)
      defaults[key] = default
      required_keys << key if options[:required]
      option_accessor key
    end

    def options(*keys, **keys_defaults)
      option_accessor *keys if keys.any?
      if keys_defaults.any?
        defaults.merge!(keys_defaults)
        option_accessor *(keys_defaults.keys - expected_arguments)
      end
    end

    def defaults
      @defaults ||= {}
    end

    def expect_arguments(*arguments)
      @expected_arguments = arguments
      attr_accessor *arguments
    end

    def expected_arguments
      @expected_arguments || []
    end
  end
end
