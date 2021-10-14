def init
  options.serializer = Serializers::FileSystemSerializer.new :extension => "yml"
  toc_items = []
  options.objects.each do |object|
    next if object.root?
    toc_items << object
    serialize object
  end
  copy_files
  toc toc_items
end

def serialize object
  file_name = "#{object.path.gsub "::", "-"}.yml"

  Templates::Engine.with_serializer file_name, options.serializer do
    T('layout').run options.merge(:item => object)
  end
end

def copy_files
  options.files.each do |file|
    if file.path == "README"
      FileUtils.cp file.filename, "#{options.serializer.basepath}/index.md"
    else
      FileUtils.cp file.filename, "#{options.serializer.basepath}/#{file.filename}"
    end
  end
end

def toc objects
  Templates::Engine.with_serializer "toc.yml", options.serializer do
    T('toc').run options.merge(:item => objects)
  end
end
