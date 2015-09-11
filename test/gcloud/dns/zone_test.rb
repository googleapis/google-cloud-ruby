# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Dns::Zone, :mock_dns do
  # Create a zone object with the project's mocked connection object
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone_hash) { random_zone_hash zone_name, zone_dns }
  let(:zone) { Gcloud::Dns::Zone.from_gapi zone_hash, dns.connection }
  let(:record_name) { "example.com." }
  let(:record_ttl)  { 86400 }
  let(:record_type) { "A" }
  let(:record_data) { ["1.2.3.4"] }

  it "knows its attributes" do
    zone.name.must_equal zone_name
    zone.dns.must_equal zone.dns
    zone.description.must_equal ""
    zone.id.must_equal 123456789
    zone.name_servers.must_equal [ "virtual-dns-1.google.example",
                                   "virtual-dns-2.google.example" ]
    zone.name_server_set.must_be :nil?

    creation_time = Time.new 2015, 1, 1, 0, 0, 0, 0
    zone.created_at.must_equal creation_time
  end

  it "can delete itself" do
    mock_connection.delete "/dns/v1/projects/#{project}/managedZones/#{zone.id}" do |env|
      [200, {"Content-Type" => "application/json"}, ""]
    end

    zone.delete
  end

  it "finds a change" do
    found_change = "dns-change-1234567890"

    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{found_change}" do |env|
      [200, {"Content-Type" => "application/json"},
       find_change_json(found_change)]
    end

    change = zone.change found_change
    change.must_be_kind_of Gcloud::Dns::Change
    change.id.must_equal found_change
  end

  it "returns nil when it cannot find a change" do
    unfound_change = "dns-change-0987654321"

    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes/#{unfound_change}" do |env|
      [404, {"Content-Type" => "application/json"},
       ""]
    end

    change = zone.change unfound_change
    change.must_be :nil?
  end

  def find_change_json change_id
    hash = random_change_hash
    hash["id"] = change_id
    hash.to_json
  end

  it "lists changes" do
    num_changes = 3
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.wont_include "maxResults"
      env.params.wont_include "sortBy"
      env.params.wont_include "sortOrder"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(num_changes)]
    end

    changes = zone.changes
    changes.size.must_equal num_changes
    changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
  end

  it "lists changes with max set" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      env.params.wont_include "sortBy"
      env.params.wont_include "sortOrder"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(3, "next_page_token")]
    end

    changes = zone.changes max: 3
    changes.count.must_equal 3
    changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    changes.token.wont_be :nil?
    changes.token.must_equal "next_page_token"
  end

  it "lists changes with order set to asc" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.must_include "sortBy"
      env.params["sortBy"].must_equal "changeSequence"
      env.params.must_include "sortOrder"
      env.params["sortOrder"].must_equal "ascending"
      env.params.wont_include "maxResults"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(3, "next_page_token")]
    end

    changes = zone.changes order: :asc
    changes.count.must_equal 3
    changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    changes.token.wont_be :nil?
    changes.token.must_equal "next_page_token"
  end

  it "lists changes with order set to desc" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.must_include "sortBy"
      env.params["sortBy"].must_equal "changeSequence"
      env.params.must_include "sortOrder"
      env.params["sortOrder"].must_equal "descending"
      env.params.wont_include "maxResults"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(3, "next_page_token")]
    end

    changes = zone.changes order: :desc
    changes.count.must_equal 3
    changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    changes.token.wont_be :nil?
    changes.token.must_equal "next_page_token"
  end

  it "paginates changes" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(2)]
    end

    first_changes = zone.changes
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    first_changes.token.wont_be :nil?
    first_changes.token.must_equal "next_page_token"

    second_changes = zone.changes token: first_changes.token
    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    second_changes.token.must_be :nil?
  end

  it "paginates changes with next? and next" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_changes_json(2)]
    end

    first_changes = zone.changes
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    first_changes.next?.must_equal true

    second_changes = first_changes.next
    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Gcloud::Dns::Change }
    second_changes.next?.must_equal false
  end

  def list_changes_json count = 2, token = nil
    changes = count.times.map do
      ch = random_change_hash
      ch["id"] = "dns-change-#{rand 9999999}"
      ch
    end
    hash = { "kind" => "dns#changesListResponse", "changes" => changes }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end

  it "can create a record" do
    record = zone.record record_name, record_ttl, record_type, record_data

    record.name.must_equal record_name
    record.ttl.must_equal  record_ttl
    record.type.must_equal record_type
    record.data.must_equal record_data
  end
end
