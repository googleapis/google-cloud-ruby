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
    # Accumulates configuration for an image annotation request. Users describe
    # the type of Google Cloud Vision API tasks to perform over images by
    # configuring features such as `faces`, `landmarks`, `text`, etc. This
    # configuration captures the Cloud Vision API vertical to operate on and the
    # number of top-scoring results to return.
    #
    # See {Project#annotate}.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #
    #   face_image = vision.image "path/to/face.jpg"
    #   landmark_image = vision.image "path/to/landmark.jpg"
    #
    #   annotation = vision.annotate do |annotate|
    #      annotate.annotate face_image, faces: 10, labels: 10
    #      annotate.annotate landmark_image, landmarks: 10
    #   end
    #
    #   annotation.faces.count #=> 1
    #   annotation.labels.count #=> 4
    #   annotation.landmarks.count #=> 1
    #
    class Annotate
      # @private
      attr_accessor :requests

      ##
      # @private Creates a new Annotate instance.
      def initialize project
        @project = project
        @requests = []
      end

      ##
      # Performs detection of Cloud Vision [features](https://cloud.google.com/vision/reference/rest/v1/images/annotate#Feature)
      # on the given images. If no options for features are provided, **all**
      # image detection features will be performed, with a default of `10`
      # results for faces, landmarks, logos, and labels. If any feature option
      # is provided, only the specified feature detections will be performed.
      # Please review [Pricing](https://cloud.google.com/vision/docs/pricing)
      # before use, as a separate charge is incurred for each feature performed
      # on an image.
      #
      # Cloud Vision sets upper limits on file size as well as on the total
      # combined size of all images in a request. Reducing your file size can
      # significantly improve throughput; however, be careful not to reduce
      # image quality in the process. See [Best Practices - Image
      # Sizing](https://cloud.google.com/vision/docs/image-best-practices#image_sizing)
      # for current file size limits.
      #
      # See {Project#annotate} for requests that do not involve multiple feature
      # configurations.
      #
      # @see https://cloud.google.com/vision/docs/requests-and-responses Cloud
      #   Vision API Requests and Responses
      # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#AnnotateImageRequest
      #   AnnotateImageRequest
      # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
      #
      # @param [Image] images The image or images to annotate. Required.
      # @param [Integer] faces The maximum number of results for the
      #   `FACE_DETECTION` feature. Optional.
      # @param [Integer] landmarks The maximum number of results for the
      #   `LANDMARK_DETECTION` feature. Optional.
      # @param [Integer] logos The maximum number of results for the
      #   `LOGO_DETECTION` feature. Optional.
      # @param [Integer] labels The maximum number of results for the
      #   `LABEL_DETECTION` feature. Optional.
      # @param [Boolean] text Whether to perform the `TEXT_DETECTION` feature
      #   (OCR). Optional.
      # @param [Boolean] safe_search Whether to perform the
      #   `SAFE_SEARCH_DETECTION` feature. Optional.
      # @param [Boolean] properties Whether to perform the
      #   `IMAGE_PROPERTIES` feature (currently, the image's dominant colors.)
      #   Optional.
      #
      # @return [Annotation, Array<Annotation>] The results for all image
      #   detections, returned as a single {Annotation} instance for one image,
      #   or as an array of {Annotation} instances, one per image, for multiple
      #   images.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #
      #   face_image = vision.image "path/to/face.jpg"
      #   landmark_image = vision.image "path/to/landmark.jpg"
      #   text_image = vision.image "path/to/text.png"
      #
      #   annotations = vision.annotate do |annotate|
      #      annotate.annotate face_image, faces: 10, labels: 10
      #      annotate.annotate landmark_image, landmarks: 10
      #      annotate.annotate text_image, text: true
      #   end
      #
      #   annotations[0].faces.count #=> 1
      #   annotations[0].labels.count #=> 4
      #   annotations[1].landmarks.count #=> 1
      #   annotations[2].text.words.count #=> 28
      #
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
