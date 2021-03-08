def init
  @object = options.item
  @methods = @object.children.select { |child| child.type == :method }
  @constants = @object.children.select { |child| child.type == :constant }
  @references = @object.children.reject { |child| [:method, :constant].include? child.type }
  @object_text = ERB.new(File.read"#{__dir__}/_object.erb").result binding

  @method_text = @methods.map { |method|
    @method = method
    ERB.new(File.read"#{__dir__}/_method.erb").result binding
  }.join("\n")

  @constant_text = @constants.map { |constant|
    @constant = constant
    ERB.new(File.read"#{__dir__}/_constant.erb").result binding
  }.join("\n")

  if @references.empty?
    @reference_text = "[]"
  else
    @reference_text = "\n" + @references.map { |reference|
      @reference = reference
      ERB.new(File.read "#{__dir__}/_reference.erb").result binding
    }.join("\n")
  end

  sections :layout
end

def children
  if !@object.children || @object.children.empty?
    "[]"
  else
    out = "\n"
    out += @object.children.map { |child|
      "      - #{child.path}"
    }.join("\n")
    out
  end
end

def docstring obj
  obj.docstring.to_str.chomp.sub("--- ", "").sub("|-\n", "").gsub '"', "'"
end
