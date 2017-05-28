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

    # For the record, I don't like this, but it's undeniably faster than alternatives
    def expect_arguments(*arguments)
      @expected_arguments = arguments
      attr_accessor *arguments
      lines = []
      arguments.each_with_index do |arg, i|
        lines << "@#{arg} = options.delete(:#{arg}) if options.key?(:#{arg})"
        lines << "@#{arg} = values[#{i}] if values.length > #{i}"
        lines << %[raise ArgumentError, "missing required argument: #{arg}" unless defined?(@#{arg})]
      end
      self.class_eval <<~RUBY
        def assign_arguments(values)
          #{lines.join("\n  ")}
        end
      RUBY
    end

    def expected_arguments
      @expected_arguments || []
    end
  end
end
