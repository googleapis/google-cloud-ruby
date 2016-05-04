# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/vision/image"

module Gcloud
  module Vision
    class Annotate
      attr_accessor :requests

      def initialize project
        @project = project
        @requests = []
      end

      def annotate *images, faces: nil, landmarks: nil, logos: nil, labels: nil,
                   text: nil, safe_search: nil, properties: nil
        add_requests(images, faces, landmarks, logos, labels, text,
                     safe_search, properties)
      end

      protected

      def image source
        return source if source.is_a? Image
        Image.from_source source, @project
      end

      def add_requests images, faces, landmarks, logos, labels, text,
                       safe_search, properties
        features = annotate_features faces, landmarks, logos, labels, text,
                                     safe_search, properties
        Array(images).flatten.each do |img|
          @requests << { image: image(img).to_gapi, features: features }
        end
      end

      def annotate_features faces, landmarks, logos, labels, text,
                            safe_search, properties
        features = []
        features << { type: :FACE_DETECTION, maxResults: faces.to_i } if faces
        features << { type: :LANDMARK_DETECTION,
                      maxResults: landmarks.to_i } if landmarks
        features << { type: :LOGO_DETECTION, maxResults: logos.to_i } if logos
        features << { type: :LABEL_DETECTION,
                      maxResults: labels.to_i } if labels
        features << { type: :TEXT_DETECTION, maxResults: 1 } if text
        features << { type: :SAFE_SEARCH_DETECTION,
                      maxResults: 1 } if safe_search
        features << { type: :IMAGE_PROPERTIES, maxResults: 1 } if properties
        features
      end
    end
  end
end
