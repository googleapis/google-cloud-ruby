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


module Google
  module Cloud
    module Speech
      ##
      # # Audio
      #
      # @example
      #   require "google/cloud"
      #
      #   gcloud = Google::Cloud.new
      #   speech = gcloud.speech
      #
      #   audio = speech.audio "path/to/text.flac", language: "en"
      #
      class Audio
        # @private The V1beta1::RecognitionAudio object.
        attr_reader :grpc
        attr_accessor :encoding
        attr_accessor :sample_rate
        attr_accessor :language

        ##
        # @private Creates a new Audio instance.
        def initialize
          @grpc = V1beta1::RecognitionAudio.new
        end

        ##
        # @private Whether the Audio has content.
        #
        def content?
          @grpc.audio_source == :content
        end

        ##
        # @private Whether the Audio is a URL.
        #
        def url?
          @grpc.audio_source == :uri
        end

        ##
        # @private The Google API Client object for the Audio.
        def to_grpc
          @grpc
        end

        ##
        # @private New Audio from a source object.
        def self.from_source source
          audio = new
          if source.respond_to?(:read) && source.respond_to?(:rewind)
            audio.grpc.content = String(source.read)
            return audio
          end
          # Convert Storage::File objects to the URL
          source = source.to_gs_url if source.respond_to? :to_gs_url
          # Everything should be a string from now on
          source = String source
          # Create an Audio from the Google Storage URL
          if source.start_with? "gs://"
            audio.grpc.uri = source
            return audio
          end
          # Create an audio from a file on the filesystem
          if File.file? source
            unless File.readable? source
              fail ArgumentError, "Cannot read #{source}"
            end
            content = String(File.read(source, mode: "rb"))
            audio.grpc.content = content
            return audio
          end
          fail ArgumentError, "Unable to convert #{source} to an Audio"
        end

        protected

        ##
        # Raise an error unless an active speech project object is available.
        def ensure_speech!
          fail "Must have active connection" unless @speech
        end
      end
    end
  end
end
