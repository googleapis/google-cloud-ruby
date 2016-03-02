require "jbuilder"
require "gcloud/jsondoc/doc"
require "gcloud/jsondoc/child_doc"

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
        build
        docs.each do |doc|
          json = doc.jbuilder.target!
          json_path = Pathname.new(base_path).join doc.filepath
          puts json_path.to_path
          FileUtils.mkdir_p(json_path.dirname)
          File.write json_path.to_path, json
        end
      end

      protected

      def build
        modules = @registry.all(:module)
        modules.each do |object|
          @docs += Doc.new(object).subtree
        end
        @registry.clear
      end
    end
  end
end
