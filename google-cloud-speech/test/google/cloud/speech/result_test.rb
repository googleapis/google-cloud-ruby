# Copyright 2016 Google LLC
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

require "helper"

describe Google::Cloud::Speech::Result, :mock_speech do
  let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}" }
  let(:results_grpc) { Google::Cloud::Speech::V1::RecognizeResponse.decode_json results_json }
  let(:results) { results_grpc.results.map { |result_grpc| Google::Cloud::Speech::Result.from_grpc result_grpc } }

  it "knows itself" do
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  describe Google::Cloud::Speech::Result::Word do
    let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}" }
    let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.987629,\"words\":[{\"startTime\":{},\"endTime\":{\"nanos\":300000000},\"word\":\"how\"},{\"startTime\":{\"nanos\":300000000},\"endTime\":{\"nanos\":600000000},\"word\":\"old\"},{\"startTime\":{\"nanos\":600000000},\"endTime\":{\"nanos\":800000000},\"word\":\"is\"},{\"startTime\":{\"nanos\":800000000},\"endTime\":{\"nanos\":900000000},\"word\":\"the\"},{\"startTime\":{\"nanos\":900000000},\"endTime\":{\"seconds\":1,\"nanos\":100000000},\"word\":\"Brooklyn\"},{\"startTime\":{\"seconds\":1,\"nanos\":100000000},\"endTime\":{\"seconds\":1,\"nanos\":500000000},\"word\":\"Bridge\"}]}]}]}" }

    it "knows itself" do
      results.count.must_equal 1
      results.first.transcript.must_equal "how old is the Brooklyn Bridge"
      results.first.confidence.must_be_close_to 0.98762899
      results.first.words.wont_be :empty?

      results.first.words[0].must_be_kind_of Google::Cloud::Speech::Result::Word
      results.first.words[0].word.must_equal "how"
      results.first.words[0].start_time.must_be_close_to 0
      results.first.words[0].end_time.must_be_close_to 0.3

      results.first.words[1].must_be_kind_of Google::Cloud::Speech::Result::Word
      results.first.words[1].word.must_equal "old"
      results.first.words[1].start_time.must_be_close_to 0.3
      results.first.words[1].end_time.must_be_close_to 0.6

      results.first.words[2].must_be_kind_of Google::Cloud::Speech::Result::Word
      results.first.words[2].word.must_equal "is"
      results.first.words[2].start_time.must_be_close_to 0.6
      results.first.words[2].end_time.must_be_close_to 0.8

      results.first.words[3].must_be_kind_of Google::Cloud::Speech::Result::Word
      results.first.words[3].word.must_equal "the"
      results.first.words[3].start_time.must_be_close_to 0.8
      results.first.words[3].end_time.must_be_close_to 0.9

      results.first.words[4].must_be_kind_of Google::Cloud::Speech::Result::Word
      results.first.words[4].word.must_equal "Brooklyn"
      results.first.words[4].start_time.must_be_close_to 0.9
      results.first.words[4].end_time.must_be_close_to 1.1

      results.first.words[5].must_be_kind_of Google::Cloud::Speech::Result::Word
      results.first.words[5].word.must_equal "Bridge"
      results.first.words[5].start_time.must_be_close_to 1.1
      results.first.words[5].end_time.must_be_close_to 1.5

      results.first.alternatives.must_be :empty?
    end
  end
end
