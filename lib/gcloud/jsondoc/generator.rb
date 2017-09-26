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
      def initialize registry, source_path = nil, generate: nil
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
          fp = json_path.to_path
          unless doc.title == "Google::Cloud::Videointelligence"
            puts fp
            FileUtils.mkdir_p(json_path.dirname)
            File.write fp, json
          end
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
        @generate[:documents].each do |g_config|
          unless g_config[:type] == "toc"
            fail "documents type 'toc' not found. Only TOC-type docs are currently supported."
          end

          modules = g_config[:modules].map do |m|
            # There appears to be an issue with duplicates, so create a hash to
            # ensure only one type for each id is returned.
            matched_types = @docs.each_with_object({}) do |doc, memo|
              if matching_type? doc, m[:include], m[:exclude]
                json = doc.jbuilder.attributes!
                memo[json["id"]] = OpenStruct.new(
                  id: json["id"],
                  name: doc.title,
                  description: short_description(json["description"])
                )
              end
            end
            OpenStruct.new title: m[:title], types: matched_types.values.sort_by(&:name)
          end
          generated_doc = GeneratedTocDoc.new g_config[:title], modules
          @docs << generated_doc
          @types << generated_doc
        end
      end

      def matching_type? type, include_patterns, exclude_patterns
        type.object &&
          !type.object.docstring.empty? &&
          include_type?(type, include_patterns) &&
          !include_type?(type, exclude_patterns)
      end
      def include_type? type, patterns
        return false unless patterns
        patterns.detect do |pattern|
          Regexp.new(pattern).match(type.filepath)
        end
      end

      def short_description description
        result = description.split(/\.(?=[\W])/)
        description = result[0] + "." if result.size > 1
        description
      end
    end

    class YardSyntaxError < RuntimeError
    end
  end
end
