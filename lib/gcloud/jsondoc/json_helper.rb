module Gcloud
  module Jsondoc
    module JsonHelper
      # object is API defined by YARD's HtmlHelper, so depend on it here too
      # source_path is available in Doc
      def metadata json
        json.name object.name.to_s
        json.title object.title.split("::") # Array of namespaces + name
        json.description md(object.docstring, true)
        json.source get_source

        json.resources object.docstring.tags(:see) do |t|
          json.title md(t.text)
          json.link t.name
        end
        json.examples object.docstring.tags(:example) do |t|
          json.caption md(t.name, true)
          json.code t.text
        end
      end

      def get_full_name
        object.path.gsub("::", "/").downcase
      end

      protected

      def get_source
        s = object.files.first.join("#L")
        s.prepend "#{source_path}/" if source_path
        s
      end
    end
  end
end
