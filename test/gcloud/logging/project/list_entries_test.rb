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
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(num_entries)]
    end

    entries = logging.entries
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.size.must_equal num_entries
  end

  it "lists entries with find_entries alias" do
    num_entries = 3
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(num_entries)]
    end

    entries = logging.find_entries
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.size.must_equal num_entries
  end

  it "paginates entries" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_equal "next_page_token"
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(2)]
    end

    first_entries = logging.entries
    first_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    first_entries.count.must_equal 3
    first_entries.token.wont_be :nil?
    first_entries.token.must_equal "next_page_token"

    second_entries = logging.entries token: first_entries.token
    second_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    second_entries.count.must_equal 2
    second_entries.token.must_be :nil?
  end

  it "paginates entries with next? and next" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_equal "next_page_token"
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(2)]
    end

    first_entries = logging.entries
    first_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    first_entries.count.must_equal 3
    first_entries.next?.must_equal true #must_be :next?

    second_entries = first_entries.next
    second_entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    second_entries.count.must_equal 2
    second_entries.next?.must_equal false #wont_be :next?
  end

  it "paginates entries with one project" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal ["project1"]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries projects: "project1"
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with multiple projects" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal ["project1", "project2", "project3"]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries projects: ["project1", "project2", "project3"]
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with a filter" do
    adv_logs_filter = 'resource.type:"gce_"'
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_equal adv_logs_filter
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries filter: adv_logs_filter
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with order asc" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_equal "timestamp"
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries order: "timestamp"
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with order desc" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_equal "timestamp desc"
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries order: "timestamp desc"
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries with max set" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_equal 3
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries max: 3
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  it "paginates entries without max set" do
    mock_connection.post "/v2beta1/entries:list" do |env|
      list_json = JSON.parse env.body
      list_json["projectIds"].must_equal [project]
      list_json["filter"].must_be :nil?
      list_json["orderBy"].must_be :nil?
      list_json["pageToken"].must_be :nil?
      list_json["maxResults"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       list_entries_json(3, "next_page_token")]
    end

    entries = logging.entries
    entries.each { |m| m.must_be_kind_of Gcloud::Logging::Entry }
    entries.count.must_equal 3
    entries.token.wont_be :nil?
    entries.token.must_equal "next_page_token"
  end

  def list_entries_json count = 2, token = nil
    {
      entries: count.times.map { random_entry_hash },
      nextPageToken: token
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
