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

module YARD
  module Gcloud
    module SideNav
      def sidenav
        buffer = []

        buffer << '<div class="side-nav--meta"><div id="doc-build-date">Docs built on '
        buffer << Date.today.strftime("%b %d, %Y")
        buffer << '.</div></div>'
        buffer << '<ul><h4 class="list-item--heading">Getting Started</h4>'
        buffer << list_item(url_for("index.html"), "Overview", css_current: (options.file == options.readme))

        config["pages"].each do |side|
          page = options.files.find { |f| f.title == side["full_name"] }

          if page && side["ignore"] != true
            buffer << list_item(url_for("#{page.name}.html"), side["name"],
                                        css_current: (options.file == page))
          end
        end

        # Now for the files that aren't in the config
        other_pages = options.files.reject do |page|
          config["pages"].find { |p| p["full_name"] == page.title }
        end.each do |page|
          buffer << list_item(url_for("#{page.name}.html"), page.title,
                                      css_current: (options.file == page))
        end
        buffer << '</ul>'

        buffer << '<ul><h4 class="list-item--heading">API</h4>'
        config["classes"].each do |side|
          klass = options.objects.find { |k| k.path == side["full_name"] }
          if klass
            buffer << list_item(url_for(klass), side["name"],
                                css_current: (self.object.path == side["full_name"]))

            if self.object.path.start_with? side["full_name"]
              Array(side["classes"]).each do |sub|
                sub_klass = options.objects.find { |k| k.path == sub["full_name"] }
                if sub_klass
                  buffer << list_item(url_for(sub_klass), sub["name"],
                                      css_class: "toc-l1",
                                      css_current: (self.object.path == sub["full_name"]))
                end
              end
            end
          end
        end
        buffer << list_item(url_for("reference.html"), "API Reference",
                            css_current: (options.file.nil? && YARD::CodeObjects::RootObject === self.object))
        buffer << '</ul>'

        buffer.join ""
      end

      def config
        @config ||= begin
          config_file = File.dirname(File.expand_path(__FILE__)) + "/../../config/side.yaml"
          config_yaml = File.open config_file
          YAML::load config_yaml
        end
      end

      def list_item path, text, css_current: false, css_class: "toc-l0"
        current_class = (self.object.path == path) ? " current" : ""
        current_class = " current" if css_current
        "<li class='#{css_class}'><a class='reference internal#{current_class}' href='#{path}'>#{text}</a></li>"
      end
    end
  end
end
