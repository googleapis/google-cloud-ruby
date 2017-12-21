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

  it "can represent no result" do
    grpc_response = nil

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, []

    commit_response.commit_time.must_be :nil?
    commit_response.write_results.must_be :empty?
  end

  it "can represent an empty result" do
    grpc_response = Google::Firestore::V1beta1::CommitResponse.new

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, []

    commit_response.commit_time.must_be :nil?
    commit_response.write_results.must_be :empty?
  end

  it "can represent results with transforms" do
    json = "{\"writeResults\":[{\"updateTime\":{\"seconds\":1513748033,\"nanos\":441316000},\"transformResults\":[{\"timestampValue\":{\"seconds\":1513748033,\"nanos\":428000000}},{\"timestampValue\":{\"seconds\":1513748033,\"nanos\":428000000}},{\"timestampValue\":{\"seconds\":1513748033,\"nanos\":428000000}}]}],\"commitTime\":{\"seconds\":1513748033,\"nanos\":441316000}}"
    grpc_response = Google::Firestore::V1beta1::CommitResponse.decode_json json

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    commit_response.commit_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    commit_response.write_results.size.must_equal 1
    commit_response.write_results.first.tap do |write_result|
      write_result.update_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    end
  end

  it "can represent results with and without updateTime" do
    json = "{\"writeResults\":[{\"updateTime\":{\"seconds\":1513748093,\"nanos\":441316000}}, {}],\"commitTime\":{\"seconds\":1513748033,\"nanos\":441316000}}"
    grpc_response = Google::Firestore::V1beta1::CommitResponse.decode_json json

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    commit_response.commit_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    commit_response.write_results.size.must_equal 1
    commit_response.write_results[0].update_time.must_be_close_to Time.parse("2017-12-19 22:34:53 -0700"), 1
  end

  it "can represent results without and with updateTime" do
    json = "{\"writeResults\":[{}, {\"updateTime\":{\"seconds\":1513748093,\"nanos\":441316000}}],\"commitTime\":{\"seconds\":1513748033,\"nanos\":441316000}}"
    grpc_response = Google::Firestore::V1beta1::CommitResponse.decode_json json

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    commit_response.commit_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    commit_response.write_results.size.must_equal 1
    commit_response.write_results[0].update_time.must_be_close_to Time.parse("2017-12-19 22:34:53 -0700"), 1
  end

  it "can represent results without updateTime" do
    json = "{\"writeResults\":[{}, {}],\"commitTime\":{\"seconds\":1513748033,\"nanos\":441316000}}"
    grpc_response = Google::Firestore::V1beta1::CommitResponse.decode_json json

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two]]

    commit_response.commit_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    commit_response.write_results.size.must_equal 1
    commit_response.write_results[0].update_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
  end

  it "can represent results without mismatched writes" do
    json = "{\"writeResults\":[{}, {}],\"commitTime\":{\"seconds\":1513748033,\"nanos\":441316000}}"
    grpc_response = Google::Firestore::V1beta1::CommitResponse.decode_json json

    commit_response = Google::Cloud::Firestore::CommitResponse.from_grpc grpc_response, [[:one, :two], :three]

    commit_response.commit_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    commit_response.write_results.size.must_equal 2
    commit_response.write_results[0].update_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
    commit_response.write_results[1].update_time.must_be_close_to Time.parse("2017-12-19 22:33:53 -0700"), 1
  end
end
