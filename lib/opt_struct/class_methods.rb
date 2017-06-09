module OptStruct
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
      existing = expected_arguments.count
      expected_arguments.concat(arguments)

      arguments.each_with_index do |arg, i|
        n = i + existing
        define_method(arg) { @arguments[n] }
        define_method("#{arg}=") { |value| @arguments[n] = value }
      end

    end

    def expected_arguments
      @expected_arguments ||= []
    end
  end
end
