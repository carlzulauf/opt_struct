module OptStruct
  module InstanceMethods
    def initialize(*values, **options)
      @options = self.class.defaults.merge(options)
      assign_arguments(values)
      check_required_keys
    end

    def fetch(*a, &b)
      options.fetch(*a, &b)
    end

    private

    # overwritten if required arguments are defined
    def assign_arguments(values); end

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
