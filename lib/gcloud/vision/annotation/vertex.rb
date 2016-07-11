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


module Gcloud
  module Vision
    class Annotation
      ##
      # # Vertex
      #
      # A vertex in a set of bounding polygon vertices.
      #
      # See {Face::Bounds} and {Text}.
      #
      # @attr_reader [Integer] x The X coordinate.
      # @attr_reader [Integer] y The Y coordinate.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #
      #   image = vision.image "path/to/text.png"
      #   text = image.text
      #
      #   text.bounds.count #=> 4
      #   vertex = text.bounds.first
      #   vertex.x #=> 13
      #   vertex.y #=> 8
      #
      class Vertex
        attr_reader :x, :y

        ##
        # @private Creates a new Vertex instance.
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
          to_ary
        end

        ##
        # Returns the object's property values as an array.
        #
        # @return [Array]
        #
        def to_ary
          [x, y]
        end

        ##
        # Converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_h
          to_hash
        end

        ##
        # Converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_hash
          { x: x, y: y }
        end

        # @private
        def to_s
          "(x: #{x.inspect}, y: #{y.inspect})"
        end

        # @private
        def inspect
          "#<Vertex #{self}>"
        end

        ##
        # @private New Annotation::Entity::Bounds::Vertex from a Google API
        # Client object.
        def self.from_gapi gapi
          new gapi.x, gapi.y
        end
      end
    end
  end
end
