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
        # # Face
        #
        # The results of face detection.
        #
        # See {Annotation#faces} and {Annotation#face}.
        #
        # @example
        #   require "google/cloud/vision"
        #
        #   vision = Google::Cloud::Vision.new
        #
        #   image = vision.image "path/to/face.jpg"
        #
        #   face = image.face
        #   face.confidence #=> 0.8616237640380859
        #
        class Face
          ##
          # @private The FaceAnnotation GRPC object.
          attr_accessor :grpc

          ##
          # @private Creates a new Face instance.
          def initialize
            @grpc = nil
          end

          ##
          # The angles of the face, including roll, yaw, and pitch.
          #
          # @return [Angles]
          #
          def angles
            @angles ||= Angles.from_grpc @grpc
          end

          ##
          # The bounds of the face, including the polygons for the head and
          # face.
          #
          # @return [Bounds]
          #
          def bounds
            @bounds ||= Bounds.from_grpc @grpc
          end

          ##
          # The landmarks of the face, including the points for the eyes, ears,
          # nose and mouth.
          #
          # @return [Features]
          #
          def features
            @features ||= Features.from_grpc @grpc
          end

          ##
          # The likelihood of the facial detection, including joy, sorrow,
          # anger, surprise, under_exposed, blurred, and headwear.
          #
          # @return [Likelihood]
          #
          def likelihood
            @likelihood ||= Likelihood.from_grpc @grpc
          end

          ##
          # The confidence of the facial detection.
          #
          # @return [Float] A value in the range [0, 1].
          #
          def confidence
            @grpc.detection_confidence
          end

          ##
          # Deeply converts object to a hash. All keys will be symbolized.
          #
          # @return [Hash]
          #
          def to_h
            { angles: angles.to_h, bounds: bounds.to_h, features: features.to_h,
              likelihood: likelihood.to_h }
          end

          # @private
          def to_s
            # Keep console output low by not showing all sub-objects.
            "(angles, bounds, features, likelihood)"
          end

          # @private
          def inspect
            "#<#{self.class.name} #{self}>"
          end

          ##
          # @private New Annotation::Face from a GRPC object.
          def self.from_grpc grpc
            new.tap { |f| f.instance_variable_set :@grpc, grpc }
          end

          ##
          # # Angles
          #
          # The orientation of the face relative to the image.
          #
          # See {Face}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/face.jpg"
          #   face = image.face
          #
          #   face.angles.roll #=> -5.149211883544922
          #   face.angles.yaw #=> -4.069568157196045
          #   face.angles.pitch #=> -13.083284378051758
          #
          class Angles
            ##
            # @private The FaceAnnotation GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Angles instance.
            def initialize
              @grpc = nil
            end

            ##
            # Roll angle. Indicates the amount of clockwise/anti-clockwise
            # rotation of the face relative to the image vertical, about the
            # axis perpendicular to the face.
            #
            # @return [Float] A value in the range [-180,180].
            #
            def roll
              @grpc.roll_angle
            end

            ##
            # Yaw (pan) angle. Indicates the leftward/rightward angle that the
            # face is pointing, relative to the vertical plane perpendicular to
            # the image.
            #
            # @return [Float] A value in the range [-180,180].
            #
            def yaw
              @grpc.pan_angle
            end
            alias pan yaw

            ##
            # Pitch (tilt) angle. Indicates the upwards/downwards angle that the
            # face is pointing relative to the image's horizontal plane.
            #
            # @return [Float] A value in the range [-180,180].
            #
            def pitch
              @grpc.tilt_angle
            end
            alias tilt pitch

            ##
            # Returns the object's property values as an array.
            #
            # @return [Array]
            #
            def to_a
              [roll, yaw, pitch]
            end

            ##
            # Converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { roll: roll, yaw: yaw, pitch: pitch }
            end

            # @private
            def to_s
              format "(roll: %s, yaw: %s, pitch: %s)", roll.inspect,
                     yaw.inspect, pitch.inspect
            end

            # @private
            def inspect
              "#<Angles #{self}>"
            end

            ##
            # @private New Annotation::Face::Angles from a GRPC
            # object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end
          end

          ##
          # # Bounds
          #
          # Bounding polygons around the face.
          #
          # See {Face}.
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/face.jpg"
          #   face = image.face
          #
          #   face.bounds.face.count #=> 4
          #   vertex = face.bounds.face.first
          #   vertex.x #=> 28
          #   vertex.y #=> 40
          #
          class Bounds
            ##
            # @private The FaceAnnotation GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Bounds instance.
            def initialize
              @grpc = nil
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
              return [] unless @grpc.bounding_poly
              @head ||= Array(@grpc.bounding_poly.vertices).map do |v|
                Vertex.from_grpc v
              end
            end

            ##
            # This bounding polygon is tighter than the {#head}, and encloses
            # only the skin part of the face. Typically, it is used to eliminate
            # the face from any image annotation that detects the "amount of
            # skin" visible in an image. It is not based on the landmarks, only
            # on the initial face detection.
            def face
              return [] unless @grpc.fd_bounding_poly
              @face ||= Array(@grpc.fd_bounding_poly.vertices).map do |v|
                Vertex.from_grpc v
              end
            end

            ##
            # Returns the object's property values as an array.
            #
            # @return [Array]
            #
            def to_a
              [head.map(&:to_a), face.map(&:to_a)]
            end

            ##
            # Deeply converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { head: head.map(&:to_h), face: face.map(&:to_h) }
            end

            # @private
            def to_s
              "(head: #{head.inspect}, face: #{face.inspect})"
            end

            # @private
            def inspect
              "#<Bounds #{self}>"
            end

            ##
            # @private New Annotation::Face::Angles from a GRPC
            # object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end
          end

          ##
          # # Features
          #
          # Represents facial landmarks or features. Left and right are defined
          # from the vantage of the viewer of the image, without considering
          # mirror projections typical of photos. So `face.features.eyes.left`
          # typically is the person's right eye.
          #
          # See {Face}.
          #
          # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
          #   images.annotate Type
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/face.jpg"
          #   face = image.face
          #
          #   face.features.to_h.count #=> 9
          #   face.features.eyes.left.pupil
          #   #<Landmark (x: 190.41544, y: 84.4557, z: -1.3682901)>
          #   face.features.chin.center
          #   #<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
          #
          class Features
            ##
            # @private The FaceAnnotation GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Features instance.
            def initialize
              @grpc = nil
            end

            ##
            # The confidence of the facial landmarks detection.
            #
            # @return [Float] A value in the range [0,1].
            #
            def confidence
              @grpc.landmarking_confidence
            end

            ##
            # Returns the facial landmark for the provided type code.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @param [String, Symbol] landmark_type An `images.annotate` type
            #   code from the [Vision
            #   API](https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1).
            #
            # @return [Landmark]
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   face.features["RIGHT_EAR_TRAGION"]
            #   #<Landmark (x: 303.81198, y: 88.5782, z: 77.719193)>
            #
            def [] landmark_type
              landmark = Array(@grpc.landmarks).detect do |l|
                l.type == landmark_type
              end
              return nil if landmark.nil?
              Landmark.from_grpc landmark
            end

            ##
            # The landmarks of the chin.
            #
            # @return [Chin]
            #
            def chin
              @chin ||= Chin.new self[:CHIN_LEFT_GONION],
                                 self[:CHIN_GNATHION],
                                 self[:CHIN_RIGHT_GONION]
            end

            ##
            # The landmarks of the ears.
            #
            # @return [Ears]
            #
            def ears
              @ears ||= Ears.new self[:LEFT_EAR_TRAGION],
                                 self[:RIGHT_EAR_TRAGION]
            end

            ##
            # The landmarks of the eyebrows.
            #
            # @return [Eyebrows]
            #
            def eyebrows
              @eyebrows ||= begin
                left = Eyebrow.new self[:LEFT_OF_LEFT_EYEBROW],
                                   self[:LEFT_EYEBROW_UPPER_MIDPOINT],
                                   self[:RIGHT_OF_LEFT_EYEBROW]
                right = Eyebrow.new self[:LEFT_OF_RIGHT_EYEBROW],
                                    self[:RIGHT_EYEBROW_UPPER_MIDPOINT],
                                    self[:RIGHT_OF_RIGHT_EYEBROW]
                Eyebrows.new left, right
              end
            end

            ##
            # The landmarks of the eyes.
            #
            # @return [Eyes]
            #
            def eyes
              @eyes ||= begin
                left = Eye.new self[:LEFT_EYE_LEFT_CORNER],
                               self[:LEFT_EYE_BOTTOM_BOUNDARY],
                               self[:LEFT_EYE], self[:LEFT_EYE_PUPIL],
                               self[:LEFT_EYE_TOP_BOUNDARY],
                               self[:LEFT_EYE_RIGHT_CORNER]
                right = Eye.new self[:RIGHT_EYE_LEFT_CORNER],
                                self[:RIGHT_EYE_BOTTOM_BOUNDARY],
                                self[:RIGHT_EYE], self[:RIGHT_EYE_PUPIL],
                                self[:RIGHT_EYE_TOP_BOUNDARY],
                                self[:RIGHT_EYE_RIGHT_CORNER]
                Eyes.new left, right
              end
            end

            ##
            # The landmark for the forehead glabella.
            #
            # @return [Landmark]
            #
            def forehead
              @forehead ||= self[:FOREHEAD_GLABELLA]
            end

            ##
            # The landmarks of the lips.
            #
            # @return [Lips]
            #
            def lips
              @lips ||= Lips.new self[:UPPER_LIP], self[:LOWER_LIP]
            end

            ##
            # The landmarks of the mouth.
            #
            # @return [Mouth]
            #
            def mouth
              @mouth ||= Mouth.new self[:MOUTH_LEFT], self[:MOUTH_CENTER],
                                   self[:MOUTH_RIGHT]
            end

            ##
            # The landmarks of the nose.
            #
            # @return [Nose]
            #
            def nose
              @nose ||= Nose.new self[:NOSE_BOTTOM_LEFT],
                                 self[:NOSE_BOTTOM_CENTER], self[:NOSE_TIP],
                                 self[:MIDPOINT_BETWEEN_EYES],
                                 self[:NOSE_BOTTOM_RIGHT]
            end

            ##
            # Deeply converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { confidence: confidence, chin: chin.to_h, ears: ears.to_h,
                eyebrows: eyebrows.to_h, eyes: eyes.to_h,
                forehead: forehead.to_h, lips: lips.to_h, mouth: mouth.to_h,
                nose: nose.to_h }
            end

            # @private
            def to_s
              # Keep console output low by not showing all sub-objects.
              "(confidence, chin, ears, eyebrows, eyes, " \
                "forehead, lips, mouth, nose)"
            end

            # @private
            def inspect
              "#<Features #{self}>"
            end

            ##
            # @private New Annotation::Face::Features from a GRPC
            # object.
            def self.from_grpc grpc
              new.tap { |f| f.instance_variable_set :@grpc, grpc }
            end

            ##
            # # Landmark
            #
            # A face-specific landmark (for example, a face feature). Landmark
            # positions may fall outside the bounds of the image when the face
            # is near one or more edges of the image. Therefore it is NOT
            # guaranteed that `0 <= x < width` or `0 <= y < height`.
            #
            # See {Features} and {Face}.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   face.features.to_h.count #=> 9
            #   face.features.eyes.left.pupil
            #   #<Landmark (x: 190.41544, y: 84.4557, z: -1.3682901)>
            #   face.features.chin.center
            #   #<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
            #
            class Landmark
              ##
              # @private The Landmark GRPC object.
              attr_accessor :grpc

              ##
              # @private Creates a new Landmark instance.
              def initialize
                @grpc = nil
              end

              ##
              # The landmark type code.
              #
              # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
              #   images.annotate Type
              #
              # @return [String]
              #
              # @example
              #   require "google/cloud/vision"
              #
              #   vision = Google::Cloud::Vision.new
              #
              #   image = vision.image "path/to/face.jpg"
              #   face = image.face
              #
              #   face.features.forehead.type #=> :FOREHEAD_GLABELLA
              #
              def type
                @grpc.type
              end

              ##
              # The X (horizontal) coordinate.
              #
              # @return [Float]
              #
              def x
                return nil unless @grpc.position
                @grpc.position.x
              end

              ##
              # The Y (vertical) coordinate.
              #
              # @return [Float]
              #
              def y
                return nil unless @grpc.position
                @grpc.position.y
              end

              ##
              # The Z (depth) coordinate.
              #
              # @return [Float]
              #
              def z
                return nil unless @grpc.position
                @grpc.position.z
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [x, y, z]
              end

              ##
              # Converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { x: x, y: y, z: z }
              end

              # @private
              def to_s
                "(x: #{x.inspect}, y: #{y.inspect}, z: #{z.inspect})"
              end

              # @private
              def inspect
                "#<Landmark #{self}>"
              end

              ##
              # @private New Annotation::Face::Features from a GRPC
              # object.
              def self.from_grpc grpc
                new.tap { |f| f.instance_variable_set :@grpc, grpc }
              end
            end

            ##
            # # Chin
            #
            # The landmarks of the chin in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Features} and {Face}.
            #
            # @attr_reader [Landmark] left The chin, left gonion.
            # @attr_reader [Landmark] center The chin, gnathion.
            # @attr_reader [Landmark] right The chin, right gonion.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   chin = face.features.chin
            #
            #   chin.center
            #   #<Landmark (x: 233.21977, y: 189.47475, z: 19.487228)>
            #
            class Chin
              attr_reader :left, :center, :right

              ##
              # @private Creates a new Chin instance.
              def initialize left, center, right
                @left   = left
                @center = center
                @right  = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, center, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, center: center.to_h, right: right.to_h }
              end

              # @private
              def to_s
                format "(left: %s, center: %s, right: %s)", left.inspect,
                       center.inspect, right.inspect
              end

              # @private
              def inspect
                "#<Chin #{self}>"
              end
            end

            ##
            # # Ears
            #
            # The landmarks for the ear tragions.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Features} and {Face}.
            #
            # @attr_reader [Landmark] left The left ear tragion.
            # @attr_reader [Landmark] right The right ear tragion.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   ears = face.features.ears
            #   ears.right
            #   #<Landmark (x: 303.81198, y: 88.5782, z: 77.719193)>
            #
            class Ears
              attr_reader :left, :right

              ##
              # @private Creates a new Ears instance.
              def initialize left, right
                @left  = left
                @right = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, right: right.to_h }
              end

              # @private
              def to_s
                "(left: #{left.inspect}, right: #{right.inspect})"
              end

              # @private
              def inspect
                "#<Ears #{self}>"
              end
            end

            ##
            # # Eyebrows
            #
            # The landmarks of the eyebrows in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Features} and {Face}.
            #
            # @attr_reader [Eyebrow] left The left eyebrow.
            # @attr_reader [Eyebrow] right The right eyebrow.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   eyebrows = face.features.eyebrows
            #
            #   right_eyebrow = eyebrows.right
            #   right_eyebrow.top
            #   #<Landmark (x: 256.3194, y: 58.222664, z: -17.299419)>
            #
            class Eyebrows
              attr_reader :left, :right

              ##
              # @private Creates a new Eyebrows instance.
              def initialize left, right
                @left  = left
                @right = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, right: right.to_h }
              end

              # @private
              def to_s
                "(left: #{left.inspect}, right: #{right.inspect})"
              end

              # @private
              def inspect
                "#<Eyebrows #{self}>"
              end
            end

            ##
            # # Eyebrow
            #
            # The landmarks of an eyebrow in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Eyebrows}, {Features} and {Face}.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @attr_reader [Landmark] left The eyebrow, left.
            # @attr_reader [Landmark] top The eyebrow, upper midpoint.
            # @attr_reader [Landmark] right The eyebrow, right.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   eyebrows = face.features.eyebrows
            #
            #   right_eyebrow = eyebrows.right
            #   right_eyebrow.top
            #   #<Landmark (x: 256.3194, y: 58.222664, z: -17.299419)>
            #
            class Eyebrow
              attr_reader :left, :top, :right

              ##
              # @private Creates a new Eyebrow instance.
              def initialize left, top, right
                @left  = left
                @top   = top
                @right = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, top, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, top: top.to_h, right: right.to_h }
              end

              # @private
              def to_s
                format "(left: %s, top: %s, right: %s)", left.inspect,
                       top.inspect, right.inspect
              end

              # @private
              def inspect
                "#<Eyebrow #{self}>"
              end
            end

            ##
            # # Eyes
            #
            # The landmarks of the eyes in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Features} and {Face}.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @attr_reader [Eye] left The left eye.
            # @attr_reader [Eye] right The right eye.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   eyes = face.features.eyes
            #
            #   right_eye = eyes.right
            #   right_eye.pupil
            #   #<Landmark (x: 256.63464, y: 79.641411, z: -6.0731235)>
            #
            class Eyes
              attr_reader :left, :right

              ##
              # @private Creates a new Eyes instance.
              def initialize left, right
                @left  = left
                @right = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, right: right.to_h }
              end

              # @private
              def to_s
                "(left: #{left.inspect}, right: #{right.inspect})"
              end

              # @private
              def inspect
                "#<Eyes #{self}>"
              end
            end

            ##
            # # Eye
            #
            # The landmarks of an eye in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Eyes}, {Features} and {Face}.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @attr_reader [Landmark] left The eye, left corner.
            # @attr_reader [Landmark] bottom The eye, bottom boundary.
            # @attr_reader [Landmark] center The eye, center.
            # @attr_reader [Landmark] pupil The eye pupil.
            # @attr_reader [Landmark] top The eye, top boundary.
            # @attr_reader [Landmark] right The eye, right corner.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   right_eye = face.features.eyes.right
            #
            #   right_eye.pupil
            #   #<Landmark (x: 256.63464, y: 79.641411, z: -6.0731235)>
            #
            class Eye
              attr_reader :left, :bottom, :center, :pupil, :top, :right

              ##
              # @private Creates a new Eye instance.
              def initialize left, bottom, center, pupil, top, right
                @left   = left
                @bottom = bottom
                @center = center
                @pupil  = pupil
                @top    = top
                @right  = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, top, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, bottom: bottom.to_h, center: center.to_h,
                  pupil: pupil.to_h, top: top.to_h, right: right.to_h }
              end

              # @private
              def to_s
                tmplt = "(left: %s, bottom: %s, center: %s, " \
                          "pupil: %s, top: %s, right: %s)"
                format tmplt, left.inspect, bottom.inspect, center.inspect,
                       pupil.inspect, top.inspect, right.inspect
              end

              # @private
              def inspect
                "#<Eye #{self}>"
              end
            end

            ##
            # # Lips
            #
            # The landmarks of the lips in the features of a face.
            #
            # See {Features} and {Face}.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @attr_reader [Landmark] top The upper lip.
            # @attr_reader [Landmark] bottom The lower lip.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   lips = face.features.lips
            #
            #   lips.top
            #   #<Landmark (x: 228.54768, y: 143.2952, z: -5.6550336)>
            #
            class Lips
              attr_reader :top, :bottom

              alias upper top
              alias lower bottom

              ##
              # @private Creates a new Lips instance.
              def initialize top, bottom
                @top = top
                @bottom = bottom
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [top, bottom]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { top: top.to_h, bottom: bottom.to_h }
              end

              # @private
              def to_s
                "(top: #{top.inspect}, bottom: #{bottom.inspect})"
              end

              # @private
              def inspect
                "#<Lips #{self}>"
              end
            end

            ##
            # # Mouth
            #
            # The landmarks of the mouth in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Features} and {Face}.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @attr_reader [Landmark] left The mouth, left.
            # @attr_reader [Landmark] center The mouth, center.
            # @attr_reader [Landmark] right TThe mouth, right.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   mouth = face.features.mouth
            #
            #   mouth.center
            #   #<Landmark (x: 228.53499, y: 150.29066, z: 1.1069832)>
            #
            class Mouth
              attr_reader :left, :center, :right

              ##
              # @private Creates a new Mouth instance.
              def initialize left, center, right
                @left   = left
                @center = center
                @right  = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, center, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, center: center.to_h, right: right.to_h }
              end

              # @private
              def to_s
                format "(left: %s, center: %s, right: %s)", left.inspect,
                       center.inspect, right.inspect
              end

              # @private
              def inspect
                "#<Mouth #{self}>"
              end
            end

            ##
            # # Nose
            #
            # The landmarks of the nose in the features of a face.
            #
            # Left and right are defined from the vantage of the viewer of the
            # image, without considering mirror projections typical of photos.
            # So `face.features.eyes.left` typically is the person's right eye.
            #
            # See {Features} and {Face}.
            #
            # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Type_1
            #   images.annotate Type
            #
            # @attr_reader [Landmark] left The nose, bottom left.
            # @attr_reader [Landmark] bottom The nose, bottom center.
            # @attr_reader [Landmark] tip The nose tip.
            # @attr_reader [Landmark] top The midpoint between the eyes.
            # @attr_reader [Landmark] right The nose, bottom right.
            #
            # @example
            #   require "google/cloud/vision"
            #
            #   vision = Google::Cloud::Vision.new
            #
            #   image = vision.image "path/to/face.jpg"
            #   face = image.face
            #
            #   nose = face.features.nose
            #
            #   nose.tip
            #   #<Landmark (x: 225.23511, y: 122.47372, z: -25.817825)>
            #
            class Nose
              attr_reader :left, :bottom, :tip, :top, :right

              ##
              # @private Creates a new Nose instance.
              def initialize left, bottom, tip, top, right
                @left   = left
                @bottom = bottom
                @tip    = tip
                @top    = top
                @right  = right
              end

              ##
              # Returns the object's property values as an array.
              #
              # @return [Array]
              #
              def to_a
                [left, bottom, tip, top, right]
              end

              ##
              # Deeply converts object to a hash. All keys will be symbolized.
              #
              # @return [Hash]
              #
              def to_h
                { left: left.to_h, bottom: bottom.to_h, tip: tip.to_h,
                  top: top.to_h, right: right.to_h }
              end

              # @private
              def to_s
                tmplt = "(left: %s, bottom: %s, tip: %s, " \
                          "top: %s, right: %s)"
                format tmplt, left.inspect, bottom.inspect, tip.inspect,
                       top.inspect, right.inspect
              end

              # @private
              def inspect
                "#<Nose #{self}>"
              end
            end
          end

          ##
          # # Likelihood
          #
          # A bucketized representation of likelihood of various separate facial
          # characteristics, meant to give highly stable results across model
          # upgrades.
          #
          # See {Face}.
          #
          # @see https://cloud.google.com/vision/reference/rest/v1/images/annotate#Likelihood
          #   images.annotate Likelihood
          #
          # @example
          #   require "google/cloud/vision"
          #
          #   vision = Google::Cloud::Vision.new
          #
          #   image = vision.image "path/to/face.jpg"
          #   face = image.face
          #
          #   face.likelihood.to_h.count #=> 7
          #   face.likelihood.sorrow? #=> false
          #   face.likelihood.sorrow #=> :VERY_UNLIKELY
          #
          class Likelihood
            POSITIVE_RATINGS = %i[POSSIBLE LIKELY VERY_LIKELY].freeze

            ##
            # @private The FaceAnnotation GRPC object.
            attr_accessor :grpc

            ##
            # @private Creates a new Likelihood instance.
            def initialize
              @grpc = nil
            end

            ##
            # Joy likelihood rating. Possible values are `VERY_UNLIKELY`,
            # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
            def joy
              @grpc.joy_likelihood
            end

            ##
            # Joy likelihood. Returns `true` if {#joy} is `POSSIBLE`, `LIKELY`,
            # or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def joy?
              POSITIVE_RATINGS.include? joy
            end

            ##
            # Sorrow likelihood rating. Possible values are `VERY_UNLIKELY`,
            # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
            def sorrow
              @grpc.sorrow_likelihood
            end

            ##
            # Sorrow likelihood. Returns `true` if {#sorrow} is `POSSIBLE`,
            # `LIKELY`, or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def sorrow?
              POSITIVE_RATINGS.include? sorrow
            end

            ##
            # Joy likelihood rating. Possible values are `VERY_UNLIKELY`,
            # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
            def anger
              @grpc.anger_likelihood
            end

            ##
            # Anger likelihood. Returns `true` if {#anger} is `POSSIBLE`,
            # `LIKELY`, or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def anger?
              POSITIVE_RATINGS.include? anger
            end

            ##
            # Surprise likelihood rating. Possible values are `VERY_UNLIKELY`,
            # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
            def surprise
              @grpc.surprise_likelihood
            end

            ##
            # Surprise likelihood. Returns `true` if {#surprise} is `POSSIBLE`,
            # `LIKELY`, or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def surprise?
              POSITIVE_RATINGS.include? surprise
            end

            ##
            # Under Exposed likelihood rating. Possible values are
            # `VERY_UNLIKELY`, `UNLIKELY`, `POSSIBLE`, `LIKELY`, and
            # `VERY_LIKELY`.
            def under_exposed
              @grpc.under_exposed_likelihood
            end

            ##
            # Under Exposed likelihood. Returns `true` if {#under_exposed} is
            # `POSSIBLE`, `LIKELY`, or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def under_exposed?
              POSITIVE_RATINGS.include? under_exposed
            end

            ##
            # Blurred likelihood rating. Possible values are `VERY_UNLIKELY`,
            # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
            def blurred
              @grpc.blurred_likelihood
            end

            ##
            # Blurred likelihood. Returns `true` if {#blurred} is `POSSIBLE`,
            # `LIKELY`, or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def blurred?
              POSITIVE_RATINGS.include? blurred
            end

            ##
            # Headwear likelihood rating. Possible values are `VERY_UNLIKELY`,
            # `UNLIKELY`, `POSSIBLE`, `LIKELY`, and `VERY_LIKELY`.
            def headwear
              @grpc.headwear_likelihood
            end

            ##
            # Headwear likelihood. Returns `true` if {#headwear} is `POSSIBLE`,
            # `LIKELY`, or `VERY_LIKELY`.
            #
            # @return [Boolean]
            #
            def headwear?
              POSITIVE_RATINGS.include? headwear
            end

            ##
            # Converts object to a hash. All keys will be symbolized.
            #
            # @return [Hash]
            #
            def to_h
              { joy: joy?, sorrow: sorrow?, anger: anger?, surprise: surprise?,
                under_exposed: under_exposed?, blurred: blurred?,
                headwear: headwear? }
            end

            # @private
            def to_s
              tmplt = "(joy?: %s, sorrow?: %s, anger?: %s, " \
                        "surprise?: %s, under_exposed?: %s, blurred?: %s, " \
                        "headwear: %s)"
              format tmplt, joy?.inspect, sorrow?.inspect, anger?.inspect,
                     surprise?.inspect, under_exposed?.inspect,
                     blurred?.inspect, headwear?.inspect
            end

            # @private
            def inspect
              "#<Likelihood #{self}>"
            end

            ##
            # @private New Annotation::Face::Likelihood from a GRPC
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
