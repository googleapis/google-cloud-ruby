# Copyright 2017 Google LLC
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

describe Google::Cloud::Firestore::CommitResponse, :mock_firestore do
  let(:update_time) { Time.parse "2017-12-20T05:33:53.428000000Z" }
  let(:update_timestamp) { Google::Cloud::Firestore::Convert.time_to_timestamp update_time }
  let(:commit_time) { Time.parse "2017-12-20T05:35:21.295000000Z" }
  let(:commit_timestamp) { Google::Cloud::Firestore::Convert.time_to_timestamp update_time }

  it "can represent no result" do
    grpc_response = nil

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, []

    _(commit_response.commit_time).must_be :nil?
    _(commit_response.write_results).must_be :empty?
  end

  it "can represent an empty result" do
    grpc_response = Google::Cloud::Firestore::V1::CommitResponse.new

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, []

    _(commit_response.commit_time).must_be :nil?
    _(commit_response.write_results).must_be :empty?
  end

  it "can represent results with transforms" do
    grpc_response = Google::Cloud::Firestore::V1::CommitResponse.new(
      write_results: [
        {
          update_time: update_timestamp,
          transform_results: [
            { timestamp_value: update_timestamp },
            { timestamp_value: update_timestamp },
            { timestamp_value: update_timestamp }
          ]
        }
      ],
      commit_time: commit_timestamp
    )

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    _(commit_response.commit_time).must_equal update_time
    _(commit_response.write_results.size).must_equal 1
    commit_response.write_results.first.tap do |write_result|
      _(write_result.update_time).must_equal update_time
    end
  end

  it "can represent results with and without update_time" do
    grpc_response = Google::Cloud::Firestore::V1::CommitResponse.new(
      write_results: [
        { update_time: update_timestamp },
        {}
      ],
      commit_time: commit_timestamp
    )

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    _(commit_response.commit_time).must_equal update_time
    _(commit_response.write_results.size).must_equal 1
    _(commit_response.write_results[0].update_time).must_equal update_time
  end

  it "can represent results without and with update_time" do
    grpc_response = Google::Cloud::Firestore::V1::CommitResponse.new(
      write_results: [
        {},
        { update_time: update_timestamp }
      ],
      commit_time: commit_timestamp
    )

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    _(commit_response.commit_time).must_equal update_time
    _(commit_response.write_results.size).must_equal 1
    _(commit_response.write_results[0].update_time).must_equal update_time
  end

  it "can represent results without update_time" do
    grpc_response = Google::Cloud::Firestore::V1::CommitResponse.new(
      write_results: [
        {},
        {}
      ],
      commit_time: commit_timestamp
    )

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    _(commit_response.commit_time).must_equal update_time
    _(commit_response.write_results.size).must_equal 1
    _(commit_response.write_results[0].update_time).must_equal update_time
  end

  it "can represent results without mismatched writes" do
    grpc_response = Google::Cloud::Firestore::V1::CommitResponse.new(
      write_results: [
        {},
        {}
      ],
      commit_time: commit_timestamp
    )

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two], :three]

    _(commit_response.commit_time).must_equal update_time
    _(commit_response.write_results.size).must_equal 2
    _(commit_response.write_results[0].update_time).must_equal update_time
    _(commit_response.write_results[1].update_time).must_equal update_time
  end
end
