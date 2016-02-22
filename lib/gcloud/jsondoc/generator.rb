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
        build
      end

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
