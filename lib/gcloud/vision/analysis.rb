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

      # Whether there is at least one Analysis::Entity result.
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

      def to_h
        to_hash
      end

      def to_hash
        { faces: faces.map(&:to_h), landmarks: landmarks.map(&:to_h) }
      end

      def to_s
        "(faces: #{faces.count}, landmarks: #{landmarks.count})"
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
