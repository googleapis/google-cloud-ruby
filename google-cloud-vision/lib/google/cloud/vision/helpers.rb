# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "uri"

module Google
  module Cloud
    module Vision
      def add_helper_methods client, version_module
        require "google/cloud/vision/#{version_module.downcase}/image_annotator_pb"
        Google::Cloud::Vision.const_get(version_module)::Feature::Type.constants.each do |feature_type|
          next if [:TYPE_UNSPECIFIED].include? feature_type
          method_name = feature_type.to_s.downcase
          method_name += "_detection" unless method_name.include? "detection"

          client.define_singleton_method(method_name.to_sym) do |images: [], image: nil, max_results: nil, options: nil, &blk|
            feature = { type: feature_type }
            feature[:max_results] = max_results if max_results
            images << image if image
    
            formatted_images = images.map do |img|
              if File.file? img
                { content: File.binread(img) }
              elsif img =~ URI::DEFAULT_PARSER.make_regexp
                if URI(img).scheme == "gs"
                  source = { gcs_image_uri: img }
                  { source: source }
                else
                  source = { image_uri: img }
                  { source: source }
                end
              else
                raise TypeError.new("Image must be a filepath, file, url, or Google Cloud Storage url")
              end
            end
    
            requests = formatted_images.map do |img|
              {
                image: img,
                features: [feature]
              }
            end
    
            batch_annotate_images requests, options, &blk
          end
        end

        client
      end
      module_function :add_helper_methods
    end
  end
end
