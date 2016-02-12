module Gcloud
  module Jsondoc
    module JsonHelper
      # object is API defined by YARD's HtmlHelper, so depend on it here too
      def metadata json
        json.metadata do
          json.name object.name.to_s
          json.description md(object.docstring.to_s, true)
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
      end
    end
  end
end
