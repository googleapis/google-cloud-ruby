# Copyright 2018 Google LLC
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


require "google/cloud/vision/annotation/normalized_vertex"

module Google
  module Cloud
    module Vision
      class Annotation
        class ObjectLocalization
          ##
          # @private The LocalizedObjectAnnotation GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Web instance.
          def initialize
            @grpc = nil
          end

          ##
          # Opaque entity ID. Should align with {Entity#mid}.
          #
          # @return [String] The opaque entity ID.
          #
          def mid
            @grpc.mid
          end

          ##
          # The BCP-47 language code, such as "en-US" or "sr-Latn".
          #
          # @see http://www.unicode.org/reports/tr35/#Unicode_locale_identifier
          #
          # @return [String] The language code.
          #
          def code
            @grpc.language_code
          end

          ##
          # Object name, expressed in its {#code} language.
          #
          # @return [String] The object name.
          #
          def name
            @grpc.name
          end

          ##
          # The tcore of the result. Range [0, 1].
          #
          # @return [Float] A value in the range [0, 1].
          #
          def score
            @grpc.score
          end

          ##
          # Image region to which this entity belongs.
          #
          # @return [Array<NormalizedVertex>] An array of normalized vertices.
          #
          def bounds
            return [] unless @grpc.bounding_poly
            @bounds ||= @grpc.bounding_poly.normalized_vertices.map do |v|
              NormalizedVertex.from_grpc v
            end
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { mid: mid, code: code, name: name, score: score,
              bounds: bounds.map(&:to_h) }
          end

          # @private
          def to_s
            tmplt = "mid: %s, code: %s, name: %s, score: %s, " \
                    " bounds: %i"
            format tmplt, mid.inspect, code.inspect, name.inspect,
                   score.inspect, bounds.count
          end

          # @private
          def inspect
            "#<#{self.class.name} #{self}>"
          end

          ##
          # @private New Annotation::Face from a GRPC object.
          def self.from_grpc grpc
            new.tap { |ol| ol.instance_variable_set :@grpc, grpc }
          end
        end
      end
    end
  end
end
