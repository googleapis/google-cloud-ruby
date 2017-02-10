module IncludedModule
  ##
  # When mode is +TRANSACTIONAL+, mutations affecting a single entity are
  # applied in order. The following sequences of mutations affecting a single
  # entity are not permitted in a single +Commit+ request.
  class ClassA
  end

  ##
  # Entities not found as +ResultType.KEY_ONLY+ entities. The order of results
  # in this field is undefined and has no relation to the order of the keys
  # in the input.
  class ClassB
  end
end
