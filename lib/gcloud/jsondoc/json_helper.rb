module Gcloud
  module Jsondoc
    module JsonHelper
      # object is API defined by YARD's HtmlHelper, so depend on it here too
      def metadata json
        json.id get_full_name
        json.name object.name.to_s
        json.title object.title.split("::") # Array of namespaces + name
        json.description md(object.docstring, true)
        json.source object.files.first.join("#L")

        if object.type == :method
          if object.constructor?
            json.type "constructor"
          else
            json.type object.scope.to_s
          end
        end

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
        object.title.split("::").map(&:downcase).join("/")
      end
    end
  end
end
