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
        self.class.expected_arguments.each_with_index do |arg, i|
          send("#{arg}=", values[i])
        end
        @options = self.class.defaults.merge(options)
        check_required
      end

      private

      def check_required

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
