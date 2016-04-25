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
      # # Face
      class Face
        ##
        # @private The FaceAnnotation Google API Client object.
        attr_accessor :gapi

        ##
        # @private Creates a new Face instance.
        def initialize
          @gapi = {}
        end

        ##
        # The angles of the face, including roll, yaw, and pitch.
        def angles
          @angles ||= Angles.from_gapi @gapi
        end

        ##
        # The Bounds of the face, including the polygons for the head and face.
        def bounds
          @bounds ||= Bounds.from_gapi @gapi
        end

        ##
        # The Features of the face, including the points for the eyes, ears,
        # nose and mouth.
        def features
          @features ||= Features.from_gapi @gapi
        end

        ##
        # The Likelihood of the facial detection, including joy, sorrow, anger,
        # surprise, under_exposed, blurred, and headwear.
        def likelihood
          @likelihood ||= Likelihood.from_gapi @gapi
        end

        ##
        # The confidence of the facial detection. Range [0, 1].
        def confidence
          @gapi["detectionConfidence"]
        end

        def to_s
          # Keep console output low by not showing all sub-objects.
          "(angles, bounds, features, likelihood)"
        end

        def inspect
          "#<#{self.class.name} #{self}>"
        end

        ##
        # @private New Analysis::Face from a Google API Client object.
        def self.from_gapi gapi
          new.tap { |f| f.instance_variable_set :@gapi, gapi }
        end

        ##
        # # Angles
        class Angles
          ##
          # @private The FaceAnnotation Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Angles instance.
          def initialize
            @gapi = {}
          end

          ##
          # Roll angle. Indicates the amount of clockwise/anti-clockwise
          # rotation of the face relative to the image vertical, about the axis
          # perpendicular to the face. Range [-180,180].
          def roll
            @gapi["rollAngle"]
          end

          ##
          # Yaw angle. Indicates the leftward/rightward angle that the face is
          # pointing, relative to the vertical plane perpendicular to the image.
          # Range [-180,180].
          def yaw
            @gapi["panAngle"]
          end
          alias_method :pan, :yaw

          ##
          # Pitch angle. Indicates the upwards/downwards angle that the face is
          # pointing relative to the image's horizontal plane. Range [-180,180].
          def pitch
            @gapi["tiltAngle"]
          end
          alias_method :tilt, :pitch

          def to_s
            format "(roll: %s, yaw: %s, pitch: %s)", roll.inspect, yaw.inspect,
                   pitch.inspect
          end

          def inspect
            "#<#{self.class.class_name} #{self}>"
          end

          ##
          # @private New Analysis::Face::Angles from a Google API Client object.
          def self.from_gapi gapi
            new.tap { |f| f.instance_variable_set :@gapi, gapi }
          end
        end

        ##
        # # Bounds
        class Bounds
          ##
          # @private The FaceAnnotation Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Bounds instance.
          def initialize
            @gapi = {}
          end

          ##
          # The bounding polygon around the face. The coordinates of the
          # bounding box are in the original image's scale, as returned in
          # ImageParams. The bounding box is computed to "frame" the face in
          # accordance with human expectations. It is based on the landmarker
          # results. Note that one or more x and/or y coordinates may not be
          # generated in the BoundingPoly (the polygon will be unbounded) if
          # only a partial face appears in the image to be annotated.
          def head
            return [] unless @gapi["boundingPoly"]
            @head ||= Array(@gapi["boundingPoly"]["vertices"]).map do |v|
              Vertex.from_gapi v
            end
          end

          ##
          # This bounding polygon is tighter than the {#head}, and encloses only
          # the skin part of the face. Typically, it is used to eliminate the
          # face from any image analysis that detects the "amount of skin"
          # visible in an image. It is not based on the landmarks, only on the
          # initial face detection.
          def face
            return [] unless @gapi["fdBoundingPoly"]
            @face ||= Array(@gapi["fdBoundingPoly"]["vertices"]).map do |v|
              Vertex.from_gapi v
            end
          end

          def to_s
            "(head: #{head.inspect}, face: #{face.inspect})"
          end

          def inspect
            "#<#{self.class.class_name} #{self}>"
          end

          ##
          # @private New Analysis::Face::Angles from a Google API Client object.
          def self.from_gapi gapi
            new.tap { |f| f.instance_variable_set :@gapi, gapi }
          end

          ##
          # # Vertex
          class Vertex
            attr_accessor :x, :y

            def initialize x, y
              @x = x
              @y = y
            end

            def to_a
              to_ary
            end

            def to_ary
              [x, y]
            end

            def to_s
              "(x: #{x.inspect}, y: #{y.inspect})"
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end

            ##
            # @private New Analysis::Face::Bounds::Vertex from a Google API
            # Client object.
            def self.from_gapi gapi
              new gapi["x"], gapi["y"]
            end
          end
        end

        ##
        # # Features
        class Features
          ##
          # @private The FaceAnnotation Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Angles instance.
          def initialize
            @gapi = {}
          end

          ##
          # The confidence of the facial features detection. Range [0, 1].
          def confidence
            @gapi["landmarkingConfidence"]
          end

          def [] landmark_type
            landmark = Array(@gapi["landmarks"]).detect do |l|
              l["type"] == landmark_type
            end
            return nil if landmark.nil?
            Landmark.from_gapi landmark
          end

          def chin
            @chin ||= Chin.new self["CHIN_LEFT_GONION"], self["CHIN_GNATHION"],
                               self["CHIN_RIGHT_GONION"]
          end

          def ears
            @ears ||= Ears.new self["LEFT_EAR_TRAGION"],
                               self["RIGHT_EAR_TRAGION"]
          end

          def eyebrows
            @eyebrows ||= begin
              left = Eyebrow.new self["LEFT_OF_LEFT_EYEBROW"],
                                 self["LEFT_EYEBROW_UPPER_MIDPOINT"],
                                 self["RIGHT_OF_LEFT_EYEBROW"]
              right = Eyebrow.new self["LEFT_OF_RIGHT_EYEBROW"],
                                  self["RIGHT_EYEBROW_UPPER_MIDPOINT"],
                                  self["RIGHT_OF_RIGHT_EYEBROW"]
              Eyebrows.new left, right
            end
          end

          def eyes
            @eyes ||= begin
              left = Eye.new self["LEFT_EYE_LEFT_CORNER"],
                             self["LEFT_EYE_BOTTOM_BOUNDARY"],
                             self["LEFT_EYE"], self["LEFT_EYE_PUPIL"],
                             self["LEFT_EYE_TOP_BOUNDARY"],
                             self["LEFT_EYE_RIGHT_CORNER"]
              right = Eye.new self["RIGHT_EYE_LEFT_CORNER"],
                              self["RIGHT_EYE_BOTTOM_BOUNDARY"],
                              self["RIGHT_EYE"], self["RIGHT_EYE_PUPIL"],
                              self["RIGHT_EYE_TOP_BOUNDARY"],
                              self["RIGHT_EYE_RIGHT_CORNER"]
              Eyes.new left, right
            end
          end

          def forehead
            @forehead ||= self["FOREHEAD_GLABELLA"]
          end

          def lips
            @lips ||= Lips.new self["UPPER_LIP"], self["LOWER_LIP"]
          end

          def mouth
            @mouth ||= Mouth.new self["MOUTH_LEFT"], self["MOUTH_CENTER"],
                                 self["MOUTH_RIGHT"]
          end

          def nose
            @nose ||= Nose.new self["NOSE_BOTTOM_LEFT"],
                               self["NOSE_BOTTOM_CENTER"], self["NOSE_TIP"],
                               self["MIDPOINT_BETWEEN_EYES"],
                               self["NOSE_BOTTOM_RIGHT"]
          end

          def to_s
            # Keep console output low by not showing all sub-objects.
            "(confidence, chin, ears, eyebrows, eyes, " \
              "forehead, lips, mouth, nose)"
          end

          def inspect
            "#<#{self.class.class_name} #{self}>"
          end

          ##
          # @private New Analysis::Face::Features from a Google API Client
          # object.
          def self.from_gapi gapi
            new.tap { |f| f.instance_variable_set :@gapi, gapi }
          end

          class Landmark
            ##
            # @private The Landmark Google API Client object.
            attr_accessor :gapi

            ##
            # @private Creates a new Angles instance.
            def initialize
              @gapi = {}
            end

            ##
            # Face landmark type.
            def type
              @gapi["type"]
            end

            ##
            # X coordinate.
            def x
              return nil unless @gapi["position"]
              @gapi["position"]["x"]
            end

            ##
            # Y coordinate.
            def y
              return nil unless @gapi["position"]
              @gapi["position"]["y"]
            end

            ##
            # Z coordinate (or depth).
            def z
              return nil unless @gapi["position"]
              @gapi["position"]["z"]
            end

            def to_a
              to_ary
            end

            def to_ary
              [x, y, z]
            end

            def to_s
              "(x: #{x.inspect}, y: #{y.inspect}, z: #{z.inspect})"
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end

            ##
            # @private New Analysis::Face::Features from a Google API Client
            # object.
            def self.from_gapi gapi
              new.tap { |f| f.instance_variable_set :@gapi, gapi }
            end
          end

          ##
          # # Chin
          class Chin
            attr_accessor :left, :center, :right

            def initialize left, center, right
              @left   = left
              @center = center
              @right  = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, center, right]
            end

            def to_s
              format "(left: %s, center: %s, right: %s)", left.inspect,
                     center.inspect, right.inspect
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Ears
          class Ears
            attr_accessor :left, :right

            def initialize left, right
              @left  = left
              @right = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, right]
            end

            def to_s
              "(left: #{left.inspect}, right: #{right.inspect})"
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Eyebrows
          class Eyebrows
            attr_accessor :left, :right

            def initialize left, right
              @left  = left
              @right = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, right]
            end

            def to_s
              "(left: #{left.inspect}, right: #{right.inspect})"
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Eyebrow
          class Eyebrow
            attr_accessor :left, :top, :right

            def initialize left, top, right
              @left  = left
              @top   = top
              @right = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, top, right]
            end

            def to_s
              format "(left: %s, top: %s, right: %s)", left.inspect,
                     top.inspect, right.inspect
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Eyes
          class Eyes
            attr_accessor :left, :right

            def initialize left, right
              @left  = left
              @right = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, right]
            end

            def to_s
              "(left: #{left.inspect}, right: #{right.inspect})"
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Eye
          class Eye
            attr_accessor :left, :bottom, :center, :pupil, :top, :right

            def initialize left, bottom, center, pupil, top, right
              @left   = left
              @bottom = bottom
              @center = center
              @pupil  = pupil
              @top    = top
              @right  = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, top, right]
            end

            def to_s
              tmplt = "(left: %s, bottom: %s, center: %s, " \
                        "pupil: %s, top: %s, right: %s)"
              format tmplt, left.inspect, bottom.inspect, center.inspect,
                     pupil.inspect, top.inspect, right.inspect
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Lips
          class Lips
            attr_accessor :top, :bottom

            alias_method :upper, :top
            alias_method :lower, :bottom

            def initialize top, bottom
              @top = top
              @bottom = bottom
            end

            def to_a
              to_ary
            end

            def to_ary
              [top, bottom]
            end

            def to_s
              "(top: #{top.inspect}, bottom: #{bottom.inspect})"
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Mouth
          class Mouth
            attr_accessor :left, :center, :right

            def initialize left, center, right
              @left   = left
              @center = center
              @right  = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, center, right]
            end

            def to_s
              format "(left: %s, center: %s, right: %s)", left.inspect,
                     center.inspect, right.inspect
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end

          ##
          # # Nose
          class Nose
            attr_accessor :left, :bottom, :tip, :top, :right

            def initialize left, bottom, tip, top, right
              @left   = left
              @bottom = bottom
              @tip    = tip
              @top    = top
              @right  = right
            end

            def to_a
              to_ary
            end

            def to_ary
              [left, bottom, tip, top, right]
            end

            def to_s
              tmplt = "(left: %s, bottom: %s, tip: %s, " \
                        "top: %s, right: %s)"
              format tmplt, left.inspect, bottom.inspect, tip.inspect,
                     top.inspect, right.inspect
            end

            def inspect
              "#<#{self.class.class_name} #{self}>"
            end
          end
        end

        ##
        # # Likelihood
        class Likelihood
          POSITIVE_RATINGS = %w(POSSIBLE LIKELY VERY_LIKELY)

          ##
          # @private The FaceAnnotation Google API Client object.
          attr_accessor :gapi

          ##
          # @private Creates a new Likelihood instance.
          def initialize
            @gapi = {}
          end

          ##
          # Joy likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def joy
            @gapi["joyLikelihood"]
          end

          ##
          # Joy likelihood. Returns `true` if {#joy} is `POSSIBLE`, `LIKELY`, or
          # `VERY_LIKELY`.
          def joy?
            POSITIVE_RATINGS.include? @gapi["joyLikelihood"]
          end

          ##
          # Sorrow likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def sorrow
            @gapi["sorrowLikelihood"]
          end

          ##
          # Sorrow likelihood. Returns `true` if {#joy} is `POSSIBLE`, `LIKELY`,
          # or `VERY_LIKELY`.
          def sorrow?
            POSITIVE_RATINGS.include? sorrow
          end

          ##
          # Joy likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def anger
            @gapi["angerLikelihood"]
          end

          ##
          # Anger likelihood. Returns `true` if {#joy} is `POSSIBLE`, `LIKELY`,
          # or `VERY_LIKELY`.
          def anger?
            POSITIVE_RATINGS.include? anger
          end

          ##
          # Surprise likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def surprise
            @gapi["surpriseLikelihood"]
          end

          ##
          # Surprise likelihood. Returns `true` if {#joy} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          def surprise?
            POSITIVE_RATINGS.include? surprise
          end

          ##
          # Under Exposed likelihood rating. Possible values are
          # `VERY_UNLIKELY`, `UNLIKELY`, `POSSIBLE`, `LIKELY`, and
          # `VERY_LIKELY`.
          def under_exposed
            @gapi["underExposedLikelihood"]
          end

          ##
          # Under Exposed likelihood. Returns `true` if {#joy} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          def under_exposed?
            POSITIVE_RATINGS.include? under_exposed
          end

          ##
          # Blurred likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def blurred
            @gapi["blurredLikelihood"]
          end

          ##
          # Blurred likelihood. Returns `true` if {#joy} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          def blurred?
            POSITIVE_RATINGS.include? blurred
          end

          ##
          # Headwear likelihood rating. Possible values are `VERY_UNLIKELY`,
          # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
          def headwear
            @gapi["headwearLikelihood"]
          end

          ##
          # Headwear likelihood. Returns `true` if {#joy} is `POSSIBLE`,
          # `LIKELY`, or `VERY_LIKELY`.
          def headwear?
            POSITIVE_RATINGS.include? headwear
          end

          def to_s
            tmplt = "(joy?: %s, sorrow?: %s, anger?: %s, " \
                      "surprise?: %s, under_exposed?: %s, blurred?: %s, " \
                      "headwear: %s)"
            format tmplt, joy?.inspect, sorrow?.inspect, anger?.inspect,
                   surprise?.inspect, under_exposed?.inspect, blurred?.inspect,
                   headwear?.inspect
          end

          def inspect
            "#<#{self.class.class_name} #{self}>"
          end

          ##
          # @private New Analysis::Face::Likelihood from a Google API Client
          # object.
          def self.from_gapi gapi
            new.tap { |f| f.instance_variable_set :@gapi, gapi }
          end
        end
      end
    end
  end
end
