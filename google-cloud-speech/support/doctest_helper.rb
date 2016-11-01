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

require "google/cloud/storage"
require "google/cloud/speech"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

class File
  def self.file? f
    true
  end
  def self.readable? f
    true
  end
  def self.read f, opts
    "fake file data"
  end
end

class MicrophoneInput
  def self.read size
    "1,2,3"
  end
end

module Google
  module Cloud
    module Speech
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
    end
  end
end

def mock_speech
  Google::Cloud::Speech.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    speech = Google::Cloud::Speech::Project.new(Google::Cloud::Speech::Service.new("my-project-id", credentials))

    speech.service.mocked_service = Minitest::Mock.new
    speech.service.mocked_ops = Minitest::Mock.new
    if block_given?
      yield speech.service.mocked_service, speech.service.mocked_ops
    end
    speech
  end
end

module Google
  module Cloud
    module Storage
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
    end
  end
end

def mock_storage
  Google::Cloud::Storage.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    storage = Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new("my-project-id", credentials))

    storage.service.mocked_service = Minitest::Mock.new
    yield storage.service.mocked_service
    storage
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Speech::V1beta1::SpeechApi"

  doctest.before "Google::Cloud#speech" do
    mock_speech
  end

  doctest.before "Google::Cloud::Speech" do
    mock_speech
  end


  doctest.before "Google::Cloud::Speech::Project" do
    mock_speech do |mock|
      mock.expect :sync_recognize, sync_recognize_response, recognize_args
    end
  end

  doctest.before "Google::Cloud::Speech::Project#audio@With a Google Cloud Storage File object:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "bucket-name"), ["bucket-name"]
      mock.expect :get_object,  OpenStruct.new(bucket: "bucket-name", name: "path/to/audio.raw"), ["bucket-name", "path/to/audio.raw", {:generation=>nil, :options=>{}}]
    end
    mock_speech do |mock, mock_ops|
      mock.expect :async_recognize, op_done_false, recognize_args(recognition_config_alternatives, recognition_audio_uri)
      mock_ops.expect :get_operation, nil, ["1234567890"]
    end
  end


  doctest.before "Google::Cloud::Speech::Project#recognize@With a Google Cloud Storage URI:" do
    mock_storage do |mock|
    end
    mock_speech do |mock|
      mock.expect :sync_recognize, sync_recognize_response, recognize_args(nil, recognition_audio_uri)
    end
  end


  doctest.before "Google::Cloud::Speech::Project#recognize@With a Google Cloud Storage File object:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "bucket-name"), ["bucket-name"]
      mock.expect :get_object,  OpenStruct.new(bucket: "bucket-name", name: "path/to/audio.raw"), ["bucket-name", "path/to/audio.raw", {:generation=>nil, :options=>{}}]
    end
    mock_speech do |mock|
      mock.expect :sync_recognize, sync_recognize_response, recognize_args(recognition_config_alternatives, recognition_audio_uri)
    end
  end

  doctest.before "Google::Cloud::Speech::Project#recognize_job" do
    mock_speech do |mock, mock_ops|
      mock.expect :async_recognize, op_done_false, recognize_args
      mock_ops.expect :get_operation, nil, ["1234567890"]
    end
  end

  doctest.before "Google::Cloud::Speech::Project#recognize_job@With a Google Cloud Storage File object:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "bucket-name"), ["bucket-name"]
      mock.expect :get_object,  OpenStruct.new(bucket: "bucket-name", name: "path/to/audio.raw"), ["bucket-name", "path/to/audio.raw", {:generation=>nil, :options=>{}}]
    end
    mock_speech do |mock, mock_ops|
      mock.expect :async_recognize, op_done_false, recognize_args(recognition_config_alternatives, recognition_audio_uri)
      mock_ops.expect :get_operation, nil, ["1234567890"]
    end
  end

  doctest.before "Google::Cloud::Speech::Project#recognize_job@With a Google Cloud Storage URI:" do
    mock_speech do |mock, mock_ops|
      mock.expect :async_recognize, op_done_false, recognize_args(nil, recognition_audio_uri)
      mock_ops.expect :get_operation, nil, ["1234567890"]
    end
  end

  doctest.before "Google::Cloud::Speech::Audio" do
    mock_speech do |mock|
      mock.expect :sync_recognize, sync_recognize_response, recognize_args
    end
  end

  doctest.before "Google::Cloud::Speech::Audio#recognize_job" do
    mock_speech do |mock_service, mock_ops|
      mock_service.expect :async_recognize, op_done_false, recognize_args
      mock_ops.expect :get_operation, op_done_true, [op_name]
    end
  end

  doctest.before "Google::Cloud::Speech::Job" do
    mock_speech do |mock_service, mock_ops|
      mock_service.expect :async_recognize, op_done_false, recognize_args
      mock_ops.expect :get_operation, op_done_true, [op_name]
    end
  end

  doctest.before "Google::Cloud::Speech::Job#results" do
    mock_speech do |mock_service|
      mock_service.expect :async_recognize, op_done_true, recognize_args
    end
  end

  doctest.before "Google::Cloud::Speech::Result" do
    mock_speech do |mock|
      mock.expect :sync_recognize, sync_recognize_response, recognize_args
    end
  end

  doctest.before "Google::Cloud::Speech::Result::Alternative" do
    mock_speech do |mock|
      mock.expect :sync_recognize, sync_recognize_response_alternatives, recognize_args
    end
  end

  doctest.before "Google::Cloud::Speech::Stream#results" do
    mock_speech do |mock|
    end
  end
end

# Fixture helpers



def default_headers
  { "google-cloud-resource-prefix" => "projects/my-project-id" }
end

def default_options
  Google::Gax::CallOptions.new kwargs: default_headers
end

def recognition_config
  Google::Cloud::Speech::V1beta1::RecognitionConfig.new encoding: :LINEAR16, sample_rate: 16000
end

def recognition_config_alternatives
  Google::Cloud::Speech::V1beta1::RecognitionConfig.new encoding: :LINEAR16, sample_rate: 16000, max_alternatives: 10
end

def recognition_audio_uri
  recognition_audio = Google::Cloud::Speech::V1beta1::RecognitionAudio.new
  recognition_audio.audio_source == :uri
  recognition_audio.uri = "gs://bucket-name/path/to/audio.raw"
  recognition_audio
end

def recognition_audio
  Google::Cloud::Speech::V1beta1::RecognitionAudio.new content: "fake file data"
end

# TODO: Match argument values, not just types
def recognize_args config = nil, audio = nil
  [(config || recognition_config), (audio || recognition_audio), {options: default_options}]
end

def sync_recognize_response
  results_json = "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.9826789498329163}]}]}"
  Google::Cloud::Speech::V1beta1::SyncRecognizeResponse.decode_json results_json
end

def sync_recognize_response_alternatives
  results_json = "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.9826789498329163},{\"transcript\":\"how old is the Brooklyn brim\",\"confidence\":0.22030000388622284}]}]}"
  Google::Cloud::Speech::V1beta1::SyncRecognizeResponse.decode_json results_json
end

def op_name
  "1234567890"
end

def op_done_false
  job_json = "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1beta1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}}"
  Google::Longrunning::Operation.decode_json job_json
end

def op_done_true
  results_json = "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}"
  results_grpc = Google::Cloud::Speech::V1beta1::AsyncRecognizeResponse.decode_json results_json
  complete_json = "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1beta1.AsyncRecognizeMetadata\",\"value\":\"CFQSDAi6jKS/BRCwkLafARoMCIeZpL8FEKjRqswC\"}, \"done\": true, \"response\": {\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1beta1.AsyncRecognizeResponse\",\"value\":\"#{Base64.strict_encode64(results_grpc.to_proto)}\"}"
  Google::Longrunning::Operation.decode_json complete_json
end
