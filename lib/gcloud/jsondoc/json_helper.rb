module Gcloud
  module Jsondoc
    module JsonHelper
      # object is API defined by YARD's HtmlHelper, so depend on it here too
      def metadata json
        json.name object.name.to_s
        json.title object.title.split("::") # Array of namespaces + name
        json.description md(object.docstring, true)
        json.source object.files.first.join("#L")

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
    end
  end
end
