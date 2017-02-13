module IncludedModule
  ##
  # When mode is +TRANSACTIONAL+, mutations affecting a single entity are
  # applied in order. The following sequences of mutations affecting a single
  # entity are not permitted in a single +Commit+ request.
  class ClassA

    ##
    # Returns length of `str.to_s`.
    #
    # @param [Object] items a variable-length argument list
    #
    # @return [Integer] the length of the string from `to_s`
    #
    def an_instance_method *items
      items.length
    end
  end

  ##
  # Entities not found as +ResultType.KEY_ONLY+ entities. The order of results
  # in this field is undefined and has no relation to the order of the keys
  # in the input.
  class ClassB
  end
end
