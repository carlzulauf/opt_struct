module OptStruct
  module InstanceMethods
    def initialize(*arguments, **options)
      @arguments = arguments
      @options = options
      check_required_args
      check_required_keys
    end

    def fetch(*a, &b)
      options.fetch(*a, &b)
    end

    def defaults
      self.class.defaults
    end

    private

    def check_required_keys
      missing = self.class.required_keys.reject { |key| options.key?(key) }
      if missing.any?
        raise ArgumentError, "missing required keywords: #{missing.inspect}"
      end
    end

    def check_required_args
      self.class.expected_arguments.each_with_index do |arg, i|
        if i >= @arguments.length
          if options.key?(arg)
            @arguments[i] = options.delete(arg)
          elsif defaults.key?(arg)
            @arguments[i] = defaults[arg]
          else
            raise ArgumentError, "missing required argument: #{arg}"
          end
        end
      end
    end
  end
end
