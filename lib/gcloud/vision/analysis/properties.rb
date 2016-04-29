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
    class Analysis
      ##
      # # Properties
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
        # Set of dominant colors and their corresponding scores.
        def colors
          return [] unless @gapi["dominantColors"]
          @colors ||= Array(@gapi["dominantColors"]["colors"]).map do |c|
            Color.from_gapi c
          end
        end

        def to_a
          to_ary
        end

        def to_ary
          colors.map(&:rgb)
        end

        def to_h
          to_hash
        end

        def to_hash
          { colors: colors.map(&:to_h) }
        end

        def to_s
          "(colors: #{colors.count})"
        end

        def inspect
          "#<Properties #{self}>"
        end

        ##
        # @private New Analysis::Properties from a Google API Client object.
        def self.from_gapi gapi
          new.tap { |f| f.instance_variable_set :@gapi, gapi }
        end

        ##
        # # Color
        class Color
          ##
          # @private The ColorInfo Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Likelihood instance.
          def initialize
            @gapi = {}
          end

          ##
          # The amount of red in the color as a value in the interval [0, 255].
          def red
            @gapi["color"]["red"]
          end

          ##
          # The amount of green in the color as a value in the interval [0,
          # 255].
          def green
            @gapi["color"]["green"]
          end

          ##
          # The amount of blue in the color as a value in the interval [0, 255].
          def blue
            @gapi["color"]["blue"]
          end

          ##
          # The amount this color that should be applied to the pixel. A value
          # of 1.0 corresponds to a solid color, whereas a value of 0.0
          # corresponds to a completely transparent color.
          def alpha
            @gapi["color"]["alpha"] || 1.0
          end

          def rgb
            "#{red.to_i.to_s 16}#{green.to_i.to_s 16}#{blue.to_i.to_s 16}"
          end

          ##
          # Image-specific score for this color. Value in range [0, 1].
          def score
            @gapi["score"]
          end

          ##
          # Stores the fraction of pixels the color occupies in the image. Value
          # in range [0, 1].
          def pixel_fraction
            @gapi["pixelFraction"]
          end

          def to_h
            to_hash
          end

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
          # @private New Analysis::Properties from a Google API Client object.
          def self.from_gapi gapi
            new.tap { |f| f.instance_variable_set :@gapi, gapi }
          end
        end
      end
    end
  end
end
