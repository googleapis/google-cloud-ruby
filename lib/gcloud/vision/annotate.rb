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
    ##
    # # Annotate
    #
    #
    #
    class Annotate
      attr_accessor :requests

      def initialize project
        @project = project
        @requests = []
      end

      def annotate *images, faces: 0, landmarks: 0, logos: 0, labels: 0,
                   text: false, safe_search: false, properties: false
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
        features = annotate_features(faces, landmarks, logos, labels, text,
                                     safe_search, properties)

        Array(images).flatten.each do |img|
          i = image(img)
          @requests << { image: i.to_gapi, features: features,
                         imageContext: i.context.to_gapi }
        end
      end

      def annotate_features faces, landmarks, logos, labels, text,
                            safe_search, properties
        return default_features if default_features?(faces, landmarks, logos,
                                                     labels, text, safe_search,
                                                     properties)

        f = []
        f << { type: :FACE_DETECTION, maxResults: faces } unless faces.zero?
        f << { type: :LANDMARK_DETECTION,
               maxResults: landmarks } unless landmarks.zero?
        f << { type: :LOGO_DETECTION, maxResults: logos } unless logos.zero?
        f << { type: :LABEL_DETECTION, maxResults: labels } unless labels.zero?
        f << { type: :TEXT_DETECTION, maxResults: 1 } if text
        f << { type: :SAFE_SEARCH_DETECTION, maxResults: 1 } if safe_search
        f << { type: :IMAGE_PROPERTIES, maxResults: 1 } if properties
        f
      end

      def default_features? faces, landmarks, logos, labels, text,
                            safe_search, properties
        faces == 0 && landmarks == 0 && logos == 0 && labels == 0 &&
          text == false && safe_search == false && properties == false
      end

      def default_features
        [
          { type: :FACE_DETECTION, maxResults: 10 },
          { type: :LANDMARK_DETECTION, maxResults: 10 },
          { type: :LOGO_DETECTION, maxResults: 10 },
          { type: :LABEL_DETECTION, maxResults: 10 },
          { type: :TEXT_DETECTION, maxResults: 1 },
          { type: :SAFE_SEARCH_DETECTION, maxResults: 1 },
          { type: :IMAGE_PROPERTIES, maxResults: 1 }
        ]
      end
    end
  end
end
