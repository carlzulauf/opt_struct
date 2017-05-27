module OptStruct
  def self.new(*args, **defaults)
    check_for_invalid_args(args)
    args.map!(&:to_sym)
    Class.new do
      extend ClassMethods
      expect_arguments *args
      set_defaults defaults
      attr_reader :options

      def initialize(*values, **options)
        @options = self.class.defaults.merge(options)
        steal_arguments_from_options
        assign_arguments(values)
        check_arguments(values)
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

      def expected_arguments
        self.class.expected_arguments
      end
    end
  end

  private

  def self.check_for_invalid_args(args)

  end

  module ClassMethods

    def option_reader(*keys)
      keys.each do |key|
        define_method(key) { options[key] }
      end
    end

    def option_writer(*keys)
      keys.each do |key|
        define_method("#{key}=") { |value| option[key] = value }
      end
    end

    def option_accessor(*keys)
      option_reader *keys
      option_writer *keys
    end

    def set_defaults(defaults)
      @defaults = defaults
      option_accessor *defaults.keys
    end

    def defaults
      @defaults || {}
    end

    def expect_arguments(*arguments)
      @expected_arguments = arguments
      attr_accessor *arguments
    end

    def expected_arguments
      @expected_arguments
    end
  end
end
