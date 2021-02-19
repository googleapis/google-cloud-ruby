def init
  @object = options.item
  @methods = @object.children.select { |child| child.type == :method }
  @constants = @object.children.select { |child| child.type == :constant }
  @references = @object.children.reject { |child| [:method, :constant].include? child.type }
  @object_text = ERB.new(File.read"#{__dir__}/_object.erb").result(binding)

  @method_text = @methods.map { |method|
    ERB.new(File.read"#{__dir__}/_method.erb").result_with_hash :method => method
  }.join("\n")

  @constant_text = @constants.map { |constant|
    ERB.new(File.read"#{__dir__}/_constant.erb").result_with_hash :constant => constant
  }.join("\n")

  if @references.empty?
    @reference_text = "[]"
  else
    @reference_text = @references.map { |reference|
      ERB.new(File.read "#{__dir__}/_reference.erb").result_with_hash :reference => reference
    }.join("\n")
  end

  sections :layout
end
