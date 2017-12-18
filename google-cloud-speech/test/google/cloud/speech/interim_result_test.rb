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

describe Google::Cloud::Speech::InterimResult, :mock_speech do
  let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is\"}],\"stability\":0.89999998},{\"alternatives\":[{\"transcript\":\" the Brooklyn Bridge\"}],\"stability\":0.0099999998}]}" }
  let(:results_grpc) { Google::Cloud::Speech::V1::StreamingRecognizeResponse.decode_json results_json }
  let(:results) { results_grpc.results.map { |result_grpc| Google::Cloud::Speech::InterimResult.from_grpc result_grpc } }

  it "knows itself" do
    results.count.must_equal 2
    results.each { |r| r.must_be_kind_of Google::Cloud::Speech::InterimResult }

    results.first.transcript.must_equal "how old is"
    results.first.confidence.must_be :zero?
    results.first.alternatives.must_be :empty?
    results.first.stability.must_be_close_to 0.89999998

    results.last.transcript.must_equal " the Brooklyn Bridge"
    results.last.confidence.must_be :zero?
    results.last.alternatives.must_be :empty?
    results.last.stability.must_be_close_to 0.0099999998
  end
end
