def init
  options.serializer = Serializers::FileSystemSerializer.new :extension => "yml"
  options.objects.each do |object|
    begin
      next if object.root?
      serialize(object)
    rescue => e
      path = options.serializer.serialized_path(object)
      log.error "Exception occurred while generating '#{path}'"
      log.backtrace(e)
    end
  end
  serialize_index options
  toc
end

def serialize(object)
  file_name = "#{object.path.gsub "::", "-"}.yml"

  Templates::Engine.with_serializer(file_name, options.serializer) do
    T('layout').run(options.merge(:item => object))
  end
end

def serialize_index(options)
  return
  Templates::Engine.with_serializer('index.yml', options.serializer) do
    T('layout').run(options.merge(:index => true))
  end
end

def toc
  roots = []
  options.objects.each do |object|
    next if object.root?
    roots << object if object.parent.root?
  end

  Templates::Engine.with_serializer("toc.yml", options.serializer) do
    T('toc').run(options.merge(:item => roots))
  end
end
