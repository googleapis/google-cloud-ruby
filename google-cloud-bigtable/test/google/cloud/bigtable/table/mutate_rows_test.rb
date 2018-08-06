# frozen_string_literal: true

# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigtable::Table, :mutate_rows, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:app_profile_id) { "test-app-profile-id" }
  let(:row_key) { "rk" }
  let(:family) {  "cf" }
  let(:qualifier) {  "field1" }
  let(:cell_value) { "xyz" }
  let(:timestamp) { Time.now.to_i * 1000 }
  let(:mutation_gprc) {
    Google::Bigtable::V2::Mutation.new(set_cell: {
      family_name: family, column_qualifier: qualifier, value: cell_value, timestamp_micros: timestamp
    })
  }
  let(:mutation_entry_grpc){
    Google::Bigtable::V2::MutateRowsRequest::Entry.new(
      row_key: row_key,
      mutations: [mutation_gprc]
    )
  }
  let(:req_entries_grpc) do
    2.times.map do |i|
      mutation = Google::Bigtable::V2::Mutation.new(set_cell: {
        family_name: "cf#{i}",
        column_qualifier: "field01",
        timestamp_micros: Time.now.to_i * 1000,
        value: "XYZ-#{i}"
      })
      Google::Bigtable::V2::MutateRowsRequest::Entry.new(
        row_key:  "rk-#{i}",
        mutations: [mutation]
      )
    end
  end
  let(:table) {
    bigtable.table(instance_id, table_id, app_profile_id: app_profile_id)
  }

  it "mutate rows with success mutation response" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock
    res = Google::Bigtable::V2::MutateRowsResponse.new(
      entries: [{
        index: 0,
        status: { code: Google::Rpc::Code::OK, message: "success", details: [] }
      }]
    )

    mock.expect :mutate_rows, [res], [
      table_path(instance_id, table_id),
      [mutation_entry_grpc],
      app_profile_id: app_profile_id
    ]

    entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
    entry.set_cell(family, qualifier, cell_value, timestamp: timestamp)

    statuses = table.mutate_rows([entry])

    mock.verify
    statuses.length.must_equal 1
    statuses[0].index.must_equal 0
    statuses[0].status.code.must_equal Google::Rpc::Code::OK
  end

  it "do not retry for cell timestamp set to server time(-1)" do
    mutation = Google::Bigtable::V2::Mutation.new(set_cell: {
      family_name: family, column_qualifier: qualifier, value: cell_value, timestamp_micros: -1
    })
    entry = Google::Bigtable::V2::MutateRowsRequest::Entry.new(
      row_key: row_key,
      mutations: [ mutation ]
    )

    res = Google::Bigtable::V2::MutateRowsResponse.new(
      entries: [{
        index: 0,
        status: { code: Google::Rpc::Code::DEADLINE_EXCEEDED, message: "failed", details: [] }
      }]
    )

    mock = OpenStruct.new(
      retry_count: 0,
      expected_table_path: table_path(instance_id, table_id),
      expected_req_entries: [entry],
      expected_req_app_profile_id: app_profile_id,
      expected_response: [res]
    )
    def mock.mutate_rows(parent, mutation_entries, app_profile_id: nil)
      self.retry_count += 1
      parent.must_equal expected_table_path
      mutation_entries.must_equal expected_req_entries
      app_profile_id.must_equal expected_req_app_profile_id
      return expected_response
    end

    bigtable.service.mocked_client = mock

    entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
    entry.set_cell(family, qualifier, cell_value, timestamp: -1)


    statuses = table.mutate_rows([entry])

    mock.retry_count.must_equal 1
    statuses.length.must_equal 1
    statuses[0].index.must_equal 0
    statuses[0].status.code.must_equal Google::Rpc::Code::DEADLINE_EXCEEDED
  end

  it "retry for failed mutation with 3 times" do
    req_entries = req_entries_grpc
    retry_entries = [
      req_entries,
      [req_entries.last],
      [req_entries.last]
    ]

    retry_responses = [
      [
        { index: 0, status: { code: Google::Rpc::Code::OK, message: "success" }},
        { index: 1, status: { code: Google::Rpc::Code::DEADLINE_EXCEEDED, message: "failed" }}
      ],
      [
        { index: 0, status: { code: Google::Rpc::Code::DEADLINE_EXCEEDED, message: "failed" }}
      ],
      [
        { index: 0, status: { code: Google::Rpc::Code::DEADLINE_EXCEEDED, message: "failed" }}
      ]
    ]

    retry_responses = retry_responses.map do |res_entries|
      [Google::Bigtable::V2::MutateRowsResponse.new(entries: res_entries)]
    end

    expected_response = Google::Bigtable::V2::MutateRowsResponse.new(entries: [
      { index: 0, status: { code: Google::Rpc::Code::OK, message: "success"}},
      { index: 1, status: { code: Google::Rpc::Code::DEADLINE_EXCEEDED, message: "failed"}}
    ])

    mock = OpenStruct.new(
      retry_count: 0,
      expected_table_path: table_path(instance_id, table_id),
      expected_req_app_profile_id: app_profile_id,
      req_retry_entries: retry_entries,
      req_retry_response: retry_responses
    )
    def mock.mutate_rows(parent, mutation_entries, app_profile_id: nil)
      parent.must_equal expected_table_path
      mutation_entries.must_equal req_retry_entries[self.retry_count]
      app_profile_id.must_equal expected_req_app_profile_id

      res = req_retry_response[self.retry_count]
      self.retry_count += 1
      res
    end

    bigtable.service.mocked_client = mock

    mutation_entries = req_entries.map do |r|
      entry = Google::Cloud::Bigtable::MutationEntry.new(r.row_key)
      entry.mutations.concat(r.mutations)
      entry
    end
    statuses = table.mutate_rows(mutation_entries)

    mock.retry_count.must_equal 3
    statuses.length.must_equal 2
    statuses.must_equal expected_response.entries
  end

  it "stop retry on success of all mutations" do
    req_entries = req_entries_grpc
    retry_entries = [
      req_entries,
      [req_entries.last]
    ]

    retry_responses = [
      [
        { index: 0, status: { code: Google::Rpc::Code::OK, message: "success" }},
        { index: 1, status: { code: Google::Rpc::Code::DEADLINE_EXCEEDED, message: "failed" }}
      ],
      [
        { index: 0, status: { code: Google::Rpc::Code::OK, message: "success" }}
      ]
    ]

    retry_responses = retry_responses.map do |res_entries|
      [Google::Bigtable::V2::MutateRowsResponse.new(entries: res_entries)]
    end

    expected_response = Google::Bigtable::V2::MutateRowsResponse.new(entries: [
      { index: 0, status: { code: Google::Rpc::Code::OK, message: "success"}},
      { index: 1, status: { code: Google::Rpc::Code::OK, message: "success"}}
    ])

    mock = OpenStruct.new(
      retry_count: 0,
      expected_table_path: table_path(instance_id, table_id),
      expected_req_app_profile_id: app_profile_id,
      req_retry_entries: retry_entries,
      req_retry_response: retry_responses
    )
    def mock.mutate_rows(parent, mutation_entries, app_profile_id: nil)
      parent.must_equal expected_table_path
      mutation_entries.must_equal req_retry_entries[self.retry_count]
      app_profile_id.must_equal expected_req_app_profile_id

      res = req_retry_response[self.retry_count]
      self.retry_count += 1
      res
    end

    bigtable.service.mocked_client = mock

    mutation_entries = req_entries.map do |r|
      entry = Google::Cloud::Bigtable::MutationEntry.new(r.row_key)
      entry.mutations.concat(r.mutations)
      entry
    end
    statuses = table.mutate_rows(mutation_entries)

    mock.retry_count.must_equal 2
    statuses.length.must_equal 2
    statuses.must_equal expected_response.entries
  end
end
