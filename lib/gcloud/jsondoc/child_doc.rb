module Gcloud
  module Jsondoc
    # Not currently used in JSON. Future JSON output may just use directory tree and
    # not require hyphenation for a workaround.
    class ChildDoc < Doc

      def filepath # bigquery/table-list.json
        "#{@object.namespace.namespace.name.to_s.downcase}/#{@object.namespace.name.to_s.downcase}-#{@name}.json"
      end

      def build
        @jbuilder = Jbuilder.new do |json|
          json.id "#{object.namespace.name.to_s.downcase}-#{object.name.to_s.downcase}"
          metadata json
          methods json, object
        end
      end

      def metadata json
        json.metadata do
          json.name "#{object.namespace.name}::#{object.name}"
          json.description md(object.docstring.to_s, true)
          json.source object.files.first.join("#L")
          json.resources object.docstring.tags(:see) do |t|
            json.href t.name
            json.title md(t.text)
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
