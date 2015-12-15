require "yaml"
include Helpers::ModuleHelper

def init
  # Render each class/module page
  options.objects.each do |object|
    Templates::Engine.with_serializer(object, options.serializer) do
      options.object = object
      T('class').run(options)
    end
  end

  # Render api reference page
  Templates::Engine.with_serializer("reference.html", options.serializer) do
    T('reference').run(options)
  end

  # Render main index.html page
  Templates::Engine.with_serializer("index.html", options.serializer) do
    options.readme.attributes[:markup] ||= markup_for_file("", options.readme.filename)
    options.file = options.readme
    T('home').run(options)
  end
  options.delete :file

  # Render each extra file page
  options.files.each do |file|
    file.attributes[:markup] ||= markup_for_file("", file.filename)
    Templates::Engine.with_serializer("#{file.name}.html", options.serializer) do
      options.file = file
      T('file').run(options)
    end
    options.delete :file
  end

  # Render all the assets
end
