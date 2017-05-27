module OptStruct
  def self.new(*args, **defaults)
    check_for_invalid_args(args)
    args.map!(&:to_sym)
    Class.new do
      extend ClassMethods
      expect_arguments *args
      options defaults
      attr_reader :options

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
  end

  private

  def self.check_for_invalid_args(args)

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
