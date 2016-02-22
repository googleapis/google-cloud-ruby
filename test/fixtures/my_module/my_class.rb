module MyModule
  ##
  # You can use MyClass for almost anything.
  class MyClass
    # @private This method should not appear in the output.
    def my_hidden_method
    end

    ##
    # Accepts many arguments for testing this library. Has no relation to
    # {#other_instance_method}. Also accepts a block if a block is given.
    #
    # Do not call this method until you have read all of its documentation.
    #
    # @see http://ruby-doc.org/core-2.2.0/Proc.html Proc objects are blocks of
    #   code that have been bound to a set of local variables.
    #
    # @param [String] policy A *policy* is a deliberate system of principles to
    #   guide decisions and achieve rational outcomes.  As defined in
    #   [policy](https://en.wikipedia.org/wiki/Policy).
    # @param [Hash] opts Optional parameters hash, not to be confused with
    #   keyword arguments.
    # @option opts [String] :subject The subject
    # @option opts [String] :body ('') The body
    #
    # @param [Integer] times a keyword argument for how many times
    # @param [String] prefix a keyword argument for the prefix
    #
    # @yield An optional block for setting configuration.
    # @yieldparam [MyConfig] c A new instance of MyConfig. See
    #   [configuration](https://en.wikipedia.org/wiki/Configuration_management)
    #   for more info.
    # @yieldreturn [Boolean] Whether the configuration should be applied
    #   immediately or saved for later.
    #
    # @return [Array<(Boolean, MyConfig)>, nil] An array containing the return
    #   value from the block and the block MyConfig argument, or nil if no
    #   block was given.
    #
    # @example You can pass a block.
    #   my_class = MyClass.new
    #   my_class.example_instance_method times: 5 do |my_config|
    #     my_config.limit = 5
    #     true
    #   end
    #
    # @example Or you can just pass simple arguments.
    #   my_class.example_instance_method {subject: "world"}, prefix: "hello"
    #
    def example_instance_method policy = "ALWAYS", opts = {}, times: 10, prefix: nil
      if block_given?
        my_config = MyConfig.new
        immediate = yield my_config
        [immediate, my_config]
      end
    end
    alias_method :alias_instance_method, :example_instance_method

    ##
    # Returns length of `str.to_s`.
    #
    # @param [String, Object] str any value
    #
    # @return [Integer] the length of the string from `to_s`
    #
    def other_instance_method str
      str.to_s.length
    end

    protected

    # A protected method should not appear in the output.
    class ProtectedClass
    end

    # A protected method should not appear in the output.
    def my_protected_method
    end
  end

  class MyConfig
    ##
    #
    attr_accessor :limit
  end
end
