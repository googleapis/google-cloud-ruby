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
        downcase_namespace = @object.namespace.name.to_s.downcase
        if downcase_namespace == "root"
          "#{@name}.json"
        else
          "#{downcase_namespace}/#{@name}.json"
        end
      end

      def build
        @jbuilder = Jbuilder.new do |json|
          json.id object.name.to_s.downcase
          metadata json
          methods json, object
        end
      end

      protected

      def methods json, object
        methods = object.children.select { |c| c.type == :method && !c.is_alias? && !c.has_tag?(:private) } # TODO: handle aliases
        json.methods methods do |method|
          Method.new(json, method).build!
        end
      end
    end
  end
end
