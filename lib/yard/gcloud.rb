require "yard/gcloud/version"
require "yard"
require "redcarpet"

module YARD
  module Gcloud
  end
end

require "yard/templates/helpers/html_helper"

module YARD
  module Templates
    module Helpers
      module HtmlHelper
        alias_method :_pre_gcloud_html_markup_markdown, :html_markup_markdown
        def html_markup_markdown(text)
          provider = markup_class(:markdown)
          # Add GFM using Kramdown...
          if provider.to_s == "Kramdown::Document"
            provider.new(text, input: "GFM", hard_wrap: false,
                               syntax_highlighter: "rouge",
                               syntax_highlighter_opts: {css_class: "ruby"}).to_html
          else
            # Call the original method...
             _pre_gcloud_html_markup_markdown(text)
          end
        end
      end
    end
  end
end

YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + "/../../templates"
