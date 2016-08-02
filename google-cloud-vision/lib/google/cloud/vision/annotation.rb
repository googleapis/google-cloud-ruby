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


require "google/cloud/vision/annotation/face"
require "google/cloud/vision/annotation/entity"
require "google/cloud/vision/annotation/text"
require "google/cloud/vision/annotation/safe_search"
require "google/cloud/vision/annotation/properties"

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
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   vision = gcloud.vision
      #   image = vision.image "path/to/face.jpg"
      #
      #   annotation = vision.annotate image, faces: true, labels: true
      #   annotation.faces.count #=> 1
      #   annotation.labels.count #=> 4
      #   annotation.text #=> nil
      #
      class Annotation
        ##
        # @private The AnnotateImageResponse Google API Client object.
        attr_accessor :gapi

        ##
        # @private Creates a new Annotation instance.
        def initialize
          @gapi = nil
        end

        ##
        # The results of face detection.
        #
        # @return [Array<Face>]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, faces: true
        #   annotation.faces.count #=> 1
        #   face = annotation.faces.first
        #
        def faces
          @faces ||= Array(@gapi.face_annotations).map do |fa|
            Face.from_gapi fa
          end
        end

        ##
        # The first face result, if there is one.
        #
        # @return [Face]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
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
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, faces: 1
        #   annotation.face? #=> true
        #
        def face?
          faces.count > 0
        end

        ##
        # The results of landmark detection.
        #
        # @return [Array<Entity>]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = vision.annotate image, landmarks: 1
        #   annotation.landmarks.count #=> 1
        #   landmark = annotation.landmarks.first
        #
        def landmarks
          @landmarks ||= Array(@gapi.landmark_annotations).map do |lm|
            Entity.from_gapi lm
          end
        end

        ##
        # The first landmark result, if there is one.
        #
        # @return [Entity]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
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
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   annotation = vision.annotate image, landmarks: 1
        #   annotation.landmark? #=> true
        #
        def landmark?
          landmarks.count > 0
        end

        ##
        # The results of logo detection.
        #
        # @return [Array<Entity>]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/logo.jpg"
        #
        #   annotation = vision.annotate image, logos: 1
        #   annotation.logos.count #=> 1
        #   logo = annotation.logos.first
        #
        def logos
          @logos ||= Array(@gapi.logo_annotations).map do |lg|
            Entity.from_gapi lg
          end
        end

        ##
        # The first logo result, if there is one.
        #
        # @return [Entity]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
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
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/logo.jpg"
        #
        #   annotation = vision.annotate image, logos: 1
        #   annotation.logo? #=> true
        #
        def logo?
          logos.count > 0
        end

        ##
        # The results of label detection.
        #
        # @return [Array<Entity>]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, labels: 1
        #   annotation.labels.count #=> 1
        #   label = annotation.labels.first
        #
        def labels
          @labels ||= Array(@gapi.label_annotations).map do |lb|
            Entity.from_gapi lb
          end
        end

        ##
        # The first label result, if there is one.
        #
        # @return [Entity]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
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
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, labels: 1
        #   annotation.label? #=> true
        #
        def label?
          labels.count > 0
        end

        ##
        # The results of text (OCR) detection.
        #
        # @return [Text]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/text.png"
        #
        #   annotation = vision.annotate image, text: true
        #   text = annotation.text
        #
        def text
          @text ||= Text.from_gapi(@gapi.text_annotations)
        end

        ##
        # Whether there is a result from text (OCR) detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
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
        # @return [SafeSearch]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, safe_search: true
        #   safe_search = annotation.safe_search
        #
        def safe_search
          return nil unless @gapi.safe_search_annotation
          @safe_search ||= SafeSearch.from_gapi(@gapi.safe_search_annotation)
        end

        ##
        # Whether there is a result for safe_search detection.
        # detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
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
        # @return [Properties]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, properties: true
        #   properties = annotation.properties
        #
        def properties
          return nil unless @gapi.image_properties_annotation
          @properties ||= Properties.from_gapi(
            @gapi.image_properties_annotation)
        end

        ##
        # Whether there is a result for properties detection.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   vision = gcloud.vision
        #   image = vision.image "path/to/face.jpg"
        #
        #   annotation = vision.annotate image, properties: true
        #   annotation.properties? #=> true
        #
        def properties?
          !properties.nil?
        end

        ##
        # Deeply converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_h
          { faces: faces.map(&:to_h), landmarks: landmarks.map(&:to_h),
            logos: logos.map(&:to_h), labels: labels.map(&:to_h),
            text: text.map(&:to_h), safe_search: safe_search.to_h,
            properties: properties.to_h }
        end

        # @private
        def to_s
          tmplt = "(faces: %i, landmarks: %i, logos: %i, labels: %i," \
                  " text: %s, safe_search: %s, properties: %s)"
          format tmplt, faces.count, landmarks.count, logos.count, labels.count,
                 text?, safe_search?, properties?
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private New Annotation from a Google API Client object.
        def self.from_gapi gapi
          new.tap { |a| a.instance_variable_set :@gapi, gapi }
        end
      end
    end
  end
end
