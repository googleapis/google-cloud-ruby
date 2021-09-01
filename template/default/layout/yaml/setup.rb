require_relative "./format.rb"
require_relative "./method.rb"

def init
  @object = options.item
  @method_list = object_methods @object
  @constants = @object.children.select { |child| child.type == :constant }.sort_by { |child| child.path }
  @references = @object.children.reject { |child| [:method, :constant].include? child.type }
  @references.reject! do |ref| 
    ref.visibility == :private || ref.tags.any? { |tag| tag.tag_name == "private" }
  end
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
    @reference_text = "references: []"
  else
    @reference_text = "references:\n" + @references.map { |reference|
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
  @children_list += @object.children.reject { |child| :method == child.type }
  @children_list.reject! do |child| 
    child.visibility == :private || child.tags.any? { |tag| tag.tag_name == "private" }
  end
  @children_list
end

def children_text
  if children_list.empty?
    "[]"
  else
    out = "\n"
    out += children_list.map { |child|
      if child.type == :method
        child.path.include?("#") ? "  - #{child.path}(instance)" : "  - #{child.path}(class)"
      else
        "  - #{child.path}"
      end
    }.join("\n")
    out
  end
end

def includes_text
  return "" if @object.mixins.empty?

  text = @object.mixins.map do |mix| 
    url = "./#{mix.path.gsub("::", "-")}"
    "  - \"#{link url, mix.name.to_s}\""
  end
  text.unshift "  includes:"
  text.join "\n"
end

def inheritance_text
  text = []
  if @object.respond_to? "superclass"
    text << "inherits:"
    text << "- \"#{link_objects @object.superclass.path}\""
  end
  
  if (extended_by = run_verifier object.mixins(:class)).size > 0
    text << "extendedBy:"
    text += extended_by.map { |obj| "- \"#{link_objects obj.path}\"" }.sort
  end

  if (includes = run_verifier object.mixins(:instance)).size > 0
    text << "includes:"
    text += includes.map { |obj| "- \"#{link_objects obj.path}\"" }.sort
  end

  if (mixed_into = mixed_into(object)).size > 0
    text << "includedIn:"
    text += mixed_into.map { |obj| "- \"#{link_objects obj.path}\"" }.sort
  end
  return "" if text.size == 1
  text.map { |line| "  #{line}" }.join "\n"
end


def mixed_into object
  # stolen from https://github.com/lsegal/yard
  unless globals.mixed_into
    globals.mixed_into = {}
    list = run_verifier Registry.all(:class, :module)
    list.each {|o| o.mixins.each {|m| (globals.mixed_into[m.path] ||= []) << o } }
  end

  globals.mixed_into[object.path] || []
end

def constant_summary
  text = "<b>value: </b>#{pre_format @constant.value}"
  if @constant.docstring.size > 0
    text += "<br>"
    text += pre_format @constant.docstring
  end
  text
end
