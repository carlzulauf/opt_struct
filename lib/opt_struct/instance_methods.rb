module OptStruct
  module InstanceMethods
    def initialize(*arguments, **options)
      with_init_callbacks do
        @options = options
        assign_arguments(arguments)
        assign_defaults
        check_required_keys
      end
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

    def assign_defaults
      defaults.each do |key, default_value|
        next if options.key?(key)
        options[key] =
          case default_value
          when Proc
            instance_exec(&default_value)
          when Symbol
            respond_to?(default_value) ? send(default_value) : default_value
          else
            default_value
          end
      end
    end

    def assign_arguments(args)
      self.class.expected_arguments.each_with_index do |key, i|
        options[key] = args[i] if args.length > i
      end
    end

    def with_init_callbacks(&init_block)
      callbacks = self.class.all_callbacks
      return yield if callbacks.nil? || callbacks.empty?

      around, before, after = [:around_init, :before_init, :init].map do |type|
        callbacks.fetch(type) { [] }
      end

      if around.any?
        init = proc { run_befores_and_afters(before, after, &init_block) }
        init = around.reduce(init) do |chain, callback|
          proc { run_callback(callback, &chain) }
        end
        instance_exec(&init)
      else
        run_befores_and_afters(before, after, &init_block)
      end
    end

    def run_befores_and_afters(before, after)
      before.each { |cb| run_callback(cb) }
      yield
      after.each { |cb| run_callback(cb) }
    end

    def run_callback(callback, &to_yield)
      case callback
      when Symbol, String
        send(callback, &to_yield)
      when Proc
        instance_exec(to_yield, &callback)
      end
    end
  end
end
