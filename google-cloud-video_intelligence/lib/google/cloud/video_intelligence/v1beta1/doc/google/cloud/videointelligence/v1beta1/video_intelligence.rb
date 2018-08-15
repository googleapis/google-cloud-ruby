# Copyright 2018 Google LLC
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
    module Videointelligence
      module V1beta1
        # Video annotation request.
        # @!attribute [rw] input_uri
        #   @return [String]
        #     Input video location. Currently, only
        #     [Google Cloud Storage](https://cloud.google.com/storage/) URIs are
        #     supported, which must be specified in the following format:
        #     +gs://bucket-id/object-id+ (other URI formats return
        #     {Google::Rpc::Code::INVALID_ARGUMENT}). For more information, see
        #     [Request URIs](https://cloud.google.com/storage/docs/reference-uris).
        #     A video URI may include wildcards in +object-id+, and thus identify
        #     multiple videos. Supported wildcards: '*' to match 0 or more characters;
        #     '?' to match 1 character. If unset, the input video should be embedded
        #     in the request as +input_content+. If set, +input_content+ should be unset.
        # @!attribute [rw] input_content
        #   @return [String]
        #     The video data bytes. Encoding: base64. If unset, the input video(s)
        #     should be specified via +input_uri+. If set, +input_uri+ should be unset.
        # @!attribute [rw] features
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::Feature>]
        #     Requested video annotation features.
        # @!attribute [rw] video_context
        #   @return [Google::Cloud::Videointelligence::V1beta1::VideoContext]
        #     Additional video context and/or feature-specific parameters.
        # @!attribute [rw] output_uri
        #   @return [String]
        #     Optional location where the output (in JSON format) should be stored.
        #     Currently, only [Google Cloud Storage](https://cloud.google.com/storage/)
        #     URIs are supported, which must be specified in the following format:
        #     +gs://bucket-id/object-id+ (other URI formats return
        #     {Google::Rpc::Code::INVALID_ARGUMENT}). For more information, see
        #     [Request URIs](https://cloud.google.com/storage/docs/reference-uris).
        # @!attribute [rw] location_id
        #   @return [String]
        #     Optional cloud region where annotation should take place. Supported cloud
        #     regions: +us-east1+, +us-west1+, +europe-west1+, +asia-east1+. If no region
        #     is specified, a region will be determined based on video file location.
        class AnnotateVideoRequest; end

        # Video context and/or feature-specific parameters.
        # @!attribute [rw] segments
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::VideoSegment>]
        #     Video segments to annotate. The segments may overlap and are not required
        #     to be contiguous or span the whole video. If unspecified, each video
        #     is treated as a single segment.
        # @!attribute [rw] label_detection_mode
        #   @return [Google::Cloud::Videointelligence::V1beta1::LabelDetectionMode]
        #     If label detection has been requested, what labels should be detected
        #     in addition to video-level labels or segment-level labels. If unspecified,
        #     defaults to +SHOT_MODE+.
        # @!attribute [rw] stationary_camera
        #   @return [true, false]
        #     Whether the video has been shot from a stationary (i.e. non-moving) camera.
        #     When set to true, might improve detection accuracy for moving objects.
        # @!attribute [rw] label_detection_model
        #   @return [String]
        #     Model to use for label detection.
        #     Supported values: "latest" and "stable" (the default).
        # @!attribute [rw] face_detection_model
        #   @return [String]
        #     Model to use for face detection.
        #     Supported values: "latest" and "stable" (the default).
        # @!attribute [rw] shot_change_detection_model
        #   @return [String]
        #     Model to use for shot change detection.
        #     Supported values: "latest" and "stable" (the default).
        # @!attribute [rw] safe_search_detection_model
        #   @return [String]
        #     Model to use for safe search detection.
        #     Supported values: "latest" and "stable" (the default).
        class VideoContext; end

        # Video segment.
        # @!attribute [rw] start_time_offset
        #   @return [Integer]
        #     Start offset in microseconds (inclusive). Unset means 0.
        # @!attribute [rw] end_time_offset
        #   @return [Integer]
        #     End offset in microseconds (inclusive). Unset means 0.
        class VideoSegment; end

        # Label location.
        # @!attribute [rw] segment
        #   @return [Google::Cloud::Videointelligence::V1beta1::VideoSegment]
        #     Video segment. Set to [-1, -1] for video-level labels.
        #     Set to [timestamp, timestamp] for frame-level labels.
        #     Otherwise, corresponds to one of +AnnotateSpec.segments+
        #     (if specified) or to shot boundaries (if requested).
        # @!attribute [rw] confidence
        #   @return [Float]
        #     Confidence that the label is accurate. Range: [0, 1].
        # @!attribute [rw] level
        #   @return [Google::Cloud::Videointelligence::V1beta1::LabelLevel]
        #     Label level.
        class LabelLocation; end

        # Label annotation.
        # @!attribute [rw] description
        #   @return [String]
        #     Textual description, e.g. +Fixed-gear bicycle+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Language code for +description+ in BCP-47 format.
        # @!attribute [rw] locations
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::LabelLocation>]
        #     Where the label was detected and with what confidence.
        class LabelAnnotation; end

        # Safe search annotation (based on per-frame visual signals only).
        # If no unsafe content has been detected in a frame, no annotations
        # are present for that frame. If only some types of unsafe content
        # have been detected in a frame, the likelihood is set to +UNKNOWN+
        # for all other types of unsafe content.
        # @!attribute [rw] adult
        #   @return [Google::Cloud::Videointelligence::V1beta1::Likelihood]
        #     Likelihood of adult content.
        # @!attribute [rw] spoof
        #   @return [Google::Cloud::Videointelligence::V1beta1::Likelihood]
        #     Likelihood that an obvious modification was made to the original
        #     version to make it appear funny or offensive.
        # @!attribute [rw] medical
        #   @return [Google::Cloud::Videointelligence::V1beta1::Likelihood]
        #     Likelihood of medical content.
        # @!attribute [rw] violent
        #   @return [Google::Cloud::Videointelligence::V1beta1::Likelihood]
        #     Likelihood of violent content.
        # @!attribute [rw] racy
        #   @return [Google::Cloud::Videointelligence::V1beta1::Likelihood]
        #     Likelihood of racy content.
        # @!attribute [rw] time_offset
        #   @return [Integer]
        #     Video time offset in microseconds.
        class SafeSearchAnnotation; end

        # Bounding box.
        # @!attribute [rw] left
        #   @return [Integer]
        #     Left X coordinate.
        # @!attribute [rw] right
        #   @return [Integer]
        #     Right X coordinate.
        # @!attribute [rw] bottom
        #   @return [Integer]
        #     Bottom Y coordinate.
        # @!attribute [rw] top
        #   @return [Integer]
        #     Top Y coordinate.
        class BoundingBox; end

        # Face location.
        # @!attribute [rw] bounding_box
        #   @return [Google::Cloud::Videointelligence::V1beta1::BoundingBox]
        #     Bounding box in a frame.
        # @!attribute [rw] time_offset
        #   @return [Integer]
        #     Video time offset in microseconds.
        class FaceLocation; end

        # Face annotation.
        # @!attribute [rw] thumbnail
        #   @return [String]
        #     Thumbnail of a representative face view (in JPEG format). Encoding: base64.
        # @!attribute [rw] segments
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::VideoSegment>]
        #     All locations where a face was detected.
        #     Faces are detected and tracked on a per-video basis
        #     (as opposed to across multiple videos).
        # @!attribute [rw] locations
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::FaceLocation>]
        #     Face locations at one frame per second.
        class FaceAnnotation; end

        # Annotation results for a single video.
        # @!attribute [rw] input_uri
        #   @return [String]
        #     Video file location in
        #     [Google Cloud Storage](https://cloud.google.com/storage/).
        # @!attribute [rw] label_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::LabelAnnotation>]
        #     Label annotations. There is exactly one element for each unique label.
        # @!attribute [rw] face_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::FaceAnnotation>]
        #     Face annotations. There is exactly one element for each unique face.
        # @!attribute [rw] shot_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::VideoSegment>]
        #     Shot annotations. Each shot is represented as a video segment.
        # @!attribute [rw] safe_search_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::SafeSearchAnnotation>]
        #     Safe search annotations.
        # @!attribute [rw] error
        #   @return [Google::Rpc::Status]
        #     If set, indicates an error. Note that for a single +AnnotateVideoRequest+
        #     some videos may succeed and some may fail.
        class VideoAnnotationResults; end

        # Video annotation response. Included in the +response+
        # field of the +Operation+ returned by the +GetOperation+
        # call of the +google::longrunning::Operations+ service.
        # @!attribute [rw] annotation_results
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::VideoAnnotationResults>]
        #     Annotation results for all videos specified in +AnnotateVideoRequest+.
        class AnnotateVideoResponse; end

        # Annotation progress for a single video.
        # @!attribute [rw] input_uri
        #   @return [String]
        #     Video file location in
        #     [Google Cloud Storage](https://cloud.google.com/storage/).
        # @!attribute [rw] progress_percent
        #   @return [Integer]
        #     Approximate percentage processed thus far.
        #     Guaranteed to be 100 when fully processed.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time when the request was received.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time of the most recent update.
        class VideoAnnotationProgress; end

        # Video annotation progress. Included in the +metadata+
        # field of the +Operation+ returned by the +GetOperation+
        # call of the +google::longrunning::Operations+ service.
        # @!attribute [rw] annotation_progress
        #   @return [Array<Google::Cloud::Videointelligence::V1beta1::VideoAnnotationProgress>]
        #     Progress metadata for all videos specified in +AnnotateVideoRequest+.
        class AnnotateVideoProgress; end

        # Video annotation feature.
        module Feature
          # Unspecified.
          FEATURE_UNSPECIFIED = 0

          # Label detection. Detect objects, such as dog or flower.
          LABEL_DETECTION = 1

          # Human face detection and tracking.
          FACE_DETECTION = 2

          # Shot change detection.
          SHOT_CHANGE_DETECTION = 3

          # Safe search detection.
          SAFE_SEARCH_DETECTION = 4
        end

        # Label level (scope).
        module LabelLevel
          # Unspecified.
          LABEL_LEVEL_UNSPECIFIED = 0

          # Video-level. Corresponds to the whole video.
          VIDEO_LEVEL = 1

          # Segment-level. Corresponds to one of +AnnotateSpec.segments+.
          SEGMENT_LEVEL = 2

          # Shot-level. Corresponds to a single shot (i.e. a series of frames
          # without a major camera position or background change).
          SHOT_LEVEL = 3

          # Frame-level. Corresponds to a single video frame.
          FRAME_LEVEL = 4
        end

        # Label detection mode.
        module LabelDetectionMode
          # Unspecified.
          LABEL_DETECTION_MODE_UNSPECIFIED = 0

          # Detect shot-level labels.
          SHOT_MODE = 1

          # Detect frame-level labels.
          FRAME_MODE = 2

          # Detect both shot-level and frame-level labels.
          SHOT_AND_FRAME_MODE = 3
        end

        # Bucketized representation of likelihood.
        module Likelihood
          # Unknown likelihood.
          UNKNOWN = 0

          # Very unlikely.
          VERY_UNLIKELY = 1

          # Unlikely.
          UNLIKELY = 2

          # Possible.
          POSSIBLE = 3

          # Likely.
          LIKELY = 4

          # Very likely.
          VERY_LIKELY = 5
        end
      end
    end
  end
end