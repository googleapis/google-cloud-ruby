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
    module Dialogflow
      ##
      # # Dialogflow API Contents
      #
      # | Class | Description |
      # | ----- | ----------- |
      # | [SessionsClient][] | A session represents an interaction with a user. |
      # | [Data Types][] | Data types for Google::Cloud::Dialogflow::V2 |
      #
      # [SessionsClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dialogflow/latest/google/cloud/dialogflow/v2/sessionsclient
      # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dialogflow/latest/google/cloud/dialogflow/v2/datatypes
      #
      module V2
        # The request to detect user's intent.
        # @!attribute [rw] session
        #   @return [String]
        #     Required. The name of the session this query is sent to. Format:
        #     +projects/<Project ID>/agent/sessions/<Session ID>+. It's up to the API
        #     caller to choose an appropriate session ID. It can be a random number or
        #     some type of user identifier (preferably hashed). The length of the session
        #     ID must not exceed 36 bytes.
        # @!attribute [rw] query_params
        #   @return [Google::Cloud::Dialogflow::V2::QueryParameters]
        #     Optional. The parameters of this query.
        # @!attribute [rw] query_input
        #   @return [Google::Cloud::Dialogflow::V2::QueryInput]
        #     Required. The input specification. It can be set to:
        #
        #     1.  an audio config
        #         which instructs the speech recognizer how to process the speech audio,
        #
        #     2.  a conversational query in the form of text, or
        #
        #     3.  an event that specifies which intent to trigger.
        # @!attribute [rw] input_audio
        #   @return [String]
        #     Optional. The natural language speech audio to be processed. This field
        #     should be populated iff +query_input+ is set to an input audio config.
        #     A single request can contain up to 1 minute of speech audio data.
        class DetectIntentRequest; end

        # The message returned from the DetectIntent method.
        # @!attribute [rw] response_id
        #   @return [String]
        #     The unique identifier of the response. It can be used to
        #     locate a response in the training example set or for reporting issues.
        # @!attribute [rw] query_result
        #   @return [Google::Cloud::Dialogflow::V2::QueryResult]
        #     The results of the conversational query or event processing.
        # @!attribute [rw] webhook_status
        #   @return [Google::Rpc::Status]
        #     Specifies the status of the webhook request. +webhook_status+
        #     is never populated in webhook requests.
        class DetectIntentResponse; end

        # Represents the parameters of the conversational query.
        # @!attribute [rw] time_zone
        #   @return [String]
        #     Optional. The time zone of this conversational query from the
        #     [time zone database](https://www.iana.org/time-zones), e.g.,
        #     America/New_York, Europe/Paris. If not provided, the time zone specified in
        #     agent settings is used.
        # @!attribute [rw] geo_location
        #   @return [Google::Type::LatLng]
        #     Optional. The geo location of this conversational query.
        # @!attribute [rw] contexts
        #   @return [Array<Google::Cloud::Dialogflow::V2::Context>]
        #     Optional. The collection of contexts to be activated before this query is
        #     executed.
        # @!attribute [rw] reset_contexts
        #   @return [true, false]
        #     Optional. Specifies whether to delete all contexts in the current session
        #     before the new ones are activated.
        # @!attribute [rw] session_entity_types
        #   @return [Array<Google::Cloud::Dialogflow::V2::SessionEntityType>]
        #     Optional. The collection of session entity types to replace or extend
        #     developer entities with for this query only. The entity synonyms apply
        #     to all languages.
        # @!attribute [rw] payload
        #   @return [Google::Protobuf::Struct]
        #     Optional. This field can be used to pass custom data into the webhook
        #     associated with the agent. Arbitrary JSON objects are supported.
        class QueryParameters; end

        # Represents the query input. It can contain either:
        #
        # 1.  An audio config which
        #     instructs the speech recognizer how to process the speech audio.
        #
        # 2.  A conversational query in the form of text,.
        #
        # 3.  An event that specifies which intent to trigger.
        # @!attribute [rw] audio_config
        #   @return [Google::Cloud::Dialogflow::V2::InputAudioConfig]
        #     Instructs the speech recognizer how to process the speech audio.
        # @!attribute [rw] text
        #   @return [Google::Cloud::Dialogflow::V2::TextInput]
        #     The natural language text to be processed.
        # @!attribute [rw] event
        #   @return [Google::Cloud::Dialogflow::V2::EventInput]
        #     The event to be processed.
        class QueryInput; end

        # Represents the result of conversational query or event processing.
        # @!attribute [rw] query_text
        #   @return [String]
        #     The original conversational query text:
        #     * If natural language text was provided as input, +query_text+ contains
        #       a copy of the input.
        #     * If natural language speech audio was provided as input, +query_text+
        #       contains the speech recognition result. If speech recognizer produced
        #       multiple alternatives, a particular one is picked.
        #     * If an event was provided as input, +query_text+ is not set.
        # @!attribute [rw] language_code
        #   @return [String]
        #     The language that was triggered during intent detection.
        #     See [Language Support](https://dialogflow.com/docs/reference/language)
        #     for a list of the currently supported language codes.
        # @!attribute [rw] speech_recognition_confidence
        #   @return [Float]
        #     The Speech recognition confidence between 0.0 and 1.0. A higher number
        #     indicates an estimated greater likelihood that the recognized words are
        #     correct. The default of 0.0 is a sentinel value indicating that confidence
        #     was not set.
        #
        #     You should not rely on this field as it isn't guaranteed to be accurate, or
        #     even set. In particular this field isn't set in Webhook calls and for
        #     StreamingDetectIntent since the streaming endpoint has separate confidence
        #     estimates per portion of the audio in StreamingRecognitionResult.
        # @!attribute [rw] action
        #   @return [String]
        #     The action name from the matched intent.
        # @!attribute [rw] parameters
        #   @return [Google::Protobuf::Struct]
        #     The collection of extracted parameters.
        # @!attribute [rw] all_required_params_present
        #   @return [true, false]
        #     This field is set to:
        #     * +false+ if the matched intent has required parameters and not all of
        #       the required parameter values have been collected.
        #     * +true+ if all required parameter values have been collected, or if the
        #       matched intent doesn't contain any required parameters.
        # @!attribute [rw] fulfillment_text
        #   @return [String]
        #     The text to be pronounced to the user or shown on the screen.
        # @!attribute [rw] fulfillment_messages
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message>]
        #     The collection of rich messages to present to the user.
        # @!attribute [rw] webhook_source
        #   @return [String]
        #     If the query was fulfilled by a webhook call, this field is set to the
        #     value of the +source+ field returned in the webhook response.
        # @!attribute [rw] webhook_payload
        #   @return [Google::Protobuf::Struct]
        #     If the query was fulfilled by a webhook call, this field is set to the
        #     value of the +payload+ field returned in the webhook response.
        # @!attribute [rw] output_contexts
        #   @return [Array<Google::Cloud::Dialogflow::V2::Context>]
        #     The collection of output contexts. If applicable,
        #     +output_contexts.parameters+ contains entries with name
        #     +<parameter name>.original+ containing the original parameter values
        #     before the query.
        # @!attribute [rw] intent
        #   @return [Google::Cloud::Dialogflow::V2::Intent]
        #     The intent that matched the conversational query. Some, not
        #     all fields are filled in this message, including but not limited to:
        #     +name+, +display_name+ and +webhook_state+.
        # @!attribute [rw] intent_detection_confidence
        #   @return [Float]
        #     The intent detection confidence. Values range from 0.0
        #     (completely uncertain) to 1.0 (completely certain).
        # @!attribute [rw] diagnostic_info
        #   @return [Google::Protobuf::Struct]
        #     The free-form diagnostic info. For example, this field
        #     could contain webhook call latency.
        class QueryResult; end

        # The top-level message sent by the client to the
        # +StreamingDetectIntent+ method.
        #
        # Multiple request messages should be sent in order:
        #
        # 1.  The first message must contain +session+, +query_input+ plus optionally
        #     +query_params+ and/or +single_utterance+. The message must not contain +input_audio+.
        #
        # 2.  If +query_input+ was set to a streaming input audio config,
        #     all subsequent messages must contain only +input_audio+.
        #     Otherwise, finish the request stream.
        # @!attribute [rw] session
        #   @return [String]
        #     Required. The name of the session the query is sent to.
        #     Format of the session name:
        #     +projects/<Project ID>/agent/sessions/<Session ID>+. It’s up to the API
        #     caller to choose an appropriate <Session ID>. It can be a random number or
        #     some type of user identifier (preferably hashed). The length of the session
        #     ID must not exceed 36 characters.
        # @!attribute [rw] query_params
        #   @return [Google::Cloud::Dialogflow::V2::QueryParameters]
        #     Optional. The parameters of this query.
        # @!attribute [rw] query_input
        #   @return [Google::Cloud::Dialogflow::V2::QueryInput]
        #     Required. The input specification. It can be set to:
        #
        #     1.  an audio config which instructs the speech recognizer how to process
        #         the speech audio,
        #
        #     2.  a conversational query in the form of text, or
        #
        #     3.  an event that specifies which intent to trigger.
        # @!attribute [rw] single_utterance
        #   @return [true, false]
        #     Optional. If +false+ (default), recognition does not cease until the
        #     client closes the stream.
        #     If +true+, the recognizer will detect a single spoken utterance in input
        #     audio. Recognition ceases when it detects the audio's voice has
        #     stopped or paused. In this case, once a detected intent is received, the
        #     client should close the stream and start a new request with a new stream as
        #     needed.
        #     This setting is ignored when +query_input+ is a piece of text or an event.
        # @!attribute [rw] input_audio
        #   @return [String]
        #     Optional. The input audio content to be recognized. Must be sent if
        #     +query_input+ was set to a streaming input audio config. The complete audio
        #     over all streaming messages must not exceed 1 minute.
        class StreamingDetectIntentRequest; end

        # The top-level message returned from the
        # +StreamingDetectIntent+ method.
        #
        # Multiple response messages can be returned in order:
        #
        # 1.  If the input was set to streaming audio, the first one or more messages
        #     contain +recognition_result+. Each +recognition_result+ represents a more
        #     complete transcript of what the user said. The last +recognition_result+
        #     has +is_final+ set to +true+.
        #
        # 2.  The next message contains +response_id+, +query_result+
        #     and optionally +webhook_status+ if a WebHook was called.
        # @!attribute [rw] response_id
        #   @return [String]
        #     The unique identifier of the response. It can be used to
        #     locate a response in the training example set or for reporting issues.
        # @!attribute [rw] recognition_result
        #   @return [Google::Cloud::Dialogflow::V2::StreamingRecognitionResult]
        #     The result of speech recognition.
        # @!attribute [rw] query_result
        #   @return [Google::Cloud::Dialogflow::V2::QueryResult]
        #     The result of the conversational query or event processing.
        # @!attribute [rw] webhook_status
        #   @return [Google::Rpc::Status]
        #     Specifies the status of the webhook request.
        class StreamingDetectIntentResponse; end

        # Contains a speech recognition result corresponding to a portion of the audio
        # that is currently being processed or an indication that this is the end
        # of the single requested utterance.
        #
        # Example:
        #
        # 1.  transcript: "tube"
        #
        # 2.  transcript: "to be a"
        #
        # 3.  transcript: "to be"
        #
        # 4.  transcript: "to be or not to be"
        #     is_final: true
        #
        # 5.  transcript: " that's"
        #
        # 6.  transcript: " that is"
        #
        # 7.  recognition_event_type: +RECOGNITION_EVENT_END_OF_SINGLE_UTTERANCE+
        #
        # 8.  transcript: " that is the question"
        #     is_final: true
        #
        # Only two of the responses contain final results (#4 and #8 indicated by
        # +is_final: true+). Concatenating these generates the full transcript: "to be
        # or not to be that is the question".
        #
        # In each response we populate:
        #
        # * for +MESSAGE_TYPE_TRANSCRIPT+: +transcript+ and possibly +is_final+.
        #
        # * for +MESSAGE_TYPE_END_OF_SINGLE_UTTERANCE+: only +event_type+.
        # @!attribute [rw] message_type
        #   @return [Google::Cloud::Dialogflow::V2::StreamingRecognitionResult::MessageType]
        #     Type of the result message.
        # @!attribute [rw] transcript
        #   @return [String]
        #     Transcript text representing the words that the user spoke.
        #     Populated if and only if +event_type+ = +RECOGNITION_EVENT_TRANSCRIPT+.
        # @!attribute [rw] is_final
        #   @return [true, false]
        #     The default of 0.0 is a sentinel value indicating +confidence+ was not set.
        #     If +false+, the +StreamingRecognitionResult+ represents an
        #     interim result that may change. If +true+, the recognizer will not return
        #     any further hypotheses about this piece of the audio. May only be populated
        #     for +event_type+ = +RECOGNITION_EVENT_TRANSCRIPT+.
        # @!attribute [rw] confidence
        #   @return [Float]
        #     The Speech confidence between 0.0 and 1.0 for the current portion of audio.
        #     A higher number indicates an estimated greater likelihood that the
        #     recognized words are correct. The default of 0.0 is a sentinel value
        #     indicating that confidence was not set.
        #
        #     This field is typically only provided if +is_final+ is true and you should
        #     not rely on it being accurate or even set.
        class StreamingRecognitionResult
          # Type of the response message.
          module MessageType
            # Not specified. Should never be used.
            MESSAGE_TYPE_UNSPECIFIED = 0

            # Message contains a (possibly partial) transcript.
            TRANSCRIPT = 1

            # Event indicates that the server has detected the end of the user's speech
            # utterance and expects no additional speech. Therefore, the server will
            # not process additional audio (although it may subsequently return
            # additional results). The client should stop sending additional audio
            # data, half-close the gRPC connection, and wait for any additional results
            # until the server closes the gRPC connection. This message is only sent if
            # +single_utterance+ was set to +true+, and is not used otherwise.
            END_OF_SINGLE_UTTERANCE = 2
          end
        end

        # Instructs the speech recognizer how to process the audio content.
        # @!attribute [rw] audio_encoding
        #   @return [Google::Cloud::Dialogflow::V2::AudioEncoding]
        #     Required. Audio encoding of the audio content to process.
        # @!attribute [rw] sample_rate_hertz
        #   @return [Integer]
        #     Required. Sample rate (in Hertz) of the audio content sent in the query.
        #     Refer to [Cloud Speech API documentation](https://cloud.google.com/speech/docs/basics) for more
        #     details.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Required. The language of the supplied audio. Dialogflow does not do
        #     translations. See [Language
        #     Support](https://dialogflow.com/docs/languages) for a list of the
        #     currently supported language codes. Note that queries in the same session
        #     do not necessarily need to specify the same language.
        # @!attribute [rw] phrase_hints
        #   @return [Array<String>]
        #     Optional. The collection of phrase hints which are used to boost accuracy
        #     of speech recognition.
        #     Refer to [Cloud Speech API documentation](https://cloud.google.com/speech/docs/basics#phrase-hints)
        #     for more details.
        class InputAudioConfig; end

        # Represents the natural language text to be processed.
        # @!attribute [rw] text
        #   @return [String]
        #     Required. The UTF-8 encoded natural language text to be processed.
        #     Text length must not exceed 256 bytes.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Required. The language of this conversational query. See [Language
        #     Support](https://dialogflow.com/docs/languages) for a list of the
        #     currently supported language codes. Note that queries in the same session
        #     do not necessarily need to specify the same language.
        class TextInput; end

        # Events allow for matching intents by event name instead of the natural
        # language input. For instance, input +<event: { name: “welcome_event”,
        # parameters: { name: “Sam” } }>+ can trigger a personalized welcome response.
        # The parameter +name+ may be used by the agent in the response:
        # +“Hello #welcome_event.name! What can I do for you today?”+.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The unique identifier of the event.
        # @!attribute [rw] parameters
        #   @return [Google::Protobuf::Struct]
        #     Optional. The collection of parameters associated with the event.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Required. The language of this query. See [Language
        #     Support](https://dialogflow.com/docs/languages) for a list of the
        #     currently supported language codes. Note that queries in the same session
        #     do not necessarily need to specify the same language.
        class EventInput; end

        # Audio encoding of the audio content sent in the conversational query request.
        # Refer to the [Cloud Speech API documentation](https://cloud.google.com/speech/docs/basics) for more
        # details.
        module AudioEncoding
          # Not specified.
          AUDIO_ENCODING_UNSPECIFIED = 0

          # Uncompressed 16-bit signed little-endian samples (Linear PCM).
          AUDIO_ENCODING_LINEAR_16 = 1

          # [+FLAC+](https://xiph.org/flac/documentation.html) (Free Lossless Audio
          # Codec) is the recommended encoding because it is lossless (therefore
          # recognition is not compromised) and requires only about half the
          # bandwidth of +LINEAR16+. +FLAC+ stream encoding supports 16-bit and
          # 24-bit samples, however, not all fields in +STREAMINFO+ are supported.
          AUDIO_ENCODING_FLAC = 2

          # 8-bit samples that compand 14-bit audio samples using G.711 PCMU/mu-law.
          AUDIO_ENCODING_MULAW = 3

          # Adaptive Multi-Rate Narrowband codec. +sample_rate_hertz+ must be 8000.
          AUDIO_ENCODING_AMR = 4

          # Adaptive Multi-Rate Wideband codec. +sample_rate_hertz+ must be 16000.
          AUDIO_ENCODING_AMR_WB = 5

          # Opus encoded audio frames in Ogg container
          # ([OggOpus](https://wiki.xiph.org/OggOpus)).
          # +sample_rate_hertz+ must be 16000.
          AUDIO_ENCODING_OGG_OPUS = 6

          # Although the use of lossy encodings is not recommended, if a very low
          # bitrate encoding is required, +OGG_OPUS+ is highly preferred over
          # Speex encoding. The [Speex](https://speex.org/) encoding supported by
          # Dialogflow API has a header byte in each block, as in MIME type
          # +audio/x-speex-with-header-byte+.
          # It is a variant of the RTP Speex encoding defined in
          # [RFC 5574](https://tools.ietf.org/html/rfc5574).
          # The stream is a sequence of blocks, one block per RTP packet. Each block
          # starts with a byte containing the length of the block, in bytes, followed
          # by one or more frames of Speex data, padded to an integral number of
          # bytes (octets) as specified in RFC 5574. In other words, each RTP header
          # is replaced with a single byte containing the block length. Only Speex
          # wideband is supported. +sample_rate_hertz+ must be 16000.
          AUDIO_ENCODING_SPEEX_WITH_HEADER_BYTE = 7
        end
      end
    end
  end
end