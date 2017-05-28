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
      meths = String.new
      keys.each do |key|
        meths << <<~RUBY
          def #{key}
            options[:#{key}]
          end
        RUBY
      end
      self.class_eval meths
    end

    def option_writer(*keys)
      meths = String.new
      keys.each do |key|
        meths << <<~RUBY
          def #{key}=(value)
            options[:#{key}] = value
          end
        RUBY
      end
      self.class_eval meths
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
      assignment_lines = String.new
      arguments.each_with_index do |arg, i|
        assignment_lines << <<~RUBY
          @#{arg} = @options.delete(:#{arg}) if @options.key?(:#{arg})
          @#{arg} = values[#{i}] if values.length > #{i}
          raise ArgumentError, "missing required argument: #{arg}" unless defined?(@#{arg})
        RUBY
      end
      self.class_eval <<~RUBY
        def initialize(*values, **options)
          @options = self.class.defaults.merge(options)
          #{assignment_lines}
          check_required_keys
        end
      RUBY
    end

    def expected_arguments
      @expected_arguments || []
    end
  end
end
