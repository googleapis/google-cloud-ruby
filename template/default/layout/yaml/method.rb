def object_methods object = nil
  object ||= @object
  method_list = object.children.select { |child| child.type == :method }
  method_list.reject! do |method| 
    method.visibility == :private || method.tags.any? { |tag| tag.tag_name == "private" }
  end
  method_list
end

def method_id
  @method.path
end

def method_signature
  sign = @method.path[@method.path.size - @method.name.to_s.size - 1]
  text = ""
  yield_tags = @method.tags.select { |tag| tag.tag_name == "yield" }
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
    text += sign 
    text += @method.signature[4..-1]
    text += block_text
    text += return_text
  else
    text += overloads.map { |overload| "#{sign}#{overload.signature}#{return_text}" }.join "\\n"
  end
  text
end

def param_text
  text = []
  params.each do |param|
    text << "- id: #{param.name.to_s}"
    text << "  type:"
    param.types.each do |type|
      text << "    - \"#{type}\""
    end
    text << "  description: \"#{pre_format param.text}\"" unless param.text.empty?
  end

  return "        []" if text.empty?
  text.map { |line| line = "        #{line}" }.join("\n")
end

def params
  # p @method.tags.select { |tag| tag.tag_name == "overload" }
  
  @method.tags.select { |tag| tag.tag_name == "param" }
end

def return_text
  text = []
  returns = @method.tags.select { |tag| tag.tag_name == "return" }
  returns.each do |entry|
    text << "  type:"
    entry.types.each do |type|
      text << "    - \"#{type}\""
    end
    text << "  description: \"#{pre_format entry.text}\"" unless entry.text.empty?
  end

  return "        []" if text.empty?
  text.map { |line| line = "        #{line}" }.join("\n")
end
