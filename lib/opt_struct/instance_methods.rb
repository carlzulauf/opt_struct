module OptStruct
  module InstanceMethods
    def initialize(*arguments, **options)
      with_init_callbacks do
        @options = options
        assign_arguments(arguments)
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
    
    def assign_arguments(args)
      self.class.expected_arguments.map.with_index do |key, i|
        if args.length > i
          options[key] = args[i]
        elsif !options.key?(key)
          if defaults.key?(key)
            options[key] = read_default_value(key)
          else
            raise ArgumentError, "missing required argument: #{key}"
          end
        end
      end
    end
    
    def read_default_value(key)
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
