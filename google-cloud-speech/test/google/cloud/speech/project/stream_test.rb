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

require "helper"

class StreamingServiceStub
  attr_reader :request_enum, :responses

  def initialize responses
    @responses = responses
  end

  def streaming_recognize request_enum
    @request_enum = request_enum
    # return response enumerator
    @responses.each
  end
end

describe Google::Cloud::Speech::Project, :stream, :mock_speech do
  it "streams audio" do
    stream = speech.stream encoding: :raw, sample_rate: 16000
    stream.must_be_kind_of Google::Cloud::Speech::Stream
    stream.wont_be :started?
    stream.wont_be :stopped?

    counters = Hash.new { |h, k| h[k] = 0 }

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_speech_start { counters[:speech_start] += 1 }
    stream.on_speech_end   { counters[:speech_end] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }

    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    streaming_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognitionConfig.new(config: config_grpc)
    init_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(streaming_config: streaming_grpc)
    audio_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(audio_content: File.read("acceptance/data/audio.raw", mode: "rb"))

    responses = [
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"START_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_AUDIO\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}],\"isFinal\":true}]}")
    ]

    stub = StreamingServiceStub.new(responses)
    speech.service.mocked_service = OpenStruct.new(speech_stub: stub)

    stream.send File.read("acceptance/data/audio.raw", mode: "rb")

    stream.stop

    sleep 0.1 # give callbacks time to fire

    stub.request_enum.to_a.must_equal [init_grpc, audio_grpc]

    results = stream.results

    results.wont_be :empty?
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?

    counters[:interim].must_equal 0
    counters[:result].must_equal 1
    counters[:speech_start].must_equal 1
    counters[:speech_end].must_equal 1
    counters[:complete].must_equal 1
    counters[:utterance].must_equal 0
  end

  it "streams audio over several sends" do
    stream = speech.stream encoding: :raw, sample_rate: 16000
    stream.must_be_kind_of Google::Cloud::Speech::Stream
    stream.wont_be :started?
    stream.wont_be :stopped?

    counters = Hash.new { |h, k| h[k] = 0 }

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_speech_start { counters[:speech_start] += 1 }
    stream.on_speech_end   { counters[:speech_end] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }

    file = File.open "acceptance/data/audio.raw", "rb"

    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000)
    streaming_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognitionConfig.new(config: config_grpc)
    init_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(streaming_config: streaming_grpc)
    audio_grpc1 = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(audio_content: file.read(16000))
    audio_grpc2 = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(audio_content: file.read(16000))
    audio_grpc3 = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(audio_content: file.read(16000))

    responses = [
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"START_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_AUDIO\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}],\"isFinal\":true}]}")
    ]

    stub = StreamingServiceStub.new(responses)
    speech.service.mocked_service = OpenStruct.new(speech_stub: stub)

    file.rewind
    stream.send file.read(16000)
    stream.send file.read(16000)
    stream.send file.read(16000)

    stream.stop

    sleep 0.1 # give callbacks time to fire

    stub.request_enum.to_a.must_equal [init_grpc, audio_grpc1, audio_grpc2, audio_grpc3]

    results = stream.results

    results.wont_be :empty?
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?

    counters[:interim].must_equal 0
    counters[:result].must_equal 1
    counters[:speech_start].must_equal 1
    counters[:speech_end].must_equal 1
    counters[:complete].must_equal 1
    counters[:utterance].must_equal 0
  end

  it "streams audio with alternatives and interum results" do
    stream = speech.stream encoding: :raw, sample_rate: 16000, max_alternatives: 10, interim: true
    stream.must_be_kind_of Google::Cloud::Speech::Stream
    stream.wont_be :started?
    stream.wont_be :stopped?

    counters = Hash.new { |h, k| h[k] = 0 }

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_speech_start { counters[:speech_start] += 1 }
    stream.on_speech_end   { counters[:speech_end] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }

    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000, max_alternatives: 10)
    streaming_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognitionConfig.new(config: config_grpc, interim_results: true)
    init_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(streaming_config: streaming_grpc)
    audio_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(audio_content: File.read("acceptance/data/audio.raw", mode: "rb"))

    responses = [
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"START_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" old is\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" old is the\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" is the\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" is Sarah\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" is the book\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" is the brook\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" is the Brooklyn\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" the Brooklyn\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" the Brooklyn Bridge\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" Bridge\"}],\"stability\":0.0099999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\"}],\"stability\":0.89999998}]}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_AUDIO\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}],\"isFinal\":true}]}")
    ]

    stub = StreamingServiceStub.new(responses)
    speech.service.mocked_service = OpenStruct.new(speech_stub: stub)

    stream.send File.read("acceptance/data/audio.raw", mode: "rb")

    stream.stop

    sleep 0.1 # give callbacks time to fire

    stub.request_enum.to_a.must_equal [init_grpc, audio_grpc]

    results = stream.results

    results.wont_be :empty?
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?

    counters[:interim].must_equal 14
    counters[:result].must_equal 1
    counters[:speech_start].must_equal 1
    counters[:speech_end].must_equal 1
    counters[:complete].must_equal 1
    counters[:utterance].must_equal 0
  end

  it "streams for a single utterance" do
    stream = speech.stream encoding: :raw, sample_rate: 16000, max_alternatives: 10, interim: true
    stream.must_be_kind_of Google::Cloud::Speech::Stream
    stream.wont_be :started?
    stream.wont_be :stopped?

    counters = Hash.new { |h, k| h[k] = 0 }

    stream.on_interim      { counters[:interim] += 1 }
    stream.on_result       { counters[:result] += 1 }
    stream.on_speech_start { counters[:speech_start] += 1 }
    stream.on_speech_end   { counters[:speech_end] += 1 }
    stream.on_complete     { counters[:complete] += 1 }
    stream.on_utterance    { counters[:utterance] += 1 }

    config_grpc = Google::Cloud::Speech::V1beta1::RecognitionConfig.new(encoding: :LINEAR16, sample_rate: 16000, max_alternatives: 10)
    streaming_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognitionConfig.new(config: config_grpc, interim_results: true)
    init_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(streaming_config: streaming_grpc)
    audio_grpc = Google::Cloud::Speech::V1beta1::StreamingRecognizeRequest.new(audio_content: File.read("acceptance/data/audio.raw", mode: "rb"))

    responses = [
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"START_OF_SPEECH\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_UTTERANCE\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[],\"endpointerType\":\"END_OF_AUDIO\"}"),
      Google::Cloud::Speech::V1beta1::StreamingRecognizeResponse.decode_json("{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}],\"isFinal\":true}]}")
    ]

    stub = StreamingServiceStub.new(responses)
    speech.service.mocked_service = OpenStruct.new(speech_stub: stub)

    stream.send File.read("acceptance/data/audio.raw", mode: "rb")

    stream.stop

    sleep 0.1 # give callbacks time to fire

    stub.request_enum.to_a.must_equal [init_grpc, audio_grpc]

    results = stream.results

    results.wont_be :empty?
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?

    counters[:interim].must_equal 0
    counters[:result].must_equal 1
    counters[:speech_start].must_equal 1
    counters[:speech_end].must_equal 0
    counters[:complete].must_equal 1
    counters[:utterance].must_equal 1
  end
end
