# The very first method that runs in the template folder
def init
  options.serializer = Serializers::FileSystemSerializer.new :extension => "yml"
  toc_items = []
  # yard populates options.objects w/ all classes & modules and also yardoc root
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

  # runs the init method in layout/yaml/setup.rb
  Templates::Engine.with_serializer file_name, options.serializer do
    T('layout').run options.merge(:item => object)
  end
end

def copy_files
  # copy markdown files into the yard output folder
  options.files.each do |file|
    dest_filename = file.path == "README" ? "index.md" : file.filename
    File.open "#{options.serializer.basepath}/#{dest_filename}", "w" do |dest|
      in_code_state = 0
      File.readlines(file.filename).each do |line|
        case in_code_state
        when 0
          if line.strip == "```ruby"
            in_code_state = 1
            next
          end
        when 1
          line = "<pre class=\"prettyprint lang-rb\">#{line}"
          in_code_state = 2
        when 2
          if line.strip == "```"
            in_code_state = 0
            line = "</pre>\n"
          end
        end
        dest.puts line
      end
    end
  end
end

def toc objects
  # runs the init method in toc/yaml/setup.rb
  Templates::Engine.with_serializer "toc.yml", options.serializer do
    T('toc').run options.merge(:item => objects)
  end
end
