# Copyright 2019 Google LLC
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
      module V2
        # Description of which voice to use for speech synthesis.
        # @!attribute [rw] name
        #   @return [String]
        #     Optional. The name of the voice. If not set, the service will choose a
        #     voice based on the other parameters such as language_code and gender.
        # @!attribute [rw] ssml_gender
        #   @return [Google::Cloud::Dialogflow::V2::SsmlVoiceGender]
        #     Optional. The preferred gender of the voice. If not set, the service will
        #     choose a voice based on the other parameters such as language_code and
        #     name. Note that this is only a preference, not requirement. If a
        #     voice of the appropriate gender is not available, the synthesizer should
        #     substitute a voice with a different gender rather than failing the request.
        class VoiceSelectionParams; end

        # Configuration of how speech should be synthesized.
        # @!attribute [rw] speaking_rate
        #   @return [Float]
        #     Optional. Speaking rate/speed, in the range [0.25, 4.0]. 1.0 is the normal
        #     native speed supported by the specific voice. 2.0 is twice as fast, and
        #     0.5 is half as fast. If unset(0.0), defaults to the native 1.0 speed. Any
        #     other values < 0.25 or > 4.0 will return an error.
        # @!attribute [rw] pitch
        #   @return [Float]
        #     Optional. Speaking pitch, in the range [-20.0, 20.0]. 20 means increase 20
        #     semitones from the original pitch. -20 means decrease 20 semitones from the
        #     original pitch.
        # @!attribute [rw] volume_gain_db
        #   @return [Float]
        #     Optional. Volume gain (in dB) of the normal native volume supported by the
        #     specific voice, in the range [-96.0, 16.0]. If unset, or set to a value of
        #     0.0 (dB), will play at normal native signal amplitude. A value of -6.0 (dB)
        #     will play at approximately half the amplitude of the normal native signal
        #     amplitude. A value of +6.0 (dB) will play at approximately twice the
        #     amplitude of the normal native signal amplitude. We strongly recommend not
        #     to exceed +10 (dB) as there's usually no effective increase in loudness for
        #     any value greater than that.
        # @!attribute [rw] effects_profile_id
        #   @return [Array<String>]
        #     Optional. An identifier which selects 'audio effects' profiles that are
        #     applied on (post synthesized) text to speech. Effects are applied on top of
        #     each other in the order they are given.
        # @!attribute [rw] voice
        #   @return [Google::Cloud::Dialogflow::V2::VoiceSelectionParams]
        #     Optional. The desired voice of the synthesized audio.
        class SynthesizeSpeechConfig; end

        # Instructs the speech synthesizer how to generate the output audio content.
        # @!attribute [rw] audio_encoding
        #   @return [Google::Cloud::Dialogflow::V2::OutputAudioEncoding]
        #     Required. Audio encoding of the synthesized audio content.
        # @!attribute [rw] sample_rate_hertz
        #   @return [Integer]
        #     Optional. The synthesis sample rate (in hertz) for this audio. If not
        #     provided, then the synthesizer will use the default sample rate based on
        #     the audio encoding. If this is different from the voice's natural sample
        #     rate, then the synthesizer will honor this request by converting to the
        #     desired sample rate (which might result in worse audio quality).
        # @!attribute [rw] synthesize_speech_config
        #   @return [Google::Cloud::Dialogflow::V2::SynthesizeSpeechConfig]
        #     Optional. Configuration of how speech should be synthesized.
        class OutputAudioConfig; end

        # Audio encoding of the output audio format in Text-To-Speech.
        module OutputAudioEncoding
          # Not specified.
          OUTPUT_AUDIO_ENCODING_UNSPECIFIED = 0

          # Uncompressed 16-bit signed little-endian samples (Linear PCM).
          # Audio content returned as LINEAR16 also contains a WAV header.
          OUTPUT_AUDIO_ENCODING_LINEAR_16 = 1

          # MP3 audio.
          OUTPUT_AUDIO_ENCODING_MP3 = 2

          # Opus encoded audio wrapped in an ogg container. The result will be a
          # file which can be played natively on Android, and in browsers (at least
          # Chrome and Firefox). The quality of the encoding is considerably higher
          # than MP3 while using approximately the same bitrate.
          OUTPUT_AUDIO_ENCODING_OGG_OPUS = 3
        end

        # Gender of the voice as described in
        # [SSML voice element](https://www.w3.org/TR/speech-synthesis11/#edef_voice).
        module SsmlVoiceGender
          # An unspecified gender, which means that the client doesn't care which
          # gender the selected voice will have.
          SSML_VOICE_GENDER_UNSPECIFIED = 0

          # A male voice.
          SSML_VOICE_GENDER_MALE = 1

          # A female voice.
          SSML_VOICE_GENDER_FEMALE = 2

          # A gender-neutral voice.
          SSML_VOICE_GENDER_NEUTRAL = 3
        end
      end
    end
  end
end