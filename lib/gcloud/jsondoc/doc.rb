require "gcloud/jsondoc/markup_helper"
require "gcloud/jsondoc/json_helper"
require "gcloud/jsondoc/method"
module Gcloud
  module Jsondoc
    class Doc
      include Gcloud::Jsondoc::MarkupHelper, JsonHelper

      # object is API defined by YARD's HtmlHelper
      attr_reader :name, :title, :full_name, :filepath, :jbuilder, :object,
                  :methods, :subtree, :descendants, :types, :types_subtree,
                  :source_path

      def initialize object, source_path
        @object = object
        @name = object.name.to_s
        @title = object.title
        @full_name = get_full_name #JsonHelper
        @filepath = "#{@full_name}.json"
        @source_path = source_path
        set_methods
        build!
        set_children
        set_descendants
        set_subtree
        set_types
        set_types_subtree
      end

      def build!
        @jbuilder = Jbuilder.new do |json|
          json.id @full_name
          metadata json
          json.methods @methods do |m|
            m.build json
          end
        end
      end

      protected

      def set_methods
        method_objects = @object.children.select do |c|
          c.type == :method &&
            c.visibility == :public &&
            !c.is_alias? &&
            !c.has_tag?(:private)
            # TODO: handle aliases
        end
        @methods = method_objects.map { |mo| Method.new mo, self, source_path }
      end

      def set_children
        @children = @object.children.select do |c|
          (c.type == :class || c.type == :module) &&
            c.visibility == :public &&
            c.namespace.name == @object.name &&
            !c.has_tag?(:private)
        end
      end

      def set_descendants
        @descendants = []
        @children.each do |child|
          @descendants += Doc.new(child, source_path).subtree
        end
      end

      def set_subtree
        @subtree = [self] + @descendants
      end

      def set_types
        @types = [self] + @methods
      end

      ##
      # Includes docs and their methods
      def set_types_subtree
        @types_subtree = @types
        @descendants.each do |descendant|
          @types_subtree += descendant.types
        end
      end
    end
  end
end
