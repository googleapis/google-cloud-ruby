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

describe Gcloud::Logging::Project, :list_entries, :mock_logging do
  it "lists entries" do
    num_entries = 3

    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project]
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json list_entries_json(num_entries)

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.size.must_equal num_entries
  end

  it "lists entries with find_entries alias" do
    num_entries = 3

    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project]
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json list_entries_json(num_entries)

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.find_entries

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.size.must_equal num_entries
  end

  it "paginates entries" do
    first_list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project]
    first_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], page_token: "next_page_token"
    second_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, first_list_res, [first_list_req]
    mock.expect :list_log_entries, second_list_res, [second_list_req]
    logging.service.mocked_logging = mock

    first_entries = logging.entries
    second_entries = logging.entries token: first_entries.token

    mock.verify

    first_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    first_entries.count.must_equal 3
    first_entries.token.wont_be :nil?
    first_entries.token.must_equal "next_page_token"

    second_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    second_entries.count.must_equal 2
    second_entries.token.must_be :nil?
  end

  it "paginates entries with criteria" do
    first_list_req = Google::Logging::V2::ListLogEntriesRequest.new(
      project_ids: ["project1", "project2", "project3"],
      filter: 'resource.type:"gce_"',
      order_by: "timestamp"
    )
    first_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogEntriesRequest.new(
      project_ids: ["project1", "project2", "project3"],
      filter: 'resource.type:"gce_"',
      order_by: "timestamp",
      page_token: "next_page_token"
    )
    second_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, first_list_res, [first_list_req]
    mock.expect :list_log_entries, second_list_res, [second_list_req]
    logging.service.mocked_logging = mock

    first_entries = logging.entries projects: ["project1", "project2", "project3"],
                                    filter: 'resource.type:"gce_"',
                                    order: "timestamp"
    second_entries = logging.entries projects: ["project1", "project2", "project3"],
                                     filter: 'resource.type:"gce_"',
                                     order: "timestamp",
                                     token: first_entries.token

    mock.verify

    first_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    first_entries.count.must_equal 3
    first_entries.token.wont_be :nil?
    first_entries.token.must_equal "next_page_token"

    second_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    second_entries.count.must_equal 2
    second_entries.token.must_be :nil?
  end

  it "paginates entries using next? and next" do
    first_list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project]
    first_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], page_token: "next_page_token"
    second_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, first_list_res, [first_list_req]
    mock.expect :list_log_entries, second_list_res, [second_list_req]
    logging.service.mocked_logging = mock

    first_entries = logging.entries
    second_entries = first_entries.next

    mock.verify

    first_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    first_entries.count.must_equal 3
    first_entries.next?.must_equal true #must_be :next?

    second_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    second_entries.count.must_equal 2
    second_entries.next?.must_equal false #wont_be :next?
  end

  it "paginates entries using all" do
    first_list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project]
    first_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], page_token: "next_page_token"
    second_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, first_list_res, [first_list_req]
    mock.expect :list_log_entries, second_list_res, [second_list_req]
    logging.service.mocked_logging = mock

    all_entries = logging.entries.all

    mock.verify

    all_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    all_entries.count.must_equal 5
    all_entries.next?.must_equal false #wont_be :next?
  end

  it "paginates entries with criteria using next? and next" do
    first_list_req = Google::Logging::V2::ListLogEntriesRequest.new(
      project_ids: ["project1", "project2", "project3"],
      filter: 'resource.type:"gce_"',
      order_by: "timestamp"
    )
    first_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogEntriesRequest.new(
      project_ids: ["project1", "project2", "project3"],
      filter: 'resource.type:"gce_"',
      order_by: "timestamp",
      page_token: "next_page_token"
    )
    second_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, first_list_res, [first_list_req]
    mock.expect :list_log_entries, second_list_res, [second_list_req]
    logging.service.mocked_logging = mock

    first_entries = logging.entries projects: ["project1", "project2", "project3"],
                                    filter: 'resource.type:"gce_"',
                                    order: "timestamp"
    second_entries = first_entries.next

    mock.verify

    first_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    first_entries.count.must_equal 3
    first_entries.next?.must_equal true #must_be :next?

    second_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    second_entries.count.must_equal 2
    second_entries.next?.must_equal false #wont_be :next?
  end

  it "paginates entries with criteria using all" do
    first_list_req = Google::Logging::V2::ListLogEntriesRequest.new(
      project_ids: ["project1", "project2", "project3"],
      filter: 'resource.type:"gce_"',
      order_by: "timestamp"
    )
    first_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogEntriesRequest.new(
      project_ids: ["project1", "project2", "project3"],
      filter: 'resource.type:"gce_"',
      order_by: "timestamp",
      page_token: "next_page_token"
    )
    second_list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, first_list_res, [first_list_req]
    mock.expect :list_log_entries, second_list_res, [second_list_req]
    logging.service.mocked_logging = mock

    all_entries = logging.entries(projects: ["project1", "project2", "project3"],
                                  filter: 'resource.type:"gce_"',
                                  order: "timestamp").all

    mock.verify

    all_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    all_entries.count.must_equal 5
    all_entries.next?.must_equal false #wont_be :next?
  end

  it "paginates entries with one project" do
    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: ["project1"]
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries projects: "project1"

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with multiple projects" do
    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: ["project1", "project2", "project3"]
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries projects: ["project1", "project2", "project3"]

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with a filter" do
    adv_logs_filter = 'resource.type:"gce_"'

    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], filter: adv_logs_filter
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries filter: adv_logs_filter

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with order asc" do
    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], order_by: "timestamp"
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries order: "timestamp"

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with order desc" do
    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], order_by: "timestamp desc"
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries order: "timestamp desc"

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with max set" do
    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project], page_size: 3
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries max: 3

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries without max set" do
    list_req = Google::Logging::V2::ListLogEntriesRequest.new project_ids: [project]
    list_res = Google::Logging::V2::ListLogEntriesResponse.decode_json(list_entries_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_entries, list_res, [list_req]
    logging.service.mocked_logging = mock

    entries = logging.entries

    mock.verify

    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  def list_entries_json count = 2, token = nil
    {
      entries: count.times.map { random_entry_hash },
      next_page_token: token
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
