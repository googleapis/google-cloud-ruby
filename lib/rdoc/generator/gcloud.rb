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
        # main index page
        self.current = @store.find_text_page(@options.main_page)
        render_template "index.html.erb", "index.html"
      end

      def generate_all_files
        # text pages
        @store.all_files.select(&:text?).each do |p|
          self.current = p
          render_template "page.html.erb", p.path
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
    end
  end
end
