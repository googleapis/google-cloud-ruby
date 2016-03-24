require "jbuilder"
require "gcloud/jsondoc/doc"

module Gcloud
  module Jsondoc
    class Generator
      attr_reader :input, :docs, :registry

      ##
      # Creates a new builder to output documentation in JSON
      #
      # @param [YARD::Registry] registry The YARD registry instance containing
      #   the source code objects
      def initialize registry
        @registry = registry
        @docs = []
      end

      def write_to base_path
        build!
        docs.each do |doc|
          json = doc.jbuilder.target!
          json_path = Pathname.new(base_path).join doc.filepath
          puts json_path.to_path
          FileUtils.mkdir_p(json_path.dirname)
          File.write json_path.to_path, json
        end
        set_types
        types_builder = Jbuilder.new do |json|
          json.array! @types do |type|
            json.id type.full_name
            json.title type.title
            json.contents type.filepath
          end
        end
        types_path = Pathname.new(base_path).join "types.json"
        puts types_path.to_path
        File.write types_path, types_builder.target!
      end

      def build!
        modules = @registry.all(:module)
        modules.each do |object|
          @docs += Doc.new(object).subtree
        end
        @registry.clear
      end

      ##
      # Returns a flat list from @docs that can be used to produce `types.json`.
      def set_types
        @types = []
        docs.each do |doc|
          @types += doc.types_subtree
        end
      end
    end
  end
end
