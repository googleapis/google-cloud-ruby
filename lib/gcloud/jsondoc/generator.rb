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
          @docs << Doc.new(object)
          children = object.children.select { |c| c.type == :class && c.namespace.name == object.name }
          children.each do |child|
            @docs << Doc.new(child)
            grandchildren = child.children.select { |c| c.type == :class && c.namespace.name == child.name }
            grandchildren.each do |child|
              @docs << ChildDoc.new(child)
            end
          end
        end
        @registry.clear
      end
    end
  end
end
