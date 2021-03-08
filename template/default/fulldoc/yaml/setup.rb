def init
  options.serializer = Serializers::FileSystemSerializer.new :extension => "yaml"
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
end

def serialize(object)
  file_name = "#{object.path.gsub "::", "-"}.yaml"

  Templates::Engine.with_serializer(file_name, options.serializer) do
    T('layout').run(options.merge(:item => object))
  end
end

def serialize_index(options)
  return
  Templates::Engine.with_serializer('index.yaml', options.serializer) do
    T('layout').run(options.merge(:index => true))
  end
end
