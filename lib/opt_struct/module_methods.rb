module OptStruct
  module ModuleMethods

    def included(klass)
      OptStruct._inject_struct(klass, self)
      super(klass)
    end

    # These methods are meant to duplicate the macro methods in ClassMethods
    # When they are called in a module the action is deferred by adding a block to the struct chain
    %i(
      required
      option_reader
      option_writer
      option_accessor
      option
      options
      expect_arguments
    ).each do |class_method|
      define_method(class_method) do |*args|
        @_opt_structs << [[], {}, -> { send(class_method, *args) }]
      end
    end
  end
end
