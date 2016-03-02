require "gcloud/jsondoc/markup_helper"
require "gcloud/jsondoc/json_helper"
require "gcloud/jsondoc/method"
module Gcloud
  module Jsondoc
    class Doc
      include Gcloud::Jsondoc::MarkupHelper, JsonHelper

      # object is API defined by YARD's HtmlHelper
      attr_reader :name, :jbuilder, :object

      def initialize object
        @object = object
        @name = @object.name.to_s.downcase
        build
      end

      def filepath
        namespaces = @object.title.split("::")
        namespaces.shift if namespaces.size > 2 # remove "GCloud", since problematic in site app nav
        title_path = namespaces.map(&:downcase).join("/")
        "#{title_path}.json"
      end

      def build
        @jbuilder = Jbuilder.new do |json|
          json.id object.name.to_s.downcase
          metadata json
          methods json, object
        end
      end

      def subtree
        docs = [self]
        children = @object.children.select { |c| c.type == :class && c.visibility == :public && c.namespace.name == @object.name && !c.has_tag?(:private) }
        children.each do |child|
          docs += Doc.new(child).subtree
        end
        docs
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
