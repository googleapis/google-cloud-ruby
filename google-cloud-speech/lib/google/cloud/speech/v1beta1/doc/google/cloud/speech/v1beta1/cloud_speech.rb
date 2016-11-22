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
    module Speech
      module V1beta1
        # +SyncRecognizeRequest+ is the top-level message sent by the client for
        # the +SyncRecognize+ method.
        # @!attribute [rw] config
        #   @return [Google::Cloud::Speech::V1beta1::RecognitionConfig]
        #     [Required] The +config+ message provides information to the recognizer
        #     that specifies how to process the request.
        # @!attribute [rw] audio
        #   @return [Google::Cloud::Speech::V1beta1::RecognitionAudio]
        #     [Required] The audio data to be recognized.
        class SyncRecognizeRequest; end

        # +AsyncRecognizeRequest+ is the top-level message sent by the client for
        # the +AsyncRecognize+ method.
        # @!attribute [rw] config
        #   @return [Google::Cloud::Speech::V1beta1::RecognitionConfig]
        #     [Required] The +config+ message provides information to the recognizer
        #     that specifies how to process the request.
        # @!attribute [rw] audio
        #   @return [Google::Cloud::Speech::V1beta1::RecognitionAudio]
        #     [Required] The audio data to be recognized.
        class AsyncRecognizeRequest; end

        # +StreamingRecognizeRequest+ is the top-level message sent by the client for
        # the +StreamingRecognize+. Multiple +StreamingRecognizeRequest+ messages are
        # sent. The first message must contain a +streaming_config+ message and must
        # not contain +audio+ data. All subsequent messages must contain +audio+ data
        # and must not contain a +streaming_config+ message.
        # @!attribute [rw] streaming_config
        #   @return [Google::Cloud::Speech::V1beta1::StreamingRecognitionConfig]
        #     The +streaming_config+ message provides information to the recognizer
        #     that specifies how to process the request.
        #
        #     The first +StreamingRecognizeRequest+ message must contain a
        #     +streaming_config+  message.
        # @!attribute [rw] audio_content
        #   @return [String]
        #     The audio data to be recognized. Sequential chunks of audio data are sent
        #     in sequential +StreamingRecognizeRequest+ messages. The first
        #     +StreamingRecognizeRequest+ message must not contain +audio_content+ data
        #     and all subsequent +StreamingRecognizeRequest+ messages must contain
        #     +audio_content+ data. The audio bytes must be encoded as specified in
        #     +RecognitionConfig+. Note: as with all bytes fields, protobuffers use a
        #     pure binary representation (not base64). See
        #     {audio limits}[https://cloud.google.com/speech/limits#content].
        class StreamingRecognizeRequest; end

        # The +StreamingRecognitionConfig+ message provides information to the
        # recognizer that specifies how to process the request.
        # @!attribute [rw] config
        #   @return [Google::Cloud::Speech::V1beta1::RecognitionConfig]
        #     [Required] The +config+ message provides information to the recognizer
        #     that specifies how to process the request.
        # @!attribute [rw] single_utterance
        #   @return [true, false]
        #     [Optional] If +false+ or omitted, the recognizer will perform continuous
        #     recognition (continuing to process audio even if the user pauses speaking)
        #     until the client closes the output stream (gRPC API) or when the maximum
        #     time limit has been reached. Multiple +StreamingRecognitionResult+s with
        #     the +is_final+ flag set to +true+ may be returned.
        #
        #     If +true+, the recognizer will detect a single spoken utterance. When it
        #     detects that the user has paused or stopped speaking, it will return an
        #     +END_OF_UTTERANCE+ event and cease recognition. It will return no more than
        #     one +StreamingRecognitionResult+ with the +is_final+ flag set to +true+.
        # @!attribute [rw] interim_results
        #   @return [true, false]
        #     [Optional] If +true+, interim results (tentative hypotheses) may be
        #     returned as they become available (these interim results are indicated with
        #     the +is_final=false+ flag).
        #     If +false+ or omitted, only +is_final=true+ result(s) are returned.
        class StreamingRecognitionConfig; end

        # The +RecognitionConfig+ message provides information to the recognizer
        # that specifies how to process the request.
        # @!attribute [rw] encoding
        #   @return [Google::Cloud::Speech::V1beta1::RecognitionConfig::AudioEncoding]
        #     [Required] Encoding of audio data sent in all +RecognitionAudio+ messages.
        # @!attribute [rw] sample_rate
        #   @return [Integer]
        #     [Required] Sample rate in Hertz of the audio data sent in all
        #     +RecognitionAudio+ messages. Valid values are: 8000-48000.
        #     16000 is optimal. For best results, set the sampling rate of the audio
        #     source to 16000 Hz. If that's not possible, use the native sample rate of
        #     the audio source (instead of re-sampling).
        # @!attribute [rw] language_code
        #   @return [String]
        #     [Optional] The language of the supplied audio as a BCP-47 language tag.
        #     Example: "en-GB"  https://www.rfc-editor.org/rfc/bcp/bcp47.txt
        #     If omitted, defaults to "en-US". See
        #     {Language Support}[https://cloud.google.com/speech/docs/languages]
        #     for a list of the currently supported language codes.
        # @!attribute [rw] max_alternatives
        #   @return [Integer]
        #     [Optional] Maximum number of recognition hypotheses to be returned.
        #     Specifically, the maximum number of +SpeechRecognitionAlternative+ messages
        #     within each +SpeechRecognitionResult+.
        #     The server may return fewer than +max_alternatives+.
        #     Valid values are +0+-+30+. A value of +0+ or +1+ will return a maximum of
        #     +1+. If omitted, defaults to +1+.
        # @!attribute [rw] profanity_filter
        #   @return [true, false]
        #     [Optional] If set to +true+, the server will attempt to filter out
        #     profanities, replacing all but the initial character in each filtered word
        #     with asterisks, e.g. "f***". If set to +false+ or omitted, profanities
        #     won't be filtered out.
        # @!attribute [rw] speech_context
        #   @return [Google::Cloud::Speech::V1beta1::SpeechContext]
        #     [Optional] A means to provide context to assist the speech recognition.
        class RecognitionConfig
          # Audio encoding of the data sent in the audio message. All encodings support
          # only 1 channel (mono) audio. Only +FLAC+ includes a header that describes
          # the bytes of audio that follow the header. The other encodings are raw
          # audio bytes with no header.
          #
          # For best results, the audio source should be captured and transmitted using
          # a lossless encoding (+FLAC+ or +LINEAR16+). Recognition accuracy may be
          # reduced if lossy codecs (such as AMR, AMR_WB and MULAW) are used to capture
          # or transmit the audio, particularly if background noise is present.
          module AudioEncoding
            # Not specified. Will return result Google::Rpc::Code::INVALID_ARGUMENT.
            ENCODING_UNSPECIFIED = 0

            # Uncompressed 16-bit signed little-endian samples (Linear PCM).
            # This is the only encoding that may be used by +AsyncRecognize+.
            LINEAR16 = 1

            # This is the recommended encoding for +SyncRecognize+ and
            # +StreamingRecognize+ because it uses lossless compression; therefore
            # recognition accuracy is not compromised by a lossy codec.
            #
            # The stream FLAC (Free Lossless Audio Codec) encoding is specified at:
            # http://flac.sourceforge.net/documentation.html.
            # 16-bit and 24-bit samples are supported.
            # Not all fields in STREAMINFO are supported.
            FLAC = 2

            # 8-bit samples that compand 14-bit audio samples using G.711 PCMU/mu-law.
            MULAW = 3

            # Adaptive Multi-Rate Narrowband codec. +sample_rate+ must be 8000 Hz.
            AMR = 4

            # Adaptive Multi-Rate Wideband codec. +sample_rate+ must be 16000 Hz.
            AMR_WB = 5
          end
        end

        # Provides "hints" to the speech recognizer to favor specific words and phrases
        # in the results.
        # @!attribute [rw] phrases
        #   @return [Array<String>]
        #     [Optional] A list of strings containing words and phrases "hints" so that
        #     the speech recognition is more likely to recognize them. This can be used
        #     to improve the accuracy for specific words and phrases, for example, if
        #     specific commands are typically spoken by the user. This can also be used
        #     to add additional words to the vocabulary of the recognizer. See
        #     {usage limits}[https://cloud.google.com/speech/limits#content].
        class SpeechContext; end

        # Contains audio data in the encoding specified in the +RecognitionConfig+.
        # Either +content+ or +uri+ must be supplied. Supplying both or neither
        # returns Google::Rpc::Code::INVALID_ARGUMENT. See
        # {audio limits}[https://cloud.google.com/speech/limits#content].
        # @!attribute [rw] content
        #   @return [String]
        #     The audio data bytes encoded as specified in
        #     +RecognitionConfig+. Note: as with all bytes fields, protobuffers use a
        #     pure binary representation, whereas JSON representations use base64.
        # @!attribute [rw] uri
        #   @return [String]
        #     URI that points to a file that contains audio data bytes as specified in
        #     +RecognitionConfig+. Currently, only Google Cloud Storage URIs are
        #     supported, which must be specified in the following format:
        #     +gs://bucket_name/object_name+ (other URI formats return
        #     Google::Rpc::Code::INVALID_ARGUMENT). For more information, see
        #     {Request URIs}[https://cloud.google.com/storage/docs/reference-uris].
        class RecognitionAudio; end

        # +SyncRecognizeResponse+ is the only message returned to the client by
        # +SyncRecognize+. It contains the result as zero or more sequential
        # +SpeechRecognitionResult+ messages.
        # @!attribute [rw] results
        #   @return [Array<Google::Cloud::Speech::V1beta1::SpeechRecognitionResult>]
        #     [Output-only] Sequential list of transcription results corresponding to
        #     sequential portions of audio.
        class SyncRecognizeResponse; end

        # +AsyncRecognizeResponse+ is the only message returned to the client by
        # +AsyncRecognize+. It contains the result as zero or more sequential
        # +SpeechRecognitionResult+ messages. It is included in the +result.response+
        # field of the +Operation+ returned by the +GetOperation+ call of the
        # +google::longrunning::Operations+ service.
        # @!attribute [rw] results
        #   @return [Array<Google::Cloud::Speech::V1beta1::SpeechRecognitionResult>]
        #     [Output-only] Sequential list of transcription results corresponding to
        #     sequential portions of audio.
        class AsyncRecognizeResponse; end

        # +AsyncRecognizeMetadata+ describes the progress of a long-running
        # +AsyncRecognize+ call. It is included in the +metadata+ field of the
        # +Operation+ returned by the +GetOperation+ call of the
        # +google::longrunning::Operations+ service.
        # @!attribute [rw] progress_percent
        #   @return [Integer]
        #     Approximate percentage of audio processed thus far. Guaranteed to be 100
        #     when the audio is fully processed and the results are available.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time when the request was received.
        # @!attribute [rw] last_update_time
        #   @return [Google::Protobuf::Timestamp]
        #     Time of the most recent processing update.
        class AsyncRecognizeMetadata; end

        # +StreamingRecognizeResponse+ is the only message returned to the client by
        # +StreamingRecognize+. A series of one or more +StreamingRecognizeResponse+
        # messages are streamed back to the client.
        #
        # Here's an example of a series of ten +StreamingRecognizeResponse+s that might
        # be returned while processing audio:
        #
        # 1. endpointer_type: START_OF_SPEECH
        #
        # 2. results { alternatives { transcript: "tube" } stability: 0.01 }
        #    result_index: 0
        #
        # 3. results { alternatives { transcript: "to be a" } stability: 0.01 }
        #    result_index: 0
        #
        # 4. results { alternatives { transcript: "to be" } stability: 0.9 }
        #    results { alternatives { transcript: " or not to be" } stability: 0.01 }
        #    result_index: 0
        #
        # 5. results { alternatives { transcript: "to be or not to be"
        #                             confidence: 0.92 }
        #              alternatives { transcript: "to bee or not to bee" }
        #              is_final: true }
        #    result_index: 0
        #
        # 6. results { alternatives { transcript: " that's" } stability: 0.01 }
        #    result_index: 1
        #
        # 7. results { alternatives { transcript: " that is" } stability: 0.9 }
        #    results { alternatives { transcript: " the question" } stability: 0.01 }
        #    result_index: 1
        #
        # 8. endpointer_type: END_OF_SPEECH
        #
        # 9. results { alternatives { transcript: " that is the question"
        #                             confidence: 0.98 }
        #              alternatives { transcript: " that was the question" }
        #              is_final: true }
        #    result_index: 1
        #
        # 10. endpointer_type: END_OF_AUDIO
        #
        # Notes:
        #
        # - Only two of the above responses #5 and #9 contain final results, they are
        #   indicated by +is_final: true+. Concatenating these together generates the
        #   full transcript: "to be or not to be that is the question".
        #
        # - The others contain interim +results+. #4 and #7 contain two interim
        #   +results+, the first portion has a high stability and is less likely to
        #   change, the second portion has a low stability and is very likely to
        #   change. A UI designer might choose to show only high stability +results+.
        #
        # - The +result_index+ indicates the portion of audio that has had final
        #   results returned, and is no longer being processed. For example, the
        #   +results+ in #6 and later correspond to the portion of audio after
        #   "to be or not to be".
        # @!attribute [rw] error
        #   @return [Google::Rpc::Status]
        #     [Output-only] If set, returns a Google::Rpc::Status message that
        #     specifies the error for the operation.
        # @!attribute [rw] results
        #   @return [Array<Google::Cloud::Speech::V1beta1::StreamingRecognitionResult>]
        #     [Output-only] This repeated list contains zero or more results that
        #     correspond to consecutive portions of the audio currently being processed.
        #     It contains zero or one +is_final=true+ result (the newly settled portion),
        #     followed by zero or more +is_final=false+ results.
        # @!attribute [rw] result_index
        #   @return [Integer]
        #     [Output-only] Indicates the lowest index in the +results+ array that has
        #     changed. The repeated +StreamingRecognitionResult+ results overwrite past
        #     results at this index and higher.
        # @!attribute [rw] endpointer_type
        #   @return [Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse::EndpointerType]
        #     [Output-only] Indicates the type of endpointer event.
        class StreamingRecognizeResponse
          # Indicates the type of endpointer event.
          module EndpointerType
            # No endpointer event specified.
            ENDPOINTER_EVENT_UNSPECIFIED = 0

            # Speech has been detected in the audio stream.
            START_OF_SPEECH = 1

            # Speech has ceased to be detected in the audio stream.
            END_OF_SPEECH = 2

            # The end of the audio stream has been reached. and it is being processed.
            END_OF_AUDIO = 3

            # This event is only sent when +single_utterance+ is +true+. It indicates
            # that the server has detected the end of the user's speech utterance and
            # expects no additional speech. Therefore, the server will not process
            # additional audio. The client should stop sending additional audio data.
            END_OF_UTTERANCE = 4
          end
        end

        # A streaming speech recognition result corresponding to a portion of the audio
        # that is currently being processed.
        # @!attribute [rw] alternatives
        #   @return [Array<Google::Cloud::Speech::V1beta1::SpeechRecognitionAlternative>]
        #     [Output-only] May contain one or more recognition hypotheses (up to the
        #     maximum specified in +max_alternatives+).
        # @!attribute [rw] is_final
        #   @return [true, false]
        #     [Output-only] If +false+, this +StreamingRecognitionResult+ represents an
        #     interim result that may change. If +true+, this is the final time the
        #     speech service will return this particular +StreamingRecognitionResult+,
        #     the recognizer will not return any further hypotheses for this portion of
        #     the transcript and corresponding audio.
        # @!attribute [rw] stability
        #   @return [Float]
        #     [Output-only] An estimate of the probability that the recognizer will not
        #     change its guess about this interim result. Values range from 0.0
        #     (completely unstable) to 1.0 (completely stable). Note that this is not the
        #     same as +confidence+, which estimates the probability that a recognition
        #     result is correct.
        #     This field is only provided for interim results (+is_final=false+).
        #     The default of 0.0 is a sentinel value indicating stability was not set.
        class StreamingRecognitionResult; end

        # A speech recognition result corresponding to a portion of the audio.
        # @!attribute [rw] alternatives
        #   @return [Array<Google::Cloud::Speech::V1beta1::SpeechRecognitionAlternative>]
        #     [Output-only] May contain one or more recognition hypotheses (up to the
        #     maximum specified in +max_alternatives+).
        class SpeechRecognitionResult; end

        # Alternative hypotheses (a.k.a. n-best list).
        # @!attribute [rw] transcript
        #   @return [String]
        #     [Output-only] Transcript text representing the words that the user spoke.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     [Output-only] The confidence estimate between 0.0 and 1.0. A higher number
        #     means the system is more confident that the recognition is correct.
        #     This field is typically provided only for the top hypothesis, and only for
        #     +is_final=true+ results.
        #     The default of 0.0 is a sentinel value indicating confidence was not set.
        class SpeechRecognitionAlternative; end
      end
    end
  end
end