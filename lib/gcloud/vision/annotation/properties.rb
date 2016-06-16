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
      # # Properties
      #
      # A set of properties about an image, such as the image's dominant colors.
      #
      # See {Gcloud::Vision::Image#properties}.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   vision = gcloud.vision
      #
      #   image = vision.image "path/to/logo.jpg"
      #
      #   properties = image.properties
      #   properties.colors.count #=> 10
      #
      class Properties
        ##
        # @private The ImageProperties Google API Client object.
        attr_accessor :gapi

        ##
        # @private Creates a new Properties instance.
        def initialize
          @gapi = {}
        end

        ##
        # The image's dominant colors, including their corresponding scores.
        #
        # @return [Array<Color>] An array of the image's dominant colors.
        #
        def colors
          return [] unless @gapi.dominant_colors
          @colors ||= Array(@gapi.dominant_colors.colors).map do |c|
            Color.from_gapi c
          end
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
          colors.map(&:rgb)
        end

        ##
        # Deeply converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_h
          to_hash
        end

        ##
        # Deeply converts object to a hash. All keys will be symbolized.
        #
        # @return [Hash]
        #
        def to_hash
          { colors: colors.map(&:to_h) }
        end

        # @private
        def to_s
          "(colors: #{colors.count})"
        end

        # @private
        def inspect
          "#<Properties #{self}>"
        end

        ##
        # @private New Annotation::Properties from a Google API Client object.
        def self.from_gapi gapi
          new.tap { |f| f.instance_variable_set :@gapi, gapi }
        end

        ##
        # # Color
        #
        # Color information consisting of RGB channels, score, and fraction of
        # image the color occupies in the image.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   vision = gcloud.vision
        #
        #   image = vision.image "path/to/logo.jpg"
        #   properties = image.properties
        #
        #   color = properties.colors.first
        #   color.red #=> 247.0
        #   color.green #=> 236.0
        #   color.blue #=> 20.0
        #   color.rgb #=> "f7ec14"
        #   color.alpha #=> 1.0
        #   color.score #=> 0.20301804
        #   color.pixel_fraction #=> 0.0072649573
        #
        class Color
          ##
          # @private The ColorInfo Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Color instance.
          def initialize
            @gapi = {}
          end

          ##
          # The amount of red in the color.
          #
          # @return [Float] A value in the interval [0, 255].
          #
          def red
            @gapi.color.red
          end

          ##
          # The amount of green in the color.
          #
          # @return [Float] A value in the interval [0, 255].
          #
          def green
            @gapi.color.green
          end

          ##
          # The amount of blue in the color.
          #
          # @return [Float] A value in the interval [0, 255].
          #
          def blue
            @gapi.color.blue
          end

          ##
          # The amount this color that should be applied to the pixel. A value
          # of 1.0 corresponds to a solid color, whereas a value of 0.0
          # corresponds to a completely transparent color.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def alpha
            @gapi.color.alpha || 1.0
          end

          def rgb
            red.to_i.to_s(16).rjust(2, "0") +
              green.to_i.to_s(16).rjust(2, "0") +
              blue.to_i.to_s(16).rjust(2, "0")
          end

          ##
          # Image-specific score for this color.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def score
            @gapi.score
          end

          ##
          # Stores the fraction of pixels the color occupies in the image.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def pixel_fraction
            @gapi.pixel_fraction
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
            { red: red, green: green, blue: blue, alpha: alpha, rgb: rgb,
              score: score, pixel_fraction: pixel_fraction }
          end

          def to_s
            "(colors: #{rgb})"
          end

          def inspect
            "#<Color #{self}>"
          end

          ##
          # @private New Annotation::Properties from a Google API Client object.
          def self.from_gapi gapi
            new.tap { |f| f.instance_variable_set :@gapi, gapi }
          end
        end
      end
    end
  end
end
