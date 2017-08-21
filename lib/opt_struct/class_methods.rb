module OptStruct
  module ClassMethods
    def inherited(subclass)
      instance_variables.each do |v|
        ivar = instance_variable_get(v)
        subclass.send(:instance_variable_set, v, ivar.dup) if ivar
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
      check_reserved_words(keys)

      keys.each do |key|
        define_method(key) do
          if options.key?(key)
            options[key]
          else
            default = defaults[key]
            case default
            when Proc
              instance_exec(&default)
            when Symbol
              respond_to?(default) ? send(default) : default
            else
              default
            end
          end
        end
      end
    end

    def option_writer(*keys)
      check_reserved_words(keys)

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
      check_reserved_words(arguments)

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

    private

    RESERVED_WORDS = %i(class defaults options fetch check_required_args check_required_keys)

    def check_reserved_words(words)
      Array(words).each do |word|
        if RESERVED_WORDS.member?(word)
          raise ArgumentError, "Use of reserved word is not permitted: #{word.inspect}"
        end
      end
    end
  end
end
