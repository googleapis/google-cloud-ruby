# Copyright 2016 Google LLC
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


require "google/cloud/vision/annotation/face"
require "google/cloud/vision/annotation/entity"
require "google/cloud/vision/annotation/text"
require "google/cloud/vision/annotation/safe_search"
require "google/cloud/vision/annotation/properties"
require "google/cloud/vision/annotation/crop_hint"
require "google/cloud/vision/annotation/web"

module Google
  module Cloud
    module Vision
      ##
      # # Annotation
      #
      # The results of all requested image annotations.
      #
      # See {Project#annotate} and {Image}.
      #
      # @example
      #   require "google/cloud/vision"
      #
      #   vision = Google::Cloud::Vision.new
      #   image = vision.image "path/to/face.jpg"
      #
      #   annotation = vision.annotate image, faces: true, labels: true
      #   annotation.faces.count #=> 1
      #   annotation.labels.count #=> 4
      #   annotation.text #=> nil
      #
      class Annotation
        ##
        # @private The AnnotateImageResponse GRPC object.
        attr_accessor :grpc

        ##
        # @private Creates a new Annotation instance.
        def initialize
          @grpc = nil
        end

        ##
        # The results of face detection.
        #
        # @return [Array<Face>]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, faces: true
        #   annotation.faces.count #=> 1
        #   face = annotation.faces.first
        #
        def faces
          @faces ||= Array(@grpc.face_annotations).map do |fa|
            Face.from_grpc fa
          end
        end

        ##
        # The first face result, if there is one.
        #
        # @return [Face]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, faces: 1
        #   face = annotation.face
        #
        def face
          faces.first
        end

        ##
        # Whether there is at least one result from face detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, faces: 1
        #   annotation.face? #=> true
        #
        def face?
          faces.any?
        end

        ##
        # The results of landmark detection.
        #
        # @return [Array<Entity>]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = vision.annotate image, landmarks: 1
        #   annotation.landmarks.count #=> 1
        #   landmark = annotation.landmarks.first
        #
        def landmarks
          @landmarks ||= Array(@grpc.landmark_annotations).map do |lm|
            Entity.from_grpc lm
          end
        end

        ##
        # The first landmark result, if there is one.
        #
        # @return [Entity]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = vision.annotate image, landmarks: 1
        #   landmark = annotation.landmark
        #
        def landmark
          landmarks.first
        end

        ##
        # Whether there is at least one result from landmark detection.
        # detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = vision.annotate image, landmarks: 1
        #   annotation.landmark? #=> true
        #
        def landmark?
          landmarks.any?
        end

        ##
        # The results of logo detection.
        #
        # @return [Array<Entity>]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/logo.jpg"
        #
        #   annotation = vision.annotate image, logos: 1
        #   annotation.logos.count #=> 1
        #   logo = annotation.logos.first
        #
        def logos
          @logos ||= Array(@grpc.logo_annotations).map do |lg|
            Entity.from_grpc lg
          end
        end

        ##
        # The first logo result, if there is one.
        #
        # @return [Entity]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/logo.jpg"
        #
        #   annotation = vision.annotate image, logos: 1
        #   logo = annotation.logo
        #
        def logo
          logos.first
        end

        ##
        # Whether there is at least one result from logo detection.
        # detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/logo.jpg"
        #
        #   annotation = vision.annotate image, logos: 1
        #   annotation.logo? #=> true
        #
        def logo?
          logos.any?
        end

        ##
        # The results of label detection.
        #
        # @return [Array<Entity>]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, labels: 1
        #   annotation.labels.count #=> 1
        #   label = annotation.labels.first
        #
        def labels
          @labels ||= Array(@grpc.label_annotations).map do |lb|
            Entity.from_grpc lb
          end
        end

        ##
        # The first label result, if there is one.
        #
        # @return [Entity]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, labels: 1
        #   label = annotation.label
        #
        def label
          labels.first
        end

        ##
        # Whether there is at least one result from label detection.
        # detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, labels: 1
        #   annotation.label? #=> true
        #
        def label?
          labels.any?
        end

        ##
        # The results of text (OCR) detection.
        #
        # @return [Text]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/text.png"
        #
        #   annotation = vision.annotate image, text: true
        #   text = annotation.text
        #
        def text
          @text ||= \
            Text.from_grpc(@grpc.text_annotations, @grpc.full_text_annotation)
        end

        ##
        # Whether there is a result from text (OCR) detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/text.png"
        #
        #   annotation = vision.annotate image, text: true
        #   annotation.text? #=> true
        #
        def text?
          !text.nil?
        end

        ##
        # The results of safe_search detection.
        #
        # @return [SafeSearch, nil]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, safe_search: true
        #   safe_search = annotation.safe_search
        #
        def safe_search
          return nil unless @grpc.safe_search_annotation
          @safe_search ||= SafeSearch.from_grpc(@grpc.safe_search_annotation)
        end

        ##
        # Whether there is a result for safe_search detection.
        # detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, safe_search: true
        #   annotation.safe_search? #=> true
        #
        def safe_search?
          !safe_search.nil?
        end

        ##
        # The results of properties detection.
        #
        # @return [Properties, nil]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, properties: true
        #   properties = annotation.properties
        #
        def properties
          return nil unless @grpc.image_properties_annotation
          @properties ||= Properties.from_grpc(
            @grpc.image_properties_annotation
          )
        end

        ##
        # Whether there is a result for properties detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, properties: true
        #   annotation.properties? #=> true
        #
        def properties?
          !properties.nil?
        end

        ##
        # The results of crop hints detection.
        #
        # @return [Array<CropHint>]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, crop_hints: true
        #   crop_hints = annotation.crop_hints
        #
        def crop_hints
          return [] unless @grpc.crop_hints_annotation
          grpc_crop_hints = @grpc.crop_hints_annotation.crop_hints
          @crop_hints ||= Array(grpc_crop_hints).map do |ch|
            CropHint.from_grpc ch
          end
        end

        ##
        # Whether there is a result for crop hints detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, crop_hints: true
        #   annotation.crop_hints? #=> true
        #
        def crop_hints?
          crop_hints.any?
        end

        ##
        # The results of web detection.
        #
        # @return [Web]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, web: true
        #   web = annotation.web
        #
        def web
          return nil unless @grpc.web_detection
          @web ||= Web.from_grpc(@grpc.web_detection)
        end

        ##
        # Whether there is a result for web detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, web: true
        #   annotation.web? #=> true
        #
        def web?
          !web.nil?
        end

        ##
        # Deeply converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_h
          { faces: faces.map(&:to_h), landmarks: landmarks.map(&:to_h),
            logos: logos.map(&:to_h), labels: labels.map(&:to_h),
            text: text.to_h, safe_search: safe_search.to_h,
            properties: properties.to_h, crop_hints: crop_hints.map(&:to_h),
            web: web.to_h }
        end

        # @private
        def to_s
          tmplt = "(faces: %i, landmarks: %i, logos: %i, labels: %i," \
                  " text: %s, safe_search: %s, properties: %s," \
                  " crop_hints: %s, web: %s)"
          format tmplt, faces.count, landmarks.count, logos.count, labels.count,
                 text?, safe_search?, properties?, crop_hints?, web?
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private New Annotation from a GRPC object.
        def self.from_grpc grpc
          new.tap { |a| a.instance_variable_set :@grpc, grpc }
        end
      end
    end
  end
end
