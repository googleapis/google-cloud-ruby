module MyModule
  ##
  # @private This class should not appear in the output.
  class HiddenClass
    ##
    # This method should not appear in the output.
    def my_hidden_method
    end
  end
  ##
  # @private This module should not appear in the output.
  module HiddenModule
    ##
    # This method should not appear in the output.
    def self.my_hidden_module_method
    end
  end
end
