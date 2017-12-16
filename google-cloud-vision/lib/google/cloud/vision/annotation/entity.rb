# Copyright 2016 Google LLC
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


require "google/cloud/vision/location"
require "google/cloud/vision/annotation/vertex"

module Google
  module Cloud
    module Vision
      class Annotation
        ##
        # # Entity
        #
        # Represents characteristics of an entity detected in an image. May
        # describe a real-world entity such as a person, place, or thing. May be
        # identified with an entity ID as an entity in the Knowledge Graph (KG).
        #
        # @see https://developers.google.com/knowledge-graph/ Knowledge Graph
        #
        # @example In landmark detection:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   landmark = image.landmark
        #   landmark.score #=> 0.9191226363182068
        #   landmark.description #=> "Mount Rushmore"
        #   landmark.mid #=> "/m/019dvv"
        #
        # @example In logo detection:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/logo.jpg"
        #
        #   logo = image.logo
        #   logo.score #=> 0.7005731463432312
        #   logo.description #=> "Google"
        #   logo.mid #=> "/m/0b34hf"
        #
        # @example In label detection:
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/landmark.jpg"
        #
        #   labels = image.labels
        #   labels.count #=> 4
        #
        #   label = labels.first
        #   label.score #=> 0.9481348991394043
        #   label.description #=> "stone carving"
        #   label.mid #=> "/m/02wtjj"
        #
        class Entity
          ##
          # @private The EntityAnnotation GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Entity instance.
          def initialize
            @grpc = nil
          end

          ##
          # Opaque entity ID. Some IDs might be available in Knowledge Graph
          # (KG).
          #
          # @see https://developers.google.com/knowledge-graph/ Knowledge Graph
          #
          # @return [String] The opaque entity ID.
          #
          def mid
            @grpc.mid
          end

          ##
          # The language code for the locale in which the `description` is
          # expressed.
          #
          # @return [String] The [ISO
          #   639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
          #   language code.
          #
          def locale
            @grpc.locale
          end

          ##
          # Entity textual description, expressed in the {#locale} language.
          #
          # @return [String] A description of the entity.
          #
          def description
            @grpc.description
          end

          ##
          # Overall score of the result.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def score
            @grpc.score
          end

          ##
          # The accuracy of the entity detection in an image. For example, for
          # an image containing 'Eiffel Tower,' this field represents the
          # confidence that there is a tower in the query image.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def confidence
            @grpc.confidence
          end

          ##
          # The relevancy of the ICA (Image Content Annotation) label to the
          # image. For example, the relevancy of 'tower' to an image containing
          # 'Eiffel Tower' is likely higher than an image containing a distant
          # towering building, though the confidence that there is a tower may
          # be the same.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def topicality
            @grpc.topicality
          end

          ##
          # Image region to which this entity belongs. Not filled currently for
          # `labels` detection.
          #
          # @return [Array<Vertex>] An array of vertices.
          #
          def bounds
            return [] unless @grpc.bounding_poly
            @bounds ||= Array(@grpc.bounding_poly.vertices).map do |v|
              Vertex.from_grpc v
            end
          end

          ##
          # The location information for the detected entity. Multiple Location
          # elements can be present since one location may indicate the location
          # of the scene in the query image, and another the location of the
          # place where the query image was taken. Location information is
          # usually present for landmarks.
          #
          # @return [Array<Location>] An array of locations containing latitude
          #   and longitude.
          #
          def locations
            @locations ||= Array(@grpc.locations).map do |l|
              Location.from_grpc l.lat_lng
            end
          end

          ##
          # Some entities can have additional optional Property fields. For
          # example a different kind of score or string that qualifies the
          # entity. present for landmarks.
          #
          # @return [Hash] A hash containing property names and values.
          #
          def properties
            @properties ||=
              Hash[Array(@grpc.properties).map { |p| [p.name, p.value] }]
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { mid: mid, locale: locale, description: description,
              score: score, confidence: confidence, topicality: topicality,
              bounds: bounds.map(&:to_h), locations: locations.map(&:to_h),
              properties: properties }
          end

          # @private
          def to_s
            tmplt = "mid: %s, locale: %s, description: %s, score: %s, " \
                    "confidence: %s, topicality: %s, bounds: %i, " \
                    "locations: %i, properties: %s"
            format tmplt, mid.inspect, locale.inspect, description.inspect,
                   score.inspect, confidence.inspect, topicality.inspect,
                   bounds.count, locations.count, properties.inspect
          end

          # @private
          def inspect
            "#<#{self.class.name} #{self}>"
          end

          ##
          # @private New Annotation::Entity from a GRPC object.
          def self.from_grpc grpc
            new.tap { |f| f.instance_variable_set :@grpc, grpc }
          end
        end
      end
    end
  end
end
