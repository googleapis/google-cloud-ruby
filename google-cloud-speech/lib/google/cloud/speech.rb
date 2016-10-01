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
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # speech = gcloud.speech
    #
    # audio = speech.audio "path/to/audio.raw",
    #                      encoding: :raw, sample_rate: 16000
    # ```
    #
    # Or, you can initialize the audio instance with a Google Cloud Storage URI:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # speech = gcloud.speech
    #
    # audio = speech.audio "gs://bucket-name/path/to/audio.raw",
    #                      encoding: :raw, sample_rate: 16000
    # ```
    #
    # Or, with a Google Cloud Storage File object:
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # storage = gcloud.storage
    #
    # bucket = storage.bucket "bucket-name"
    # file = bucket.file "path/to/audio.raw"
    #
    # speech = gcloud.speech
    #
    # audio = speech.audio file, encoding: :raw, sample_rate: 16000
    # ```
    #
    # ## Recognizing speech
    #
    # The instance methods on {Speech::Audio} can be used to invoke both
    # synchronous and asynchronous versions of the Cloud Speech API speech
    # recognition operation.
    #
    # Use {Speech::Audio#recognize} for synchronous speech recognition that
    # returns {Result} objects only after all audio has been processed. This
    # method is limited to audio data of 1 minute or less in duration, and will
    # take roughly the same amount of time to process as the duration of the
    # supplied audio data.
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # speech = gcloud.speech
    #
    # audio = speech.audio "path/to/audio.raw",
    #                      encoding: :raw, sample_rate: 16000
    # results = audio.recognize
    #
    # result = results.first
    # result.transcript #=> "how old is the Brooklyn Bridge"
    # result.confidence #=> 88.15
    # ```
    #
    # Use {Speech::Audio#recognize_job} for asynchronous speech recognition,
    # in which a {Job} is returned immediately after the audio data has
    # been sent. The job can be refreshed to retrieve {Result} objects
    # once the audio data has been processed.
    #
    # ```ruby
    # require "google/cloud"
    #
    # gcloud = Google::Cloud.new
    # speech = gcloud.speech
    #
    # audio = speech.audio "path/to/audio.raw",
    #                      encoding: :raw, sample_rate: 16000
    # job = audio.recognize_job
    #
    # job.done? #=> false
    # job.reload!
    # job.done? #=> true
    # results = job.results
    #
    # result = results.first
    # result.transcript #=> "how old is the Brooklyn Bridge"
    # result.confidence #=> 88.15
    # ```
    #
    module Speech
    end
  end
end
