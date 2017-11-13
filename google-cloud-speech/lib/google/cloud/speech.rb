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


require "google-cloud-speech"
require "google/cloud/speech/project"

module Google
  module Cloud
    ##
    # # Google Cloud Speech
    #
    # Google Cloud Speech API enables developers to convert audio to text by
    # applying powerful neural network models in an easy to use API. The API
    # recognizes over 80 languages and variants, to support your global user
    # base. You can transcribe the text of users dictating to an application's
    # microphone, enable command-and-control through voice, or transcribe audio
    # files, among many other use cases. Recognize audio uploaded in the
    # request, and integrate with your audio storage on Google Cloud Storage, by
    # using the same technology Google uses to power its own products.
    #
    # For more information about Google Cloud Speech API, read the [Google Cloud
    # Speech API Documentation](https://cloud.google.com/speech/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Authentication is handled by {Google::Cloud#speech}. You can
    # provide the project and credential information to connect to the Cloud
    # Speech service, or if you are running on Google Compute Engine this
    # configuration is taken care of for you. You can read more about the
    # options for connecting in the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # ## Creating audio sources
    #
    # You can create an audio object that holds a reference to any one of
    # several types of audio data source, along with metadata such as the audio
    # encoding type.
    #
    # Use {Speech::Project#audio} to create audio sources for the Cloud Speech
    # API. You can provide a file path:
    #
    # ```ruby
    # require "google/cloud/speech"
    #
    # speech = Google::Cloud::Speech.new
    #
    # audio = speech.audio "path/to/audio.raw",
    #                      encoding: :linear16,
    #                      language: "en-US",
    #                      sample_rate: 16000
    # ```
    #
    # Or, you can initialize the audio instance with a Google Cloud Storage URI:
    #
    # ```ruby
    # require "google/cloud/speech"
    #
    # speech = Google::Cloud::Speech.new
    #
    # audio = speech.audio "gs://bucket-name/path/to/audio.raw",
    #                      encoding: :linear16,
    #                      language: "en-US",
    #                      sample_rate: 16000
    # ```
    #
    # Or, with a Google Cloud Storage File object:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "bucket-name"
    # file = bucket.file "path/to/audio.raw"
    #
    # require "google/cloud/speech"
    #
    # speech = Google::Cloud::Speech.new
    #
    # audio = speech.audio file,
    #                      encoding: :linear16,
    #                      language: "en-US",
    #                      sample_rate: 16000
    # ```
    #
    # ## Recognizing speech
    #
    # The instance methods on {Speech::Audio} can be used to invoke both
    # synchronous and asynchronous versions of the Cloud Speech API speech
    # recognition operation.
    #
    # Use {Speech::Audio#recognize} for synchronous speech recognition that
    # returns {Speech::Result} objects only after all audio has been processed.
    # This method is limited to audio data of 1 minute or less in duration, and
    # will take roughly the same amount of time to process as the duration of
    # the supplied audio data.
    #
    # ```ruby
    # require "google/cloud/speech"
    #
    # speech = Google::Cloud::Speech.new
    #
    # audio = speech.audio "path/to/audio.raw",
    #                      encoding: :linear16,
    #                      language: "en-US",
    #                      sample_rate: 16000
    #
    # results = audio.recognize
    # result = results.first
    # result.transcript #=> "how old is the Brooklyn Bridge"
    # result.confidence #=> 0.9826789498329163
    # ```
    #
    # Use {Speech::Audio#process} for asynchronous speech recognition, in which
    # a {Speech::Operation} is returned immediately after the audio data has
    # been sent. The op can be refreshed to retrieve {Speech::Result} objects
    # once the audio data has been processed.
    #
    # ```ruby
    # require "google/cloud/speech"
    #
    # speech = Google::Cloud::Speech.new
    #
    # audio = speech.audio "path/to/audio.raw",
    #                      encoding: :linear16,
    #                      language: "en-US",
    #                      sample_rate: 16000
    #
    # op = audio.process
    # op.done? #=> false
    # op.wait_until_done!
    # op.done? #=> true
    # results = op.results
    #
    # result = results.first
    # result.transcript #=> "how old is the Brooklyn Bridge"
    # result.confidence #=> 0.9826789498329163
    # ```
    #
    # Use {Speech::Project#stream} for streaming audio data for speech
    # recognition, in which a {Speech::Stream} is returned. The stream object
    # can receive results while sending audio by performing bidirectional
    # streaming speech-recognition.
    #
    # ```ruby
    # require "google/cloud/speech"
    #
    # speech = Google::Cloud::Speech.new
    #
    # stream = speech.stream encoding: :linear16,
    #                        language: "en-US",
    #                        sample_rate: 16000
    #
    # # Stream 5 seconds of audio from the microphone
    # # Actual implementation of microphone input varies by platform
    # 5.times do
    #   stream.send MicrophoneInput.read(32000)
    # end
    #
    # stream.stop
    # stream.wait_until_complete!
    #
    # results = stream.results
    # result = results.first
    # result.transcript #=> "how old is the Brooklyn Bridge"
    # result.confidence #=> 0.9826789498329163
    # ```
    #
    # Obtaining audio data from input sources such as a Microphone is outside
    # the scope of this document.
    #
    module Speech
      ##
      # Creates a new object for connecting to the Speech service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project_id Project identifier for the Speech service
      #   you are connecting to. If not present, the default project for the
      #   credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Speech::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/speech`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Speech::Project]
      #
      # @example
      #   require "google/cloud/speech"
      #
      #   speech = Google::Cloud::Speech.new
      #
      #   audio = speech.audio "path/to/audio.raw",
      #                        encoding: :linear16,
      #                        language: "en-US",
      #                        sample_rate: 16000
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || Speech::Project.default_project_id)
        project_id = project_id.to_s # Always cast to a string
        fail ArgumentError, "project_id is missing" if project_id.empty?

        credentials ||= (keyfile || Speech::Credentials.default(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Speech::Credentials.new credentials, scope: scope
        end

        Speech::Project.new(
          Speech::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config))
      end
    end
  end
end
