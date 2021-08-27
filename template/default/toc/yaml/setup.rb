def init
  @roots = options.item
  sections :toc
end

def objects
  return @objects_list if @objects_list

  @objects_list = []
  @roots.each do |root|
    populate_objects root
  end
  @objects_list.uniq!
  @objects_list.sort_by! { |obj| obj.path }
  @objects_list
end

def populate_objects obj
  objects << obj
  children = obj.children.reject { |child| [:method, :constant].include? child.type }
  unless children.empty?
    children.each do |child|
      populate_objects child
    end
  end
end

def toc_text
  text = []
  objects.each do |obj|
    text << "  - uid: #{obj.path}"
    text << "    name: #{obj.path}"
  end
  text.join "\n"
end
