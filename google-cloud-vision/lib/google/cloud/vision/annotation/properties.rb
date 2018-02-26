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
        # # Properties
        #
        # A set of properties about an image, such as the image's dominant
        # colors.
        #
        # See {Google::Cloud::Vision::Image#properties}.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/logo.jpg"
        #
        #   properties = image.properties
        #   properties.colors.count #=> 10
        #
        class Properties
          ##
          # @private The ImageProperties GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Properties instance.
          def initialize
            @grpc = nil
          end

          ##
          # The image's dominant colors, including their corresponding scores.
          #
          # @return [Array<Color>] An array of the image's dominant colors.
          #
          def colors
            return [] unless @grpc.dominant_colors
            @colors ||= Array(@grpc.dominant_colors.colors).map do |c|
              Color.from_grpc c
            end
          end

          ##
          # Returns the object's property values as an array.
          #
          # @return [Array]
          #
          def to_a
            colors.map(&:rgb)
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
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
          # @private New Annotation::Properties from a GRPC object.
          def self.from_grpc grpc
            new.tap { |f| f.instance_variable_set :@grpc, grpc }
          end

          ##
          # # Color
          #
          # Color information consisting of RGB channels, score, and fraction of
          # image the color occupies in the image.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
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
          #   color.score #=> 0.20301803946495056
          #   color.pixel_fraction #=> 0.007264957297593355
          #
          class Color
            ##
            # @private The ColorInfo GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Color instance.
            def initialize
              @grpc = nil
            end

            ##
            # The amount of red in the color.
            #
            # @return [Float] A value in the interval [0, 255].
            #
            def red
              @grpc.color.red
            end

            ##
            # The amount of green in the color.
            #
            # @return [Float] A value in the interval [0, 255].
            #
            def green
              @grpc.color.green
            end

            ##
            # The amount of blue in the color.
            #
            # @return [Float] A value in the interval [0, 255].
            #
            def blue
              @grpc.color.blue
            end

            ##
            # The amount this color that should be applied to the pixel. A value
            # of 1.0 corresponds to a solid color, whereas a value of 0.0
            # corresponds to a completely transparent color.
            #
            # @return [Float] A value in the range [0, 1].
            #
            def alpha
              @grpc.color.alpha || 1.0
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
              @grpc.score
            end

            ##
            # Stores the fraction of pixels the color occupies in the image.
            #
            # @return [Float] A value in the range [0, 1].
            #
            def pixel_fraction
              @grpc.pixel_fraction
            end

            ##
            # Converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
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
            # @private New Annotation::Properties from a GRPC
            # object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end
          end
        end
      end
    end
  end
end
