def init
  options.serializer = Serializers::FileSystemSerializer.new :extension => "yml"
  options.objects.each do |object|
    next if object.root?
    serialize object
  end
  copy_files
  toc
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

def toc
  roots = []
  options.objects.each do |object|
    next if object.root?
    roots << object if object.parent.root?
  end

  Templates::Engine.with_serializer "toc.yml", options.serializer do
    T('toc').run options.merge(:item => roots)
  end
end
