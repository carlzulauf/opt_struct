require "opt_struct/class_methods"
require "opt_struct/instance_methods"

module OptStruct
  def self.inject_struct(target_klass, &more_block)
    target_klass.instance_exec do
      extend ClassMethods
      attr_reader :options
      include InstanceMethods
    end
    target_klass.instance_exec(&more_block) if block_given?
    target_klass
  end

  def self.included(klass)
    inject_struct(klass)
  end

  def self.new(*args, **defaults)
    check_for_invalid_args(args)
    args.map!(&:to_sym)
    inject_struct(Class.new) do
      expect_arguments *args
      options defaults
    end
  end

  def self.build(*args, **defaults)
    check_for_invalid_args(args)
    args.map!(&:to_sym)
    Module.new do
      @arguments = args
      @defaults = defaults

      def self.included(klass)
        arguments, defaults = @arguments, @defaults
        OptStruct.inject_struct(klass) do
          expect_arguments *arguments
          options defaults
        end
      end
    end
  end

  private

  def self.check_for_invalid_args(args)

  end
end
