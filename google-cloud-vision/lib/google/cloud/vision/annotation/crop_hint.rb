# Copyright 2017 Google LLC
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


require "google/cloud/vision/annotation/vertex"

module Google
  module Cloud
    module Vision
      class Annotation
        ##
        # # CropHint
        #
        # A single crop hint that is used to generate new crops when serving
        # images.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/face.jpg"
        #
        #   crop_hints = image.crop_hints
        #   crop_hints.count #=> 1
        #   crop_hint = crop_hints.first
        #
        #   crop_hint.bounds.count #=> 4
        #   crop_hint.bounds[0].x #=> 1
        #   crop_hint.bounds[0].y #=> 0
        #   crop_hint.bounds[1].x #=> 511
        #   crop_hint.bounds[1].y #=> 0
        #   crop_hint.bounds[2].x #=> 511
        #   crop_hint.bounds[2].y #=> 383
        #   crop_hint.bounds[3].x #=> 0
        #   crop_hint.bounds[3].y #=> 383
        #
        #   crop_hint.confidence #=> 1.0
        #   crop_hint.importance_fraction #=> 1.0399999618530273
        #
        class CropHint
          ##
          # @private The Google::Cloud::Vision::V1::CropHint GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Entity instance.
          def initialize
            @grpc = nil
          end

          ##
          # The bounding polygon for the crop region. The coordinates of the
          # bounding box are in the original image's scale.
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
          # The confidence of this being a salient region.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def confidence
            @grpc.confidence
          end

          ##
          # The fraction of importance of this salient region with respect to
          # the original image.
          #
          # @return [Float]
          #
          def importance_fraction
            @grpc.importance_fraction
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { bounds: bounds.map(&:to_h), confidence: confidence,
              importance_fraction: importance_fraction }
          end

          # @private
          def to_s
            tmplt = "bounds: %i, confidence: %s, importance_fraction: %s"
            format tmplt, bounds.count, confidence.inspect,
                   importance_fraction.inspect
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
