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


require "google/cloud/vision/image"

module Google
  module Cloud
    module Vision
      ##
      # # Annotate
      #
      # Accumulates configuration for an image annotation request. Users
      # describe the type of Google Cloud Vision API tasks to perform over
      # images by configuring features such as `faces`, `landmarks`, `text`,
      # etc. This configuration captures the Cloud Vision API vertical to
      # operate on and the number of top-scoring results to return.
      #
      # See {Project#annotate}.
      #
      # @example
      #   require "google/cloud/vision"
      #
      #   vision = Google::Cloud::Vision.new
      #
      #   face_image = vision.image "path/to/face.jpg"
      #   landmark_image = vision.image "path/to/landmark.jpg"
      #
      #   annotations = vision.annotate do |annotate|
      #      annotate.annotate face_image, faces: true, labels: true
      #      annotate.annotate landmark_image, landmarks: true
      #   end
      #
      #   annotations[0].faces.count #=> 1
      #   annotations[0].labels.count #=> 4
      #   annotations[1].landmarks.count #=> 1
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
        # Performs detection of Cloud Vision
        # [features](https://cloud.google.com/vision/reference/rest/v1/images/annotate#Feature)
        # on the given images. If no options for features are provided, **all**
        # image detection features will be performed, with a default of `100`
        # results for faces, landmarks, logos, and labels. If any feature option
        # is provided, only the specified feature detections will be performed.
        # Please review [Pricing](https://cloud.google.com/vision/docs/pricing)
        # before use, as a separate charge is incurred for each feature
        # performed on an image.
        #
        # Cloud Vision sets upper limits on file size as well as on the total
        # combined size of all images in a request. Reducing your file size can
        # significantly improve throughput; however, be careful not to reduce
        # image quality in the process. See [Best Practices - Image
        # Sizing](https://cloud.google.com/vision/docs/best-practices#image_sizing)
        # for current file size limits.
        #
        # See {Project#annotate} for requests that do not involve multiple
        # feature configurations.
        #
        # @see https://cloud.google.com/vision/docs/requests-and-responses Cloud
        #   Vision API Requests and Responses
        # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#AnnotateImageRequest
        #   AnnotateImageRequest
        # @see https://cloud.google.com/vision/docs/pricing Cloud Vision Pricing
        #
        # @param [Image, Object] images The image or images to annotate. This
        #   can be an {Image} instance, or any other type that converts to an
        #   {Image}. See {#image} for details.
        # @param [Boolean, Integer] faces Whether to perform the facial
        #   detection feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_faces}, or may be provided here.
        #   Optional.
        # @param [Boolean, Integer] landmarks Whether to perform the landmark
        #   detection feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_landmarks}, or may be provided
        #   here. Optional.
        # @param [Boolean, Integer] logos Whether to perform the logo detection
        #   feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_logos}, or may be provided here.
        #   Optional.
        # @param [Boolean, Integer] labels Whether to perform the label
        #   detection feature. The maximum number of results is configured in
        #   {Google::Cloud::Vision.default_max_labels}, or may be provided here.
        #   Optional.
        # @param [Boolean] text Whether to perform the text (OCR) feature.
        #   Optional.
        # @param [Boolean] safe_search Whether to perform the safe search
        #   feature. Optional.
        # @param [Boolean] properties Whether to perform the image properties
        #   feature (currently, the image's dominant colors.) Optional.
        # @param [Boolean] crop_hints Whether to perform the crop hints feature.
        #   Optional.
        #
        # @return [Annotation, Array<Annotation>] The results for all image
        #   detections, returned as a single {Annotation} instance for one
        #   image, or as an array of {Annotation} instances, one per image, for
        #   multiple images.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   face_image = vision.image "path/to/face.jpg"
        #   landmark_image = vision.image "path/to/landmark.jpg"
        #   text_image = vision.image "path/to/text.png"
        #
        #   annotations = vision.annotate do |annotate|
        #      annotate.annotate face_image, faces: true, labels: true
        #      annotate.annotate landmark_image, landmarks: true
        #      annotate.annotate text_image, text: true
        #   end
        #
        #   annotations[0].faces.count #=> 1
        #   annotations[0].labels.count #=> 4
        #   annotations[1].landmarks.count #=> 1
        #   annotations[2].text.words.count #=> 28
        #
        def annotate *images, faces: false, landmarks: false, logos: false,
                     labels: false, text: false, safe_search: false,
                     properties: false, crop_hints: false
          add_requests(images, faces, landmarks, logos, labels, text,
                       safe_search, properties, crop_hints)
        end

        protected

        def image source
          return source if source.is_a? Image
          Image.from_source source, @project
        end

        def add_requests images, faces, landmarks, logos, labels, text,
                         safe_search, properties, crop_hints
          features = annotate_features(faces, landmarks, logos, labels, text,
                                       safe_search, properties, crop_hints)

          Array(images).flatten.each do |img|
            i = image(img)
            @requests << Google::Cloud::Vision::V1::AnnotateImageRequest.new(
              image: i.to_grpc,
              features: features,
              image_context: i.context.to_grpc
            )
          end
        end

        def annotate_features faces, landmarks, logos, labels, text,
                              safe_search, properties, crop_hints
          return default_features if default_features?(
            faces, landmarks, logos, labels, text, safe_search, properties,
            crop_hints)

          faces, landmarks, logos, labels = validate_max_values(
            faces, landmarks, logos, labels)

          f = value_features faces, landmarks, logos, labels
          f + boolean_features(text, safe_search, properties, crop_hints)
        end

        def value_features faces, landmarks, logos, labels
          f = []
          f << feature(:FACE_DETECTION, faces) unless faces.zero?
          f << feature(:LANDMARK_DETECTION, landmarks) unless landmarks.zero?
          f << feature(:LOGO_DETECTION, logos) unless logos.zero?
          f << feature(:LABEL_DETECTION, labels) unless labels.zero?
          f
        end

        def boolean_features text, safe_search, properties, crop_hints
          f = []
          f << feature(:TEXT_DETECTION, 1) if text
          f << feature(:SAFE_SEARCH_DETECTION, 1) if safe_search
          f << feature(:IMAGE_PROPERTIES, 1) if properties
          f << feature(:CROP_HINTS, 1) if crop_hints
          f
        end

        def feature type, max_results
          Google::Cloud::Vision::V1::Feature.new(
            type: type, max_results: max_results)
        end

        def default_features? faces, landmarks, logos, labels, text,
                              safe_search, properties, crop_hints
          faces == false && landmarks == false && logos == false &&
            labels == false && text == false && safe_search == false &&
            properties == false && crop_hints == false
        end

        def default_features
          [
            feature(:FACE_DETECTION, Google::Cloud::Vision.default_max_faces),
            feature(:LANDMARK_DETECTION,
                    Google::Cloud::Vision.default_max_landmarks),
            feature(:LOGO_DETECTION, Google::Cloud::Vision.default_max_logos),
            feature(:LABEL_DETECTION,
                    Google::Cloud::Vision.default_max_labels),
            feature(:TEXT_DETECTION, 1),
            feature(:SAFE_SEARCH_DETECTION, 1),
            feature(:IMAGE_PROPERTIES, 1),
            feature(:CROP_HINTS, 1)
          ]
        end

        def validate_max_values faces, landmarks, logos, labels
          faces     = validate_max_value(
            faces, Google::Cloud::Vision.default_max_faces)
          landmarks = validate_max_value(
            landmarks, Google::Cloud::Vision.default_max_landmarks)
          logos     = validate_max_value(
            logos, Google::Cloud::Vision.default_max_logos)
          labels    = validate_max_value(
            labels, Google::Cloud::Vision.default_max_labels)
          [faces, landmarks, logos, labels]
        end

        def validate_max_value value, default_value
          return value.to_int if value.respond_to? :to_int
          return default_value if value
          0 # not a number, not a truthy value
        end
      end
    end
  end
end
