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

describe Google::Cloud::Speech::Job, :mock_speech do
  let(:ops_mock) { Minitest::Mock.new }
  let(:incomplete_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeMetadata\",\"value\":\"CGQSDAjeiPXEBRCou4mXARoMCN+I9cQFENj+gPIB\"}}" }
  let(:incomplete_grpc) { Google::Longrunning::Operation.decode_json incomplete_json }
  let(:incomplete_gax) { Google::Gax::Operation.new incomplete_grpc, ops_mock, Google::Cloud::Speech::V1::LongRunningRecognizeResponse, Google::Cloud::Speech::V1::LongRunningRecognizeMetadata }
  let(:results_json) { "{\"results\":[{\"alternatives\":[{\"transcript\":\"how old is the Brooklyn Bridge\",\"confidence\":0.98267895}]}]}" }
  let(:results_grpc) { Google::Cloud::Speech::V1::LongRunningRecognizeResponse.decode_json results_json }
  let(:complete_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeMetadata\",\"value\":\"CGQSDAjeiPXEBRCou4mXARoMCN+I9cQFENj+gPIB\"}, \"done\": true, \"response\": {\"typeUrl\":\"type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeResponse\",\"value\":\"#{Base64.strict_encode64(results_grpc.to_proto)}\"}" }
  let(:complete_grpc) { Google::Longrunning::Operation.decode_json complete_json }
  let(:complete_gax) { Google::Gax::Operation.new complete_grpc, ops_mock, Google::Cloud::Speech::V1::LongRunningRecognizeResponse, Google::Cloud::Speech::V1::LongRunningRecognizeMetadata }

  it "refreshes to get final results" do
    job = Google::Cloud::Speech::Job.from_grpc incomplete_gax
    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?

    ops_mock.expect :get_operation, complete_grpc, ["1234567890", options: nil]

    job.refresh!
    ops_mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.must_be :done?

    results = job.results
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end

  it "refreshes but is still not done" do
    job = Google::Cloud::Speech::Job.from_grpc incomplete_gax
    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?

    ops_mock.expect :get_operation, incomplete_grpc, ["1234567890", options: nil]

    job.refresh!
    ops_mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?
  end

  it "waits until done" do
    job = Google::Cloud::Speech::Job.from_grpc incomplete_gax
    job.must_be_kind_of Google::Cloud::Speech::Job
    job.wont_be :done?

    ops_mock.expect :get_operation, incomplete_grpc, ["1234567890", options: nil]
    ops_mock.expect :get_operation, incomplete_grpc, ["1234567890", options: nil]
    ops_mock.expect :get_operation, incomplete_grpc, ["1234567890", options: nil]
    ops_mock.expect :get_operation, incomplete_grpc, ["1234567890", options: nil]
    ops_mock.expect :get_operation, complete_grpc,   ["1234567890", options: nil]

    # fake out the sleep method so the test doesn't actually block
    def incomplete_gax.sleep *args
    end

    job.wait_until_done!
    ops_mock.verify

    job.must_be_kind_of Google::Cloud::Speech::Job
    job.must_be :done?

    results = job.results
    results.count.must_equal 1
    results.first.transcript.must_equal "how old is the Brooklyn Bridge"
    results.first.confidence.must_be_close_to 0.98267895
    results.first.alternatives.must_be :empty?
  end
end
