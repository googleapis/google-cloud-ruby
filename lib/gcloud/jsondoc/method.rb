require "gcloud/jsondoc/markup_helper"
require "gcloud/jsondoc/json_helper"
module Gcloud
  module Jsondoc
    class Method
      include MarkupHelper, JsonHelper

      # object is API defined by YARD's HtmlHelper
      attr_reader :json, :object

      def initialize json, object
        @json = json
        @object = object
      end

      def build!
        metadata json
        options = object.docstring.tags(:option)
        # merge options into parent params
        params = object.docstring.tags(:param).inject([]) do |memo, param_tag|
          memo << param_tag
          options_tags = options.select { |t| t.name == param_tag.name }
          memo += options_tags unless options_tags.empty?
          memo
        end
        if block = object.docstring.tag(:yield)
          block_params = object.docstring.tags :yieldparam
          block_params.unshift block
          params += block_params
        end
        json.params params do |param|
          param json, object, param
        end
        json.exceptions object.docstring.tags(:raise) do |t|
          json.type t.type
          json.description md(t.text)
        end
        json.returns object.docstring.tags(:return) do |t|
          json.types format_types(t.types)
          json.description md(t.text)
        end
      end

      protected

      # Formats a list of types from a tag.
      #
      # @param [Array<String>, FalseClass] typelist
      #   the list of types to be formatted.
      #
      # @param [Boolean] brackets omits the surrounding
      #   brackets if +brackets+ is set to +false+.
      #
      # @return [String] the list of types formatted
      #   as [Type1, Type2, ...] with the types linked
      #   to their respective descriptions.
      #
      def format_types(typelist, brackets = true)
        return unless typelist.is_a?(Array)
        typelist.map do |type|
          type = type.gsub(/([<>])/) { h($1) }
          type.gsub(/([\w:]+)/) { $1 == "lt" || $1 == "gt" ? $1 : linkify($1, $1) }
        end
      end

      def param json, method, param

        if param.tag_name == "option"
          # #<YARD::Tags::OptionTag:0x007fc78102ad78 @tag_name="option", @text=nil, @name="opts", @types=nil, @pair=#<YARD::Tags::DefaultTag:0x007fc78102bd40 @tag_name="option", @text="The subject", @name=":subject", @types=["String"], @defaults=nil>, @object=#<yardoc method MyModule::MyClass#example_instance_method>>
          json.name (param.name + param.pair.name).sub(":", ".")
          param = param.pair
        elsif param.tag_name == "yield"
          json.name "yield"
        elsif param.tag_name == "yieldparam"
          json.name "yield.#{param.name}"
        else
          json.name param.name
        end

        if param.tag_name == "yield"
          json.types ["block"]
        else
          json.types param.types
        end
        json.description md(param.text)

        if param.tag_name == "option" || param.tag_name == "yield"
          json.optional true
        elsif param.tag_name == "yieldparam"
          json.optional false
        else
          # extract default value from MethodObject#parameters ⇒ Array<Array(String, String)>
          # keyword argument parameter names contain trailing ":" in MethodObject#parameters, but not in Tag
          method_param_pair = method.parameters.find { |p| p[0].sub(/:\z/, "") == param.name.to_s }
          fail "no entry found for @param: '#{param.name}' in MethodObject#parameters: #{method.inspect}" unless method_param_pair
          default_value = method_param_pair[1]
          json.optional !default_value.nil?
        end

        json.default default_value if default_value
        json.nullable(default_value == "nil" || (!param.types.nil? && param.types.include?("nil")))
        # json.defaults param.defaults TODO: add default value to spec and impl
      end
    end
  end
end
