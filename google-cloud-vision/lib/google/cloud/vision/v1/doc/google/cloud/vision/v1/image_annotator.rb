# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
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
        # The <em>Feature</em> indicates what type of image detection task to perform.
        # Users describe the type of Google Cloud Vision API tasks to perform over
        # images by using <em>Feature</em>s. Features encode the Cloud Vision API
        # vertical to operate on and the number of top-scoring results to return.
        # @!attribute [rw] type
        #   @return [Google::Cloud::Vision::V1::Feature::Type]
        #     The feature type.
        # @!attribute [rw] max_results
        #   @return [Integer]
        #     Maximum number of results of this type.
        class Feature
          # Type of image feature.
          module Type
            # Unspecified feature type.
            TYPE_UNSPECIFIED = 0

            # Run face detection.
            FACE_DETECTION = 1

            # Run landmark detection.
            LANDMARK_DETECTION = 2

            # Run logo detection.
            LOGO_DETECTION = 3

            # Run label detection.
            LABEL_DETECTION = 4

            # Run OCR.
            TEXT_DETECTION = 5

            # Run various computer vision models to compute image safe-search properties.
            SAFE_SEARCH_DETECTION = 6

            # Compute a set of properties about the image (such as the image's dominant colors).
            IMAGE_PROPERTIES = 7
          end
        end

        # External image source (Google Cloud Storage image location).
        # @!attribute [rw] gcs_image_uri
        #   @return [String]
        #     Google Cloud Storage image URI. It must be in the following form:
        #     +gs://bucket_name/object_name+. For more
        #     details, please see: https://cloud.google.com/storage/docs/reference-uris.
        #     NOTE: Cloud Storage object versioning is not supported!
        class ImageSource; end

        # Client image to perform Google Cloud Vision API tasks over.
        # @!attribute [rw] content
        #   @return [String]
        #     Image content, represented as a stream of bytes.
        #     Note: as with all +bytes+ fields, protobuffers use a pure binary
        #     representation, whereas JSON representations use base64.
        # @!attribute [rw] source
        #   @return [Google::Cloud::Vision::V1::ImageSource]
        #     Google Cloud Storage image location. If both 'content' and 'source'
        #     are filled for an image, 'content' takes precedence and it will be
        #     used for performing the image annotation request.
        class Image; end

        # A face annotation object contains the results of face detection.
        # @!attribute [rw] bounding_poly
        #   @return [Google::Cloud::Vision::V1::BoundingPoly]
        #     The bounding polygon around the face. The coordinates of the bounding box
        #     are in the original image's scale, as returned in ImageParams.
        #     The bounding box is computed to "frame" the face in accordance with human
        #     expectations. It is based on the landmarker results.
        #     Note that one or more x and/or y coordinates may not be generated in the
        #     BoundingPoly (the polygon will be unbounded) if only a partial face appears in
        #     the image to be annotated.
        # @!attribute [rw] fd_bounding_poly
        #   @return [Google::Cloud::Vision::V1::BoundingPoly]
        #     This bounding polygon is tighter than the previous
        #     <code>boundingPoly</code>, and
        #     encloses only the skin part of the face. Typically, it is used to
        #     eliminate the face from any image analysis that detects the
        #     "amount of skin" visible in an image. It is not based on the
        #     landmarker results, only on the initial face detection, hence
        #     the <code>fd</code> (face detection) prefix.
        # @!attribute [rw] landmarks
        #   @return [Array<Google::Cloud::Vision::V1::FaceAnnotation::Landmark>]
        #     Detected face landmarks.
        # @!attribute [rw] roll_angle
        #   @return [Float]
        #     Roll angle. Indicates the amount of clockwise/anti-clockwise rotation of
        #     the
        #     face relative to the image vertical, about the axis perpendicular to the
        #     face. Range [-180,180].
        # @!attribute [rw] pan_angle
        #   @return [Float]
        #     Yaw angle. Indicates the leftward/rightward angle that the face is
        #     pointing, relative to the vertical plane perpendicular to the image. Range
        #     [-180,180].
        # @!attribute [rw] tilt_angle
        #   @return [Float]
        #     Pitch angle. Indicates the upwards/downwards angle that the face is
        #     pointing
        #     relative to the image's horizontal plane. Range [-180,180].
        # @!attribute [rw] detection_confidence
        #   @return [Float]
        #     Detection confidence. Range [0, 1].
        # @!attribute [rw] landmarking_confidence
        #   @return [Float]
        #     Face landmarking confidence. Range [0, 1].
        # @!attribute [rw] joy_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Joy likelihood.
        # @!attribute [rw] sorrow_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Sorrow likelihood.
        # @!attribute [rw] anger_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Anger likelihood.
        # @!attribute [rw] surprise_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Surprise likelihood.
        # @!attribute [rw] under_exposed_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Under-exposed likelihood.
        # @!attribute [rw] blurred_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Blurred likelihood.
        # @!attribute [rw] headwear_likelihood
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Headwear likelihood.
        class FaceAnnotation
          # A face-specific landmark (for example, a face feature).
          # Landmark positions may fall outside the bounds of the image
          # when the face is near one or more edges of the image.
          # Therefore it is NOT guaranteed that 0 <= x < width or 0 <= y < height.
          # @!attribute [rw] type
          #   @return [Google::Cloud::Vision::V1::FaceAnnotation::Landmark::Type]
          #     Face landmark type.
          # @!attribute [rw] position
          #   @return [Google::Cloud::Vision::V1::Position]
          #     Face landmark position.
          class Landmark
            # Face landmark (feature) type.
            # Left and right are defined from the vantage of the viewer of the image,
            # without considering mirror projections typical of photos. So, LEFT_EYE,
            # typically is the person's right eye.
            module Type
              # Unknown face landmark detected. Should not be filled.
              UNKNOWN_LANDMARK = 0

              # Left eye.
              LEFT_EYE = 1

              # Right eye.
              RIGHT_EYE = 2

              # Left of left eyebrow.
              LEFT_OF_LEFT_EYEBROW = 3

              # Right of left eyebrow.
              RIGHT_OF_LEFT_EYEBROW = 4

              # Left of right eyebrow.
              LEFT_OF_RIGHT_EYEBROW = 5

              # Right of right eyebrow.
              RIGHT_OF_RIGHT_EYEBROW = 6

              # Midpoint between eyes.
              MIDPOINT_BETWEEN_EYES = 7

              # Nose tip.
              NOSE_TIP = 8

              # Upper lip.
              UPPER_LIP = 9

              # Lower lip.
              LOWER_LIP = 10

              # Mouth left.
              MOUTH_LEFT = 11

              # Mouth right.
              MOUTH_RIGHT = 12

              # Mouth center.
              MOUTH_CENTER = 13

              # Nose, bottom right.
              NOSE_BOTTOM_RIGHT = 14

              # Nose, bottom left.
              NOSE_BOTTOM_LEFT = 15

              # Nose, bottom center.
              NOSE_BOTTOM_CENTER = 16

              # Left eye, top boundary.
              LEFT_EYE_TOP_BOUNDARY = 17

              # Left eye, right corner.
              LEFT_EYE_RIGHT_CORNER = 18

              # Left eye, bottom boundary.
              LEFT_EYE_BOTTOM_BOUNDARY = 19

              # Left eye, left corner.
              LEFT_EYE_LEFT_CORNER = 20

              # Right eye, top boundary.
              RIGHT_EYE_TOP_BOUNDARY = 21

              # Right eye, right corner.
              RIGHT_EYE_RIGHT_CORNER = 22

              # Right eye, bottom boundary.
              RIGHT_EYE_BOTTOM_BOUNDARY = 23

              # Right eye, left corner.
              RIGHT_EYE_LEFT_CORNER = 24

              # Left eyebrow, upper midpoint.
              LEFT_EYEBROW_UPPER_MIDPOINT = 25

              # Right eyebrow, upper midpoint.
              RIGHT_EYEBROW_UPPER_MIDPOINT = 26

              # Left ear tragion.
              LEFT_EAR_TRAGION = 27

              # Right ear tragion.
              RIGHT_EAR_TRAGION = 28

              # Left eye pupil.
              LEFT_EYE_PUPIL = 29

              # Right eye pupil.
              RIGHT_EYE_PUPIL = 30

              # Forehead glabella.
              FOREHEAD_GLABELLA = 31

              # Chin gnathion.
              CHIN_GNATHION = 32

              # Chin left gonion.
              CHIN_LEFT_GONION = 33

              # Chin right gonion.
              CHIN_RIGHT_GONION = 34
            end
          end
        end

        # Detected entity location information.
        # @!attribute [rw] lat_lng
        #   @return [Google::Type::LatLng]
        #     Lat - long location coordinates.
        class LocationInfo; end

        # Arbitrary name/value pair.
        # @!attribute [rw] name
        #   @return [String]
        #     Name of the property.
        # @!attribute [rw] value
        #   @return [String]
        #     Value of the property.
        class Property; end

        # Set of detected entity features.
        # @!attribute [rw] mid
        #   @return [String]
        #     Opaque entity ID. Some IDs might be available in Knowledge Graph(KG).
        #     For more details on KG please see:
        #     https://developers.google.com/knowledge-graph/
        # @!attribute [rw] locale
        #   @return [String]
        #     The language code for the locale in which the entity textual
        #     <code>description</code> (next field) is expressed.
        # @!attribute [rw] description
        #   @return [String]
        #     Entity textual description, expressed in its <code>locale</code> language.
        # @!attribute [rw] score
        #   @return [Float]
        #     Overall score of the result. Range [0, 1].
        # @!attribute [rw] confidence
        #   @return [Float]
        #     The accuracy of the entity detection in an image.
        #     For example, for an image containing 'Eiffel Tower,' this field represents
        #     the confidence that there is a tower in the query image. Range [0, 1].
        # @!attribute [rw] topicality
        #   @return [Float]
        #     The relevancy of the ICA (Image Content Annotation) label to the
        #     image. For example, the relevancy of 'tower' to an image containing
        #     'Eiffel Tower' is likely higher than an image containing a distant towering
        #     building, though the confidence that there is a tower may be the same.
        #     Range [0, 1].
        # @!attribute [rw] bounding_poly
        #   @return [Google::Cloud::Vision::V1::BoundingPoly]
        #     Image region to which this entity belongs. Not filled currently
        #     for +LABEL_DETECTION+ features. For +TEXT_DETECTION+ (OCR), +boundingPoly+s
        #     are produced for the entire text detected in an image region, followed by
        #     +boundingPoly+s for each word within the detected text.
        # @!attribute [rw] locations
        #   @return [Array<Google::Cloud::Vision::V1::LocationInfo>]
        #     The location information for the detected entity. Multiple
        #     <code>LocationInfo</code> elements can be present since one location may
        #     indicate the location of the scene in the query image, and another the
        #     location of the place where the query image was taken. Location information
        #     is usually present for landmarks.
        # @!attribute [rw] properties
        #   @return [Array<Google::Cloud::Vision::V1::Property>]
        #     Some entities can have additional optional <code>Property</code> fields.
        #     For example a different kind of score or string that qualifies the entity.
        class EntityAnnotation; end

        # Set of features pertaining to the image, computed by various computer vision
        # methods over safe-search verticals (for example, adult, spoof, medical,
        # violence).
        # @!attribute [rw] adult
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Represents the adult contents likelihood for the image.
        # @!attribute [rw] spoof
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Spoof likelihood. The likelihood that an obvious modification
        #     was made to the image's canonical version to make it appear
        #     funny or offensive.
        # @!attribute [rw] medical
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Likelihood this is a medical image.
        # @!attribute [rw] violence
        #   @return [Google::Cloud::Vision::V1::Likelihood]
        #     Violence likelihood.
        class SafeSearchAnnotation; end

        # Rectangle determined by min and max LatLng pairs.
        # @!attribute [rw] min_lat_lng
        #   @return [Google::Type::LatLng]
        #     Min lat/long pair.
        # @!attribute [rw] max_lat_lng
        #   @return [Google::Type::LatLng]
        #     Max lat/long pair.
        class LatLongRect; end

        # Color information consists of RGB channels, score and fraction of
        # image the color occupies in the image.
        # @!attribute [rw] color
        #   @return [Google::Type::Color]
        #     RGB components of the color.
        # @!attribute [rw] score
        #   @return [Float]
        #     Image-specific score for this color. Value in range [0, 1].
        # @!attribute [rw] pixel_fraction
        #   @return [Float]
        #     Stores the fraction of pixels the color occupies in the image.
        #     Value in range [0, 1].
        class ColorInfo; end

        # Set of dominant colors and their corresponding scores.
        # @!attribute [rw] colors
        #   @return [Array<Google::Cloud::Vision::V1::ColorInfo>]
        #     RGB color values, with their score and pixel fraction.
        class DominantColorsAnnotation; end

        # Stores image properties (e.g. dominant colors).
        # @!attribute [rw] dominant_colors
        #   @return [Google::Cloud::Vision::V1::DominantColorsAnnotation]
        #     If present, dominant colors completed successfully.
        class ImageProperties; end

        # Image context.
        # @!attribute [rw] lat_long_rect
        #   @return [Google::Cloud::Vision::V1::LatLongRect]
        #     Lat/long rectangle that specifies the location of the image.
        # @!attribute [rw] language_hints
        #   @return [Array<String>]
        #     List of languages to use for TEXT_DETECTION. In most cases, an empty value
        #     yields the best results since it enables automatic language detection. For
        #     languages based on the Latin alphabet, setting +language_hints+ is not
        #     needed. In rare cases, when the language of the text in the image is known,
        #     setting a hint will help get better results (although it will be a
        #     significant hindrance if the hint is wrong). Text detection returns an
        #     error if one or more of the specified languages is not one of the
        #     {supported
        #     languages}[https://cloud.google.com/translate/v2/translate-reference#supported_languages].
        class ImageContext; end

        # Request for performing Google Cloud Vision API tasks over a user-provided
        # image, with user-requested features.
        # @!attribute [rw] image
        #   @return [Google::Cloud::Vision::V1::Image]
        #     The image to be processed.
        # @!attribute [rw] features
        #   @return [Array<Google::Cloud::Vision::V1::Feature>]
        #     Requested features.
        # @!attribute [rw] image_context
        #   @return [Google::Cloud::Vision::V1::ImageContext]
        #     Additional context that may accompany the image.
        class AnnotateImageRequest; end

        # Response to an image annotation request.
        # @!attribute [rw] face_annotations
        #   @return [Array<Google::Cloud::Vision::V1::FaceAnnotation>]
        #     If present, face detection completed successfully.
        # @!attribute [rw] landmark_annotations
        #   @return [Array<Google::Cloud::Vision::V1::EntityAnnotation>]
        #     If present, landmark detection completed successfully.
        # @!attribute [rw] logo_annotations
        #   @return [Array<Google::Cloud::Vision::V1::EntityAnnotation>]
        #     If present, logo detection completed successfully.
        # @!attribute [rw] label_annotations
        #   @return [Array<Google::Cloud::Vision::V1::EntityAnnotation>]
        #     If present, label detection completed successfully.
        # @!attribute [rw] text_annotations
        #   @return [Array<Google::Cloud::Vision::V1::EntityAnnotation>]
        #     If present, text (OCR) detection completed successfully.
        # @!attribute [rw] safe_search_annotation
        #   @return [Google::Cloud::Vision::V1::SafeSearchAnnotation]
        #     If present, safe-search annotation completed successfully.
        # @!attribute [rw] image_properties_annotation
        #   @return [Google::Cloud::Vision::V1::ImageProperties]
        #     If present, image properties were extracted successfully.
        # @!attribute [rw] error
        #   @return [Google::Rpc::Status]
        #     If set, represents the error message for the operation.
        #     Note that filled-in mage annotations are guaranteed to be
        #     correct, even when <code>error</code> is non-empty.
        class AnnotateImageResponse; end

        # Multiple image annotation requests are batched into a single service call.
        # @!attribute [rw] requests
        #   @return [Array<Google::Cloud::Vision::V1::AnnotateImageRequest>]
        #     Individual image annotation requests for this batch.
        class BatchAnnotateImagesRequest; end

        # Response to a batch image annotation request.
        # @!attribute [rw] responses
        #   @return [Array<Google::Cloud::Vision::V1::AnnotateImageResponse>]
        #     Individual responses to image annotation requests within the batch.
        class BatchAnnotateImagesResponse; end

        # A bucketized representation of likelihood meant to give our clients highly
        # stable results across model upgrades.
        module Likelihood
          # Unknown likelihood.
          UNKNOWN = 0

          # The image very unlikely belongs to the vertical specified.
          VERY_UNLIKELY = 1

          # The image unlikely belongs to the vertical specified.
          UNLIKELY = 2

          # The image possibly belongs to the vertical specified.
          POSSIBLE = 3

          # The image likely belongs to the vertical specified.
          LIKELY = 4

          # The image very likely belongs to the vertical specified.
          VERY_LIKELY = 5
        end
      end
    end
  end
end
