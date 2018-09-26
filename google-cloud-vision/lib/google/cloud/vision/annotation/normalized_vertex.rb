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


module Google
  module Cloud
    module Vision
      class Annotation
        ##
        # # NormalizedVertex
        #
        # A normalized vertex in a set of bounding polygon vertices.
        #
        # @attr_reader [Float] x The X coordinate.
        # @attr_reader [Float] y The Y coordinate.
        #
        class NormalizedVertex
          attr_reader :x, :y

          ##
          # @private Creates a new NormalizedVertex instance.
          def initialize x, y
            @x = x
            @y = y
          end

          ##
          # Returns the object's property values as an array.
          #
          # @return [Array]
          #
          def to_a
            [x, y]
          end

          ##
          # Converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { x: x, y: y }
          end

          # @private
          def to_s
            "(x: #{x.inspect}, y: #{y.inspect})"
          end

          # @private
          def inspect
            "#<NormalizedVertex #{self}>"
          end

          ##
          # @private New Annotation::Entity::Bounds::Vertex from a Google API
          # Client object.
          def self.from_grpc grpc
            new grpc.x, grpc.y
          end
        end
      end
    end
  end
end
