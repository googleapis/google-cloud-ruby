require "gcloud/jsondoc/markup_helper"
require "gcloud/jsondoc/json_helper"
require "gcloud/jsondoc/method"
module Gcloud
  module Jsondoc
    class Doc
      include Gcloud::Jsondoc::MarkupHelper, JsonHelper

      # object is API defined by YARD's HtmlHelper
      attr_reader :name, :full_name, :filepath, :jbuilder, :object, :subtree

      def initialize object
        @object = object
        @name = object.name.to_s
        @full_name = get_full_name #JsonHelper
        @filepath = "#{@full_name}.json"
        build!
        build_subtree!
      end

      def build!
        @jbuilder = Jbuilder.new do |json|
          metadata json
          methods json, object
        end
      end

      def build_subtree!
        @subtree = [self]
        children = @object.children.select { |c| c.type == :class && c.visibility == :public && c.namespace.name == @object.name && !c.has_tag?(:private) }
        children.each do |child|
          @subtree += Doc.new(child).subtree
        end
      end

      protected

      def methods json, object
        methods = object.children.select { |c| c.type == :method && c.visibility == :public && !c.is_alias? && !c.has_tag?(:private) } # TODO: handle aliases
        json.methods methods do |method|
          Method.new(json, method).build!
        end
      end
    end
  end
end
