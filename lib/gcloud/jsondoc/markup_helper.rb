require "kramdown"
require "yard"

module Gcloud
  module Jsondoc
    module MarkupHelper
      # Provides resolve_links
      include YARD::Templates::Helpers::HtmlHelper

      def md s, multi_paragraph = false
        html = Kramdown::Document.new(s.to_s, input: "GFM", hard_wrap: false,
                                       syntax_highlighter: "rouge",
                                       syntax_highlighter_opts: {css_class: "ruby"}).to_html.strip
        html = remove_line_breaks(html)
        html = unwrap_paragraph(html) unless multi_paragraph
        html = resolve_links(html) if html # in YARD's HtmlHelper
        html
      end

      def remove_line_breaks html
        html.gsub("\n", " ")
      end

      def unwrap_paragraph html
        match = Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(html)
        match[1] if match
      end

      # API expected by HtmlHelper; overrides BaseHelper#linkify (not included)
      def linkify(name, title)
        code_obj = YARD::Registry.resolve object.namespace, name, true
        path = if code_obj.nil?
                 name
               else
                 parts = code_obj.path.split "::"
                 parts.shift if parts.first == "Gcloud"
                 parts.map(&:downcase).join("/")
               end
        "<a data-custom-type=\"#{path}\">#{title || name}</a>"
      end
    end
  end
end
