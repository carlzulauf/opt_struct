module OptStruct
  module InstanceMethods
    def initialize(*arguments, **options)
      @arguments = arguments
      @options = self.class.defaults.merge(options)
      check_required_args
      check_required_keys
    end

    def fetch(*a, &b)
      options.fetch(*a, &b)
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
          unless options.key?(arg)
            raise ArgumentError, "missing required argument: #{arg}"
          end
          @arguments[i] = options.delete(arg)
        end
      end
    end
  end
end
