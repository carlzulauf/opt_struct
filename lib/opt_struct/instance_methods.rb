module OptStruct
  module InstanceMethods
    def initialize(**options)
      @options = self.class.defaults.merge(options)
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

    def expected_arguments
      self.class.expected_arguments
    end
  end
end
