#--
# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rdoc/rdoc"
require "rdoc/generator"
require "erb"
require "fileutils"
require "pathname"
require "yaml"

##--
# Gcloud RDoc Generator
module RDoc
  ##--
  # Gcloud RDoc Generator
  module Generator
    ##--
    # Gcloud RDoc Generator
    class Gcloud
      ::RDoc::RDoc.add_generator self

      include ERB::Util

      attr_accessor :store, :options
      attr_accessor :current
      attr_accessor :class_dir, :file_dir

      def initialize store, options
        @options = options
        @store = store
      end

      def generate
        # main index page
        generate_main

        # text pages
        generate_all_files

        # classes, modules, and methods
        generate_classes_and_modules
      end

      def generate_main
        # get the main text page
        main = @store.find_text_page(@options.main_page).dup
        # set the path so links always work
        def main.path; "index.html"; end
        self.current = main
        # main index page
        render_template "index.html.erb", "index.html"
        # api reference page
        def main.path; "reference.html"; end
        render_template "reference.html.erb", "reference.html"
      end

      def generate_all_files
        # text pages
        @store.all_files.select(&:text?).each do |p|
          self.current = p
          render_template "page.html.erb", "#{p.full_name}.html"
        end
      end

      def generate_classes_and_modules
        # classes, modules, and methods
        @store.all_classes_and_modules.sort.each do |c|
          self.current = c
          render_template "class.html.erb", c.path
        end
      end

      def path_to path
        Pathname(path).relative_path_from Pathname(current.path).dirname
      end
      alias_method :l, :path_to

      def binding_with opts = {}
        b = binding
        opts.each { |k, v| b.local_variable_set k, v }
        b
      end

      def render_partial file, opts = {}
        ERB.new(File.read(template_path("_#{file}"))).result(binding_with(opts))
      end

      def render_template file, output
        FileUtils.mkdir_p File.dirname output
        generated = ERB.new(File.read(template_path(file))).result(binding)
        File.write(output, generated)
      end

      def template_path file
        @template_dir ||= Pathname(@options.template_dir ||
          File.expand_path("../gcloud/", __FILE__))
        @template_dir + file
      end

      def friendly_page_name page
        side = side_config["pages"].find { |s| s["full_name"] == page.full_name }
        side ? side["name"] : page.full_name
      end

      def build_date
        @build_date ||= Date.today
      end

      def show_section? section, attributes
        return true if attributes = attributes.select(&:display?).any?
        current.methods_by_type(section).each do |type, visibilities|
          next if visibilities.empty?
          visibilities.each do |visibility, methods|
            next unless visibility == :public
            return true if methods.any?
          end
        end
        false
      end

      ## Configuration

      def side_config
        @side_config ||= begin
          config_file = File.dirname(File.expand_path(__FILE__)) + "/gcloud/config/side.yml"
          config_yaml = File.open config_file
          YAML::load config_yaml
        end
      end
    end
  end
end
