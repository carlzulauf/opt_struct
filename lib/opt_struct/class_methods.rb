module OptStruct
  module ClassMethods
    def inherited(subclass)
      instance_variables.each do |v|
        ivar = instance_variable_get(v)
        subclass.send(:instance_variable_set, v, ivar.dup) if ivar
      end
    end

    def defined_keys
      @defined_keys ||= []
    end

    def required_keys
      @required_keys ||= []
    end

    def expected_arguments
      @expected_arguments ||= []
    end

    def defaults
      @defaults ||= {}
    end

    def required(*keys, **options)
      required_keys.concat keys
      option_accessor *keys, **options
    end

    def option_reader(*keys, **opts)
      keys.each do |key|
        define_method(key) { options[key] }
        private key if opts[:private]
      end
    end

    def option_writer(*keys, **opts)
      keys.each do |key|
        meth = "#{key}=".to_sym
        define_method(meth) { |value| options[key] = value }
        private meth if opts[:private]
      end
    end

    def option_accessor(*keys, **options)
      check_reserved_words(keys)
      defined_keys.concat keys
      option_reader *keys, **options
      option_writer *keys, **options
    end

    def option(key, default = OptStruct::DEFAULT, required: false, **options)
      default = options[:default] if options.key?(:default)
      defaults[key] = default unless default == OptStruct::DEFAULT
      required_keys << key if required
      option_accessor key, **options
    end

    def options(*keys, **keys_defaults)
      option_accessor *keys if keys.any?
      if keys_defaults.any?
        defaults.merge!(keys_defaults)
        option_accessor *(keys_defaults.keys - expected_arguments)
      end
    end

    def expect_arguments(*arguments)
      required(*arguments)
      expected_arguments.concat(arguments)
    end
    alias_method :expect_argument, :expect_arguments

    def init(meth = nil, &blk)
      add_callback(:init, meth || blk)
    end
    alias_method :after_init, :init

    def before_init(meth = nil, &blk)
      add_callback(:before_init, meth || blk)
    end

    def around_init(meth = nil, &blk)
      add_callback(:around_init, meth || blk)
    end

    def add_callback(name, callback)
      @_callbacks ||= {}
      @_callbacks[name] ||= []
      @_callbacks[name] << callback
    end

    def all_callbacks
      @_callbacks
    end

    private

    def check_reserved_words(words)
      Array(words).each do |word|
        if OptStruct::RESERVED_WORDS.member?(word)
          raise ArgumentError, "Use of reserved word is not permitted: #{word.inspect}"
        end
      end
    end
  end
end
