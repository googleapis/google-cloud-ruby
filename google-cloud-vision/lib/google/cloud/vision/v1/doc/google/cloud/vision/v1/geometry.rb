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

module Google
  module Cloud
    module Vision
      module V1
        # A vertex represents a 2D point in the image.
        # NOTE: the vertex coordinates are in the same scale as the original image.
        # @!attribute [rw] x
        #   @return [Integer]
        #     X coordinate.
        # @!attribute [rw] y
        #   @return [Integer]
        #     Y coordinate.
        class Vertex; end

        # A bounding polygon for the detected image annotation.
        # @!attribute [rw] vertices
        #   @return [Array<Google::Cloud::Vision::V1::Vertex>]
        #     The bounding polygon vertices.
        class BoundingPoly; end

        # A 3D position in the image, used primarily for Face detection landmarks.
        # A valid Position must have both x and y coordinates.
        # The position coordinates are in the same scale as the original image.
        # @!attribute [rw] x
        #   @return [Float]
        #     X coordinate.
        # @!attribute [rw] y
        #   @return [Float]
        #     Y coordinate.
        # @!attribute [rw] z
        #   @return [Float]
        #     Z coordinate (or depth).
        class Position; end
      end
    end
  end
end