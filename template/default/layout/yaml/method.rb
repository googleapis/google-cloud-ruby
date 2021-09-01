def object_methods object = nil
  object ||= @object
  method_list = object.children.select { |child| child.type == :method }
  method_list.reject! do |method| 
    method.visibility == :private || method.tags.any? { |tag| tag.tag_name == "private" }
  end
  dot_methods = []
  instance_methods = []
  method_list.each do |method|
    if method.path.include? "#"
      instance_methods << method
    else
      dot_methods << method
    end
  end
  method_list = dot_methods.sort_by { |method| method.path }
  method_list += instance_methods.sort_by { |method| method.path }
  method_list
end

def method_id
  @method.path
end

def method_signature
  sign = @method.path[@method.path.size - @method.name.to_s.size - 1]
  text = ""
  yield_params = @method.tags.select { |tag| tag.tag_name == "yieldparam" }
  overloads = @method.tags.select { |tag| tag.tag_name == "overload" }
  returns = @method.tags.select { |tag| tag.tag_name == "return" }
  return_types = returns.map { |entry| entry.types }.flatten.uniq
  return_text = ""

  unless return_types.empty?
    return_text += " => "
    return_text += return_types.join ", "
  end

  block_text = ""

  unless yield_params.empty?
    block_text += " { |#{yield_params.map(&:name).join ", "}"
    block_text += "| ... }"
  end
  
  if overloads.empty?
    text += "def "
    text += "self." if sign == "."
    text += @method.name.to_s
    unless @method.parameters.empty?
      text += "("
      params = @method.parameters.map do |param|
        entry = param[0]
        if param[1]
          if entry.end_with? ":"
            entry += " #{escapes param[1]}"
          else
            entry += " = #{escapes param[1]}"
          end
        end
        entry
      end
      text += params.join ", "
      text += ")"
    end
    text += block_text
    text += return_text
  else
    overload_sig = overloads.map do |overload|
      head = "def "
      head += "self." if sign == "."
      "#{head}#{overload.signature}#{return_text}"
    end
    text += overload_sig.join "\\n"
  end
  text
end

def param_text
  text = []
  overloads = @method.tags.select { |tag| tag.tag_name == "overload" }
  if overloads.empty?
    params = @method.tags.select { |tag| tag.tag_name == "param" }
    text << arg_text(@method, params, "    ")
  else
    text << "    overloads:"
    overloads.each do |overload|
      text << "    - content: \"#{method_signature.split("\\n").select { |sig| sig.include? overload.signature }.first}\""
      text << "      description: \"#{pre_format overload.docstring}\"" unless overload.docstring.empty?
      text << "      example: #{example_text overload, "    "}"
      params = overload.tags.select { |tag| tag.tag_name == "param" }
      text << arg_text(@method, params, "      ")
    end
  end

  text.join("\n")
end

def arg_text method, params, indent
  return "#{indent}arguments: []" if params.empty?

  text = ["arguments:"]
  params.each do |arg|
    entry = "- description: \"#{bold arg.name}"
    types = arg.types.map { |type| link_objects type }
    entry += " (#{types.join ", "})" unless types.empty?
    default_value ||= method.parameters.select { |n| n[0] == "#{arg.name}:" }.last
    if default_value && default_value.last
      defaults = "(defaults to: #{default_value.last})"
      entry += " #{italic defaults}"
    end
    entry += " — #{pre_format arg.text}" unless arg.text.nil? || arg.text.empty?
    entry += "\""
    text << entry
  end
  text.map { |line| "#{indent}#{line}" }.join "\n"
end

def example_text item, indent = ""
  text = [""]
  examples = item.tags.select { |tag| tag.tag_name == "example" }
  return "[]" if examples.empty?

  examples.each do |example|
    text << "- \"#{codeblock escapes(example.text)}\""
  end
  text.map { |line| "#{indent}#{line}" }.join "\n"
end

def yield_text
  yield_tags = @method.tags.select { |tag| tag.tag_name == "yield" }
  return "    yields: []" if yield_tags.empty?

  text = ["yields:"]
  yield_tags.each do |tag|
    text << tag_content(tag)
  end

  text.map { |line| line = "    #{line}" }.join("\n")
end

def yield_param_text
  yield_params = @method.tags.select { |tag| tag.tag_name == "yieldparam" }
  return "    yieldparams: []" if yield_params.empty?
  
  text = ["yieldparams:"]
  yield_params.each do |tag|
    text << tag_content(tag)
  end
  text.map { |line| line = "    #{line}" }.join("\n")
end

def return_text
  return_tags = @method.tags.select { |tag| tag.tag_name == "return" }
  return "    returnValues: []" if return_tags.empty?

  text = ["returnValues:"]
  return_tags.each do |tag|
    text << tag_content(tag)
  end

  text.map { |line| line = "    #{line}" }.join("\n")
end

def raise_text
  raise_tags = @method.tags.select { |tag| tag.tag_name == "raise" }
  return "    raises: []" if raise_tags.empty?

  text = ["raises:"]
  raise_tags.each do |tag|
    text << tag_content(tag)
  end

  text.map { |line| line = "    #{line}" }.join("\n")
end

def tag_content tag
  types = tag.types.map { |type| link_objects type }
  entry = "- description: \""
  entry += "#{bold tag.name} " if tag.name && !tag.name.empty?
  entry += "(#{types.join ", "})" unless types.empty?
  entry += " — #{pre_format tag.text}" unless tag.text.empty?
  entry += "\""
  entry
end

def bold text
  "<strong>#{text}</strong>"
end

def italic text
  "<em>#{text}</em>"
end
