def init
  @objects = options.item
  sections :toc
end

def objects
  return @objects_list if @objects_list

  @objects_list = @objects
  @objects_list.uniq!
  @objects_list.sort_by! { |obj| obj.path }
  @objects_list.reject! do |obj|
    obj.visibility == :private || obj.tags.any? { |tag| tag.tag_name == "private" }
  end
  @objects_list
end

def toc_text
  text = []
  objects.each do |obj|
    text << "  - uid: #{obj.path}"
    text << "    name: #{obj.path}"
  end
  text.join "\n"
end
