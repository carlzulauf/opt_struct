module OptStruct
  module ClassMethods
    def inherited(subclass)
      opt_struct_class_constants.each do |c|
        subclass.const_set(c, const_get(c)) if const_defined?(c)
      end
    end

    # overwritten if `required` is called
    def required_keys
      [].freeze
    end

    def required(*keys, **options)
      add_required_keys *keys
      option_accessor *keys, **options
    end

    def option_reader(*keys, **options)
      keys.each do |key|
        class_eval <<~RUBY
          #{options[:private] ? "private" : ""} def #{key}
            options[:#{key}]
          end
        RUBY
      end
    end

    def option_writer(*keys, **options)
      keys.each do |key|
        class_eval <<~RUBY
          #{options[:private] ? "private" : ""} def #{key}=(value)
            options[:#{key}] = value
          end
        RUBY
      end
    end

    def option_accessor(*keys, **options)
      check_reserved_words(keys)
      option_reader *keys, **options
      option_writer *keys, **options
    end

    def option(key, default = nil, required: false, **options)
      default ||= options[:default]
      add_defaults key => default if default || options.key?(:default)
      add_required_keys key if required
      option_accessor key, **options
    end

    def options(*keys, **keys_defaults)
      option_accessor *keys if keys.any?
      if keys_defaults.any?
        add_defaults keys_defaults
        option_accessor *(keys_defaults.keys - expected_arguments)
      end
    end

    def defaults
      const_defined?(:OPT_DEFAULTS) ? const_get(:OPT_DEFAULTS) : {}
    end

    # overwritten if `expect_arguments` is called
    def expected_arguments
      [].freeze
    end

    def expect_arguments(*arguments)
      required(*arguments)
      combined = expected_arguments + arguments
      class_eval <<~EVAL
        def self.expected_arguments
          #{combined.inspect}.freeze
        end
      EVAL
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

    def all_callbacks
      const_defined?(:OPT_CALLBACKS) ? const_get(:OPT_CALLBACKS) : {}.freeze
    end

    def shareable?
      const_defined?(:SHAREABLE) && const_get(:SHAREABLE)
    end

    def shareable!
      return if shareable?
      const_set(:SHAREABLE, true)
    end

    private

    def share(value)
      return value unless shareable?
      defined?(Ractor) ? Ractor.make_shareable(value) : value
    end

    def add_required_keys(*keys)
      combined = required_keys + keys
      class_eval <<~RUBY
        def self.required_keys
          #{combined.inspect}.freeze
        end
      RUBY
    end

    def add_defaults(defaults_to_add)
      freezer = defaults.dup
      defaults_to_add.each { |k, v| freezer[k] = share(v) }
      remove_const(:OPT_DEFAULTS) if const_defined?(:OPT_DEFAULTS)
      const_set(:OPT_DEFAULTS, freezer.freeze)
    end

    def add_callback(name, callback)
      if const_defined?(:OPT_CALLBACKS)
        callbacks_for_name = (all_callbacks[name] || []) + [callback]
        callbacks_hash = all_callbacks.merge(name => callbacks_for_name).freeze
        remove_const(:OPT_CALLBACKS)
        const_set(:OPT_CALLBACKS, callbacks_hash)
      else
        const_set(:OPT_CALLBACKS, { name => [ callback ] })
      end
    end

    def opt_struct_class_constants
      [:OPT_DEFAULTS, :OPT_CALLBACKS]
    end

    def check_reserved_words(words)
      Array(words).each do |word|
        if OptStruct::RESERVED_WORDS.member?(word)
          raise ArgumentError, "Use of reserved word is not permitted: #{word.inspect}"
        end
      end
    end
  end
end
