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
        if code_obj.nil?
          name
        else
          parts = code_obj.path.split "::"

          # adhere to gcloud-common site's path pattern of top-level
          # services, e.g. "/bigquery/table"
          # except for special-case "/gcloud" service,
          # and for non-service classes in the top-level Gcloud namespace (Backoff, etc)
          if parts.first == "Gcloud" &&
            parts.size > 1 &&   # "Gcloud" alone means Gcloud module and is ok
            (parts.size != 2 || object.type == :class) # non-service types in Gcloud namespace need to retain "gcloud" in path to be found dynamically
            parts.shift
          end

          path = parts.map(&:downcase).join("/")
          "<a data-custom-type=\"#{path}\">#{title || name}</a>"
        end
      end
    end
  end
end
