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


require "gcloud/vision/analysis/face"
require "gcloud/vision/analysis/entity"
require "gcloud/vision/analysis/safe_search"
require "gcloud/vision/analysis/properties"

module Gcloud
  module Vision
    ##
    # # Analysis
    #
    # Reports the results of the Image request.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   vision = gcloud.vision
    #   analysis = vision.detect image, faces: 1
    #   analysis.face? #=> true
    class Analysis
      ##
      # @private The AnnotateImageResponse Google API Client object.
      attr_accessor :gapi

      ##
      # @private Creates a new Analysis instance.
      def initialize
        @gapi = nil
      end

      # The Analysis::Face results containing the results of face detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, faces: 1
      #   analysis.faces.count #=> 1
      #   face = analysis.faces.first
      #
      def faces
        @faces ||= Array(@gapi["faceAnnotations"]).map do |fa|
          Face.from_gapi fa
        end
      end

      # The first Analysis::Face result, if there is one.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, faces: 1
      #   face = analysis.face
      #
      def face
        faces.first
      end

      # Whether there is at least one Analysis::Face result.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, faces: 1
      #   analysis.face? #=> true
      #
      def face?
        faces.count > 0
      end

      # The Analysis::Entity results containing the results of landmark
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, landmarks: 1
      #   analysis.landmarks.count #=> 1
      #   landmark = analysis.landmarks.first
      #
      def landmarks
        @landmarks ||= Array(@gapi["landmarkAnnotations"]).map do |lm|
          Entity.from_gapi lm
        end
      end

      # The first Analysis::Entity result, if there is one.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, landmarks: 1
      #   landmark = analysis.landmark
      #
      def landmark
        landmarks.first
      end

      # Whether there is at least one Analysis::Entity result for landmark
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, landmarks: 1
      #   analysis.landmark? #=> true
      #
      def landmark?
        landmarks.count > 0
      end

      # The Analysis::Entity results containing the results of logo detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, logos: 1
      #   analysis.logos.count #=> 1
      #   logo = analysis.logos.first
      #
      def logos
        @logos ||= Array(@gapi["logoAnnotations"]).map do |lg|
          Entity.from_gapi lg
        end
      end

      # The first Analysis::Entity result, if there is one.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, logos: 1
      #   logo = analysis.logo
      #
      def logo
        logos.first
      end

      # Whether there is at least one Analysis::Entity result for logo
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, logos: 1
      #   analysis.logo? #=> true
      #
      def logo?
        logos.count > 0
      end

      # The Analysis::Entity results containing the results of label detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, labels: 1
      #   analysis.labels.count #=> 1
      #   label = analysis.labels.first
      #
      def labels
        @labels ||= Array(@gapi["labelAnnotations"]).map do |lb|
          Entity.from_gapi lb
        end
      end

      # The first Analysis::Entity result, if there is one.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, labels: 1
      #   label = analysis.label
      #
      def label
        labels.first
      end

      # Whether there is at least one Analysis::Entity result for label
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, labels: 1
      #   analysis.label? #=> true
      #
      def label?
        labels.count > 0
      end

      # The Analysis::Entity results containing the results of text detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, text: true
      #   analysis.texts.count #=> 1
      #   text = analysis.texts.first
      #
      def texts
        @texts ||= Array(@gapi["textAnnotations"]).map do |txt|
          Entity.from_gapi txt
        end
      end

      # The first Analysis::Entity result, if there is one.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, text: true
      #   text = analysis.text
      #
      def text
        texts.first
      end

      # Whether there is at least one Analysis::Entity result for text
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, text: true
      #   analysis.text? #=> true
      #
      def text?
        texts.count > 0
      end

      # The Analysis::SafeSearch results containing the results of safe_search
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, safe_search: true
      #   safe_search = analysis.safe_search
      #
      def safe_search
        return nil unless @gapi["safeSearchAnnotation"]
        @safe_search ||= SafeSearch.from_gapi(@gapi["safeSearchAnnotation"])
      end

      # Whether there is a Analysis::SafeSearch result for safe_search
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, safe_search: true
      #   analysis.safe_search? #=> true
      #
      def safe_search?
        !safe_searchs.nil?
      end

      # The Analysis::Properties results containing the results of properties
      # detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, properties: true
      #   properties = analysis.properties
      #
      def properties
        return nil unless @gapi["imagePropertiesAnnotation"]
        @properties ||= Properties.from_gapi(@gapi["imagePropertiesAnnotation"])
      end

      # Whether there is a Analysis::Properties result for properties detection.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #   analysis = vision.detect image, properties: true
      #   analysis.properties? #=> true
      #
      def properties?
        !properties.nil?
      end

      def to_h
        to_hash
      end

      def to_hash
        { faces: faces.map(&:to_h), landmarks: landmarks.map(&:to_h),
          logos: logos.map(&:to_h), labels: labels.map(&:to_h),
          texts: text.map(&:to_h), safe_search: safe_search.to_h }
      end

      def to_s
        tmplt = "(faces: %i, landmarks: %i, logos: %i, labels: %i, texts: %i" \
                " safe_search: %s)"
        format tmplt, faces.count, landmarks.count, logos.count, labels.count,
               texts.count, safe_search?
      end

      def inspect
        "#<#{self.class.name} #{self}>"
      end

      ##
      # @private New Analysis from a Google API Client object.
      def self.from_gapi gapi
        new.tap { |a| a.instance_variable_set :@gapi, gapi }
      end
    end
  end
end
