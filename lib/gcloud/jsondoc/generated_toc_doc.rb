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

      def initialize title, package, included
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
        @package = package
        @included = included
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
<p>The <code><%= @package %></code> module provides the following types:</p>

<table class="table">
  <thead>
    <tr>
      <th>Class</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
<% @included.each_pair do |k,v| %>
    <tr>
      <td><a data-custom-type="<%= v["id"] %>"><%= k %></a></td>
      <td><%= md(v["description"].split("\n")[0].split(". ")[0]) %></td>
    </tr>
<% end -%>

  </tbody>
</table>
EOT
      end
    end
  end
end
