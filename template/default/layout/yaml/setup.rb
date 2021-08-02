require_relative "./method.rb"
require_relative "./format.rb"

def init
  @object = options.item
  @method_list = object_methods @object

  @constants = @object.children.select { |child| child.type == :constant }
  @references = @object.children.reject { |child| [:method, :constant].include? child.type }
  @children = @constants + @references
  @object_text = ERB.new(File.read"#{__dir__}/_object.erb").result binding

  @method_text = @method_list.map { |method|
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

def object_list
  return @object_list if @object_list

  @object_list = options.objects.reject { |item| item.root? }
  @object_list
end

def full_object_list
  return @full_object_list if @full_object_list

  @full_object_list = []
  object_list.each do |obj|
    @full_object_list += object_methods(obj)
    references = obj.children.reject { |child| [:method, :constant].include? child.type }
    @full_object_list += references
  end
  @full_object_list
end

def children_list
  return @children_list if @children_list

  
  @children_list = object_methods(@object)
  @children_list += @object.children.reject { |child| [:method, :constant].include? child.type }
  @children_list
end


def children_text
  if children_list.empty?
    "[]"
  else
    out = "\n"
    out += children_list.map { |child|
      "      - #{child.path}"
    }.join("\n")
    out
  end
end
