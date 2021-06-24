def init
  roots = options.item
  text = []
  roots.each do |root|
    populate_items root, text
  end
  @text = text
  sections :toc
end

def populate_items obj, text, indent = "    "
  text << "#{indent}- uid: #{obj.path}"
  text << "#{indent}  name: #{obj.name}"
  children = obj.children.reject { |child| [:method, :constant].include? child.type }
  unless children.empty?
    text << "#{indent}  items:"
    children.each do |child|
      populate_items child, text, "#{indent}  "
    end
  end
end
