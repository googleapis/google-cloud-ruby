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
      module V1
        # Video annotation request.
        # @!attribute [rw] input_uri
        #   @return [String]
        #     Input video location. Currently, only
        #     [Google Cloud Storage](https://cloud.google.com/storage/) URIs are
        #     supported, which must be specified in the following format:
        #     `gs://bucket-id/object-id` (other URI formats return
        #     {Google::Rpc::Code::INVALID_ARGUMENT}). For more information, see
        #     [Request URIs](https://cloud.google.com/storage/docs/reference-uris).
        #     A video URI may include wildcards in `object-id`, and thus identify
        #     multiple videos. Supported wildcards: '*' to match 0 or more characters;
        #     '?' to match 1 character. If unset, the input video should be embedded
        #     in the request as `input_content`. If set, `input_content` should be unset.
        # @!attribute [rw] input_content
        #   @return [String]
        #     The video data bytes.
        #     If unset, the input video(s) should be specified via `input_uri`.
        #     If set, `input_uri` should be unset.
        # @!attribute [rw] features
        #   @return [Array<Google::Cloud::Videointelligence::V1::Feature>]
        #     Requested video annotation features.
        # @!attribute [rw] video_context
        #   @return [Google::Cloud::Videointelligence::V1::VideoContext]
        #     Additional video context and/or feature-specific parameters.
        # @!attribute [rw] output_uri
        #   @return [String]
        #     Optional location where the output (in JSON format) should be stored.
        #     Currently, only [Google Cloud Storage](https://cloud.google.com/storage/)
        #     URIs are supported, which must be specified in the following format:
        #     `gs://bucket-id/object-id` (other URI formats return
        #     {Google::Rpc::Code::INVALID_ARGUMENT}). For more information, see
        #     [Request URIs](https://cloud.google.com/storage/docs/reference-uris).
        # @!attribute [rw] location_id
        #   @return [String]
        #     Optional cloud region where annotation should take place. Supported cloud
        #     regions: `us-east1`, `us-west1`, `europe-west1`, `asia-east1`. If no region
        #     is specified, a region will be determined based on video file location.
        class AnnotateVideoRequest; end

        # Video context and/or feature-specific parameters.
        # @!attribute [rw] segments
        #   @return [Array<Google::Cloud::Videointelligence::V1::VideoSegment>]
        #     Video segments to annotate. The segments may overlap and are not required
        #     to be contiguous or span the whole video. If unspecified, each video is
        #     treated as a single segment.
        # @!attribute [rw] label_detection_config
        #   @return [Google::Cloud::Videointelligence::V1::LabelDetectionConfig]
        #     Config for LABEL_DETECTION.
        # @!attribute [rw] shot_change_detection_config
        #   @return [Google::Cloud::Videointelligence::V1::ShotChangeDetectionConfig]
        #     Config for SHOT_CHANGE_DETECTION.
        # @!attribute [rw] explicit_content_detection_config
        #   @return [Google::Cloud::Videointelligence::V1::ExplicitContentDetectionConfig]
        #     Config for EXPLICIT_CONTENT_DETECTION.
        # @!attribute [rw] face_detection_config
        #   @return [Google::Cloud::Videointelligence::V1::FaceDetectionConfig]
        #     Config for FACE_DETECTION.
        # @!attribute [rw] speech_transcription_config
        #   @return [Google::Cloud::Videointelligence::V1::SpeechTranscriptionConfig]
        #     Config for SPEECH_TRANSCRIPTION.
        class VideoContext; end

        # Config for LABEL_DETECTION.
        # @!attribute [rw] label_detection_mode
        #   @return [Google::Cloud::Videointelligence::V1::LabelDetectionMode]
        #     What labels should be detected with LABEL_DETECTION, in addition to
        #     video-level labels or segment-level labels.
        #     If unspecified, defaults to `SHOT_MODE`.
        # @!attribute [rw] stationary_camera
        #   @return [true, false]
        #     Whether the video has been shot from a stationary (i.e. non-moving) camera.
        #     When set to true, might improve detection accuracy for moving objects.
        #     Should be used with `SHOT_AND_FRAME_MODE` enabled.
        # @!attribute [rw] model
        #   @return [String]
        #     Model to use for label detection.
        #     Supported values: "builtin/stable" (the default if unset) and
        #     "builtin/latest".
        class LabelDetectionConfig; end

        # Config for SHOT_CHANGE_DETECTION.
        # @!attribute [rw] model
        #   @return [String]
        #     Model to use for shot change detection.
        #     Supported values: "builtin/stable" (the default if unset) and
        #     "builtin/latest".
        class ShotChangeDetectionConfig; end

        # Config for EXPLICIT_CONTENT_DETECTION.
        # @!attribute [rw] model
        #   @return [String]
        #     Model to use for explicit content detection.
        #     Supported values: "builtin/stable" (the default if unset) and
        #     "builtin/latest".
        class ExplicitContentDetectionConfig; end

        # Config for FACE_DETECTION.
        # @!attribute [rw] model
        #   @return [String]
        #     Model to use for face detection.
        #     Supported values: "builtin/stable" (the default if unset) and
        #     "builtin/latest".
        # @!attribute [rw] include_bounding_boxes
        #   @return [true, false]
        #     Whether bounding boxes be included in the face annotation output.
        class FaceDetectionConfig; end

        # Video segment.
        # @!attribute [rw] start_time_offset
        #   @return [Google::Protobuf::Duration]
        #     Time-offset, relative to the beginning of the video,
        #     corresponding to the start of the segment (inclusive).
        # @!attribute [rw] end_time_offset
        #   @return [Google::Protobuf::Duration]
        #     Time-offset, relative to the beginning of the video,
        #     corresponding to the end of the segment (inclusive).
        class VideoSegment; end

        # Video segment level annotation results for label detection.
        # @!attribute [rw] segment
        #   @return [Google::Cloud::Videointelligence::V1::VideoSegment]
        #     Video segment where a label was detected.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     Confidence that the label is accurate. Range: [0, 1].
        class LabelSegment; end

        # Video frame level annotation results for label detection.
        # @!attribute [rw] time_offset
        #   @return [Google::Protobuf::Duration]
        #     Time-offset, relative to the beginning of the video, corresponding to the
        #     video frame for this location.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     Confidence that the label is accurate. Range: [0, 1].
        class LabelFrame; end

        # Detected entity from video analysis.
        # @!attribute [rw] entity_id
        #   @return [String]
        #     Opaque entity ID. Some IDs may be available in
        #     [Google Knowledge Graph Search
        #     API](https://developers.google.com/knowledge-graph/).
        # @!attribute [rw] description
        #   @return [String]
        #     Textual description, e.g. `Fixed-gear bicycle`.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Language code for `description` in BCP-47 format.
        class Entity; end

        # Label annotation.
        # @!attribute [rw] entity
        #   @return [Google::Cloud::Videointelligence::V1::Entity]
        #     Detected entity.
        # @!attribute [rw] category_entities
        #   @return [Array<Google::Cloud::Videointelligence::V1::Entity>]
        #     Common categories for the detected entity.
        #     E.g. when the label is `Terrier` the category is likely `dog`. And in some
        #     cases there might be more than one categories e.g. `Terrier` could also be
        #     a `pet`.
        # @!attribute [rw] segments
        #   @return [Array<Google::Cloud::Videointelligence::V1::LabelSegment>]
        #     All video segments where a label was detected.
        # @!attribute [rw] frames
        #   @return [Array<Google::Cloud::Videointelligence::V1::LabelFrame>]
        #     All video frames where a label was detected.
        class LabelAnnotation; end

        # Video frame level annotation results for explicit content.
        # @!attribute [rw] time_offset
        #   @return [Google::Protobuf::Duration]
        #     Time-offset, relative to the beginning of the video, corresponding to the
        #     video frame for this location.
        # @!attribute [rw] pornography_likelihood
        #   @return [Google::Cloud::Videointelligence::V1::Likelihood]
        #     Likelihood of the pornography content..
        class ExplicitContentFrame; end

        # Explicit content annotation (based on per-frame visual signals only).
        # If no explicit content has been detected in a frame, no annotations are
        # present for that frame.
        # @!attribute [rw] frames
        #   @return [Array<Google::Cloud::Videointelligence::V1::ExplicitContentFrame>]
        #     All video frames where explicit content was detected.
        class ExplicitContentAnnotation; end

        # Normalized bounding box.
        # The normalized vertex coordinates are relative to the original image.
        # Range: [0, 1].
        # @!attribute [rw] left
        #   @return [Float]
        #     Left X coordinate.
        # @!attribute [rw] top
        #   @return [Float]
        #     Top Y coordinate.
        # @!attribute [rw] right
        #   @return [Float]
        #     Right X coordinate.
        # @!attribute [rw] bottom
        #   @return [Float]
        #     Bottom Y coordinate.
        class NormalizedBoundingBox; end

        # Video segment level annotation results for face detection.
        # @!attribute [rw] segment
        #   @return [Google::Cloud::Videointelligence::V1::VideoSegment]
        #     Video segment where a face was detected.
        class FaceSegment; end

        # Video frame level annotation results for face detection.
        # @!attribute [rw] normalized_bounding_boxes
        #   @return [Array<Google::Cloud::Videointelligence::V1::NormalizedBoundingBox>]
        #     Normalized Bounding boxes in a frame.
        #     There can be more than one boxes if the same face is detected in multiple
        #     locations within the current frame.
        # @!attribute [rw] time_offset
        #   @return [Google::Protobuf::Duration]
        #     Time-offset, relative to the beginning of the video,
        #     corresponding to the video frame for this location.
        class FaceFrame; end

        # Face annotation.
        # @!attribute [rw] thumbnail
        #   @return [String]
        #     Thumbnail of a representative face view (in JPEG format).
        # @!attribute [rw] segments
        #   @return [Array<Google::Cloud::Videointelligence::V1::FaceSegment>]
        #     All video segments where a face was detected.
        # @!attribute [rw] frames
        #   @return [Array<Google::Cloud::Videointelligence::V1::FaceFrame>]
        #     All video frames where a face was detected.
        class FaceAnnotation; end

        # Annotation results for a single video.
        # @!attribute [rw] input_uri
        #   @return [String]
        #     Video file location in
        #     [Google Cloud Storage](https://cloud.google.com/storage/).
        # @!attribute [rw] segment_label_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1::LabelAnnotation>]
        #     Label annotations on video level or user specified segment level.
        #     There is exactly one element for each unique label.
        # @!attribute [rw] shot_label_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1::LabelAnnotation>]
        #     Label annotations on shot level.
        #     There is exactly one element for each unique label.
        # @!attribute [rw] frame_label_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1::LabelAnnotation>]
        #     Label annotations on frame level.
        #     There is exactly one element for each unique label.
        # @!attribute [rw] face_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1::FaceAnnotation>]
        #     Face annotations. There is exactly one element for each unique face.
        # @!attribute [rw] shot_annotations
        #   @return [Array<Google::Cloud::Videointelligence::V1::VideoSegment>]
        #     Shot annotations. Each shot is represented as a video segment.
        # @!attribute [rw] explicit_annotation
        #   @return [Google::Cloud::Videointelligence::V1::ExplicitContentAnnotation]
        #     Explicit content annotation.
        # @!attribute [rw] speech_transcriptions
        #   @return [Array<Google::Cloud::Videointelligence::V1::SpeechTranscription>]
        #     Speech transcription.
        # @!attribute [rw] error
        #   @return [Google::Rpc::Status]
        #     If set, indicates an error. Note that for a single `AnnotateVideoRequest`
        #     some videos may succeed and some may fail.
        class VideoAnnotationResults; end

        # Video annotation response. Included in the `response`
        # field of the `Operation` returned by the `GetOperation`
        # call of the `google::longrunning::Operations` service.
        # @!attribute [rw] annotation_results
        #   @return [Array<Google::Cloud::Videointelligence::V1::VideoAnnotationResults>]
        #     Annotation results for all videos specified in `AnnotateVideoRequest`.
        class AnnotateVideoResponse; end

        # Annotation progress for a single video.
        # @!attribute [rw] input_uri
        #   @return [String]
        #     Video file location in
        #     [Google Cloud Storage](https://cloud.google.com/storage/).
        # @!attribute [rw] progress_percent
        #   @return [Integer]
        #     Approximate percentage processed thus far. Guaranteed to be
        #     100 when fully processed.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time when the request was received.
        # @!attribute [rw] update_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time of the most recent update.
        class VideoAnnotationProgress; end

        # Video annotation progress. Included in the `metadata`
        # field of the `Operation` returned by the `GetOperation`
        # call of the `google::longrunning::Operations` service.
        # @!attribute [rw] annotation_progress
        #   @return [Array<Google::Cloud::Videointelligence::V1::VideoAnnotationProgress>]
        #     Progress metadata for all videos specified in `AnnotateVideoRequest`.
        class AnnotateVideoProgress; end

        # Config for SPEECH_TRANSCRIPTION.
        # @!attribute [rw] language_code
        #   @return [String]
        #     *Required* The language of the supplied audio as a
        #     [BCP-47](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) language tag.
        #     Example: "en-US".
        #     See [Language Support](https://cloud.google.com/speech/docs/languages)
        #     for a list of the currently supported language codes.
        # @!attribute [rw] max_alternatives
        #   @return [Integer]
        #     *Optional* Maximum number of recognition hypotheses to be returned.
        #     Specifically, the maximum number of `SpeechRecognitionAlternative` messages
        #     within each `SpeechTranscription`. The server may return fewer than
        #     `max_alternatives`. Valid values are `0`-`30`. A value of `0` or `1` will
        #     return a maximum of one. If omitted, will return a maximum of one.
        # @!attribute [rw] filter_profanity
        #   @return [true, false]
        #     *Optional* If set to `true`, the server will attempt to filter out
        #     profanities, replacing all but the initial character in each filtered word
        #     with asterisks, e.g. "f***". If set to `false` or omitted, profanities
        #     won't be filtered out.
        # @!attribute [rw] speech_contexts
        #   @return [Array<Google::Cloud::Videointelligence::V1::SpeechContext>]
        #     *Optional* A means to provide context to assist the speech recognition.
        # @!attribute [rw] enable_automatic_punctuation
        #   @return [true, false]
        #     *Optional* If 'true', adds punctuation to recognition result hypotheses.
        #     This feature is only available in select languages. Setting this for
        #     requests in other languages has no effect at all. The default 'false' value
        #     does not add punctuation to result hypotheses. NOTE: "This is currently
        #     offered as an experimental service, complimentary to all users. In the
        #     future this may be exclusively available as a premium feature."
        # @!attribute [rw] audio_tracks
        #   @return [Array<Integer>]
        #     *Optional* For file formats, such as MXF or MKV, supporting multiple audio
        #     tracks, specify up to two tracks. Default: track 0.
        # @!attribute [rw] enable_speaker_diarization
        #   @return [true, false]
        #     *Optional* If 'true', enables speaker detection for each recognized word in
        #     the top alternative of the recognition result using a speaker_tag provided
        #     in the WordInfo.
        #     Note: When this is true, we send all the words from the beginning of the
        #     audio for the top alternative in every consecutive responses.
        #     This is done in order to improve our speaker tags as our models learn to
        #     identify the speakers in the conversation over time.
        # @!attribute [rw] diarization_speaker_count
        #   @return [Integer]
        #     *Optional*
        #     If set, specifies the estimated number of speakers in the conversation.
        #     If not set, defaults to '2'.
        #     Ignored unless enable_speaker_diarization is set to true.
        # @!attribute [rw] enable_word_confidence
        #   @return [true, false]
        #     *Optional* If `true`, the top result includes a list of words and the
        #     confidence for those words. If `false`, no word-level confidence
        #     information is returned. The default is `false`.
        class SpeechTranscriptionConfig; end

        # Provides "hints" to the speech recognizer to favor specific words and phrases
        # in the results.
        # @!attribute [rw] phrases
        #   @return [Array<String>]
        #     *Optional* A list of strings containing words and phrases "hints" so that
        #     the speech recognition is more likely to recognize them. This can be used
        #     to improve the accuracy for specific words and phrases, for example, if
        #     specific commands are typically spoken by the user. This can also be used
        #     to add additional words to the vocabulary of the recognizer. See
        #     [usage limits](https://cloud.google.com/speech/limits#content).
        class SpeechContext; end

        # A speech recognition result corresponding to a portion of the audio.
        # @!attribute [rw] alternatives
        #   @return [Array<Google::Cloud::Videointelligence::V1::SpeechRecognitionAlternative>]
        #     May contain one or more recognition hypotheses (up to the maximum specified
        #     in `max_alternatives`).  These alternatives are ordered in terms of
        #     accuracy, with the top (first) alternative being the most probable, as
        #     ranked by the recognizer.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Output only. The
        #     [BCP-47](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) language tag of the
        #     language in this result. This language code was detected to have the most
        #     likelihood of being spoken in the audio.
        class SpeechTranscription; end

        # Alternative hypotheses (a.k.a. n-best list).
        # @!attribute [rw] transcript
        #   @return [String]
        #     Transcript text representing the words that the user spoke.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     The confidence estimate between 0.0 and 1.0. A higher number
        #     indicates an estimated greater likelihood that the recognized words are
        #     correct. This field is typically provided only for the top hypothesis, and
        #     only for `is_final=true` results. Clients should not rely on the
        #     `confidence` field as it is not guaranteed to be accurate or consistent.
        #     The default of 0.0 is a sentinel value indicating `confidence` was not set.
        # @!attribute [rw] words
        #   @return [Array<Google::Cloud::Videointelligence::V1::WordInfo>]
        #     A list of word-specific information for each recognized word.
        class SpeechRecognitionAlternative; end

        # Word-specific information for recognized words. Word information is only
        # included in the response when certain request parameters are set, such
        # as `enable_word_time_offsets`.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Duration]
        #     Time offset relative to the beginning of the audio, and
        #     corresponding to the start of the spoken word. This field is only set if
        #     `enable_word_time_offsets=true` and only in the top hypothesis. This is an
        #     experimental feature and the accuracy of the time offset can vary.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Duration]
        #     Time offset relative to the beginning of the audio, and
        #     corresponding to the end of the spoken word. This field is only set if
        #     `enable_word_time_offsets=true` and only in the top hypothesis. This is an
        #     experimental feature and the accuracy of the time offset can vary.
        # @!attribute [rw] word
        #   @return [String]
        #     The word corresponding to this set of information.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     Output only. The confidence estimate between 0.0 and 1.0. A higher number
        #     indicates an estimated greater likelihood that the recognized words are
        #     correct. This field is set only for the top alternative.
        #     This field is not guaranteed to be accurate and users should not rely on it
        #     to be always provided.
        #     The default of 0.0 is a sentinel value indicating `confidence` was not set.
        # @!attribute [rw] speaker_tag
        #   @return [Integer]
        #     Output only. A distinct integer value is assigned for every speaker within
        #     the audio. This field specifies which one of those speakers was detected to
        #     have spoken this word. Value ranges from 1 up to diarization_speaker_count,
        #     and is only set if speaker diarization is enabled.
        class WordInfo; end

        # Video annotation feature.
        module Feature
          # Unspecified.
          FEATURE_UNSPECIFIED = 0

          # Label detection. Detect objects, such as dog or flower.
          LABEL_DETECTION = 1

          # Shot change detection.
          SHOT_CHANGE_DETECTION = 2

          # Explicit content detection.
          EXPLICIT_CONTENT_DETECTION = 3

          # Human face detection and tracking.
          FACE_DETECTION = 4

          # Speech transcription.
          SPEECH_TRANSCRIPTION = 6
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
          # Unspecified likelihood.
          LIKELIHOOD_UNSPECIFIED = 0

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