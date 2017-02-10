require "gcloud/jsondoc/markup_helper"
require "gcloud/jsondoc/json_helper"
require "gcloud/jsondoc/method"
require "erb"

module Gcloud
  module Jsondoc
    class GeneratedTocDoc < Doc
      include Gcloud::Jsondoc::MarkupHelper, JsonHelper

      # object is API defined by YARD's HtmlHelper
      attr_reader :name, :title, :full_name, :filepath, :jbuilder, :object,
                  :methods, :subtree, :descendants, :types, :types_subtree,
                  :source_path

      def initialize title, modules
        @name = title.split("::").last
        @title = title
        @full_name = @title.gsub("::", "/").downcase
        @filepath = "#{@full_name}.json"
        @source_path = source_path
        @subtree = [self]
        @descendants = []
        @types = [self]
        @types_subtree = @types
        @source_path = ""
        @modules = modules
        build!
      end

      def build!
        @jbuilder = Jbuilder.new do |json|
          json.id @full_name
          json.name @name
          json.title @title.split "::"
          json.description ERB.new(description_template, nil, '-').result(binding)
          json.source ""
          json.resources []
          json.examples []
          json.methods []
        end
      end

      protected

      def description_template
<<EOT
<% @modules.each do |m| -%>
<h4><%= m.title %></h4>

<table class="table">
  <thead>
    <tr>
      <th>Class</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
<% m.types.each do |t| %>
    <tr>
      <td><a data-custom-type="<%= t.id %>"><%= t.name %></a></td>
      <td><%= unwrap_paragraph t.description %></td>
    </tr>
<% end %>
  </tbody>
</table>
<% end %>
EOT
      end
    end
  end
end
