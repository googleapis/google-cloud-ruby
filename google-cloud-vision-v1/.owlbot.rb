# Copyright 2021 Google LLC
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

OwlBot.move_files

####
# Helper file generation
####

Dir.chdir OwlBot.gem_dir

ENV["BUNDLE_PATH"] = "vendor/bundle"
system "bundle install"
require "bundler/setup"

require "google/cloud/vision/v1"
require "erb"
require "fileutils"

# Simple code generator
class HelperGenerator
  def initialize
    @helper_methods = {}
    Google::Cloud::Vision::V1::Feature::Type.constants.sort.each do |feature_type|
      next if feature_type == :TYPE_UNSPECIFIED
      method_name = feature_type.to_s.downcase
      method_name = "#{method_name}_detection" unless method_name.end_with? "detection"
      @helper_methods[method_name] = feature_type
    end
  end

  def generate source, dest_path
    data_binding = binding
    template = File.read "owlbot-templates/#{source}"
    content = ERB.new(template).result(data_binding)
    FileUtils.mkdir_p File.dirname dest_path
    File.open(dest_path, "w") { |f| f.write content }
  end
end

generator = HelperGenerator.new

generator.generate "image_annotator_helpers.erb",
                   "lib/google/cloud/vision/v1/image_annotator/helpers.rb"
generator.generate "image_annotator_helpers_test.erb",
                   "test/google/cloud/vision/v1/image_annotator_helpers_test.rb"
generator.generate "helpers_smoke_test.erb",
                   "acceptance/google/cloud/vision/v1/helpers_smoke_test.rb"

FileUtils.rm_rf "vendor"

OwlBot.update_manifest
