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


require "google/cloud/vision/annotation/vertex"

module Google
  module Cloud
    module Vision
      class Annotation
        ##
        # # SafeSearch
        #
        # A set of features pertaining to the image, computed by various
        # computer vision methods over safe-search verticals (for example,
        # adult, spoof, medical, violence).
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/face.jpg"
        #
        #   safe_search = image.safe_search
        #   safe_search.spoof? #=> false
        #   safe_search.spoof #=> :VERY_UNLIKELY
        #
        class SafeSearch
          POSITIVE_RATINGS = %i[POSSIBLE LIKELY VERY_LIKELY].freeze

          ##
          # @private The SafeSearchAnnotation GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new SafeSearch instance.
          def initialize
            @grpc = nil
          end

          ##
          # Adult likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def adult
            @grpc.adult
          end

          ##
          # Adult likelihood. Returns `true` if {#adult} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          #
          # @return [Boolean]
          #
          def adult?
            POSITIVE_RATINGS.include? adult
          end

          ##
          # Spoof likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def spoof
            @grpc.spoof
          end

          ##
          # Spoof likelihood. Returns `true` if {#spoof} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          #
          # @return [Boolean]
          #
          def spoof?
            POSITIVE_RATINGS.include? spoof
          end

          ##
          # Medical likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def medical
            @grpc.medical
          end

          ##
          # Medical likelihood. Returns `true` if {#medical} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          #
          # @return [Boolean]
          #
          def medical?
            POSITIVE_RATINGS.include? medical
          end

          ##
          # Violence likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def violence
            @grpc.violence
          end

          ##
          # Violence likelihood. Returns `true` if {#violence} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          #
          # @return [Boolean]
          #
          def violence?
            POSITIVE_RATINGS.include? violence
          end

          ##
          # Converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { adult: adult?, spoof: spoof?, medical: medical?,
              violence: violence? }
          end

          # @private
          def to_s
            tmplt = "(adult?: %s, spoof?: %s, medical?: %s, " \
                      "violence?: %s)"
            format tmplt, adult?.inspect, spoof?.inspect, medical?.inspect,
                   violence?.inspect
          end

          # @private
          def inspect
            "#<SafeSearch #{self}>"
          end

          ##
          # @private New Annotation::SafeSearch from a GRPC object.
          def self.from_grpc grpc
            new.tap { |f| f.instance_variable_set :@grpc, grpc }
          end
        end
      end
    end
  end
end
