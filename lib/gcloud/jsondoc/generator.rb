require "json"
require "jbuilder"
require "gcloud/jsondoc/doc"
require "gcloud/jsondoc/generated_toc_doc"

module Gcloud
  module Jsondoc
    class Generator
      attr_reader :input, :docs, :registry, :types

      ##
      # Creates a new builder to output documentation in JSON
      #
      # @param [YARD::Registry] registry The YARD registry instance containing
      #   the source code objects
      # @param [String, nil] source_path The filesystem path to be used for
      #   source links, instead of the relative execution path. Optional
      # @param [Hash, nil] generate A hash configuration for types that need to
      #   be generated, such as TOCs. Optional
      def initialize registry, source_path = nil, generate: generate
        @registry = registry
        @docs = []
        @types = []
        @source_path = source_path
        @generate = generate
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
        File.write types_path, types_builder.target!
      end

      def build!
        modules = @registry.all(:module).select do |c|
          c.visibility == :public && !c.has_tag?(:private)
        end
        modules.each do |object|
          @docs += Doc.new(object, @source_path).subtree
        end
        set_types
        generate_docs if @generate
        @registry.clear
      end

      protected

      ##
      # Returns a flat list from @docs that can be used to produce `types.json`.
      def set_types
        docs.each do |doc|
          @types += doc.types_subtree
        end
      end

      def generate_docs
        @generate[:types].each do |gtype|
          if gtype[:toc]
            included = @types.each_with_object({}) do |type, memo|
              if Regexp.new(gtype[:toc][:include]).match(type.filepath) &&
                !type.object.docstring.empty?
                memo[type.title] = type.jbuilder.attributes!
              end
            end
            generated_doc = GeneratedTocDoc.new gtype[:title], gtype[:toc][:package], included
            @docs << generated_doc
            @types << generated_doc
          else
            fail "Property :toc not found. Only TOC-type docs are supported."
          end
        end
      end
    end

    class YardSyntaxError < RuntimeError
    end
  end
end
