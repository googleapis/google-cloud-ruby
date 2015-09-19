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
  let(:record_type) { "A" }
  let(:record_ttl)  { 86400 }
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

  it "lists records" do
    num_records = 3
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      [200, {"Content-Type" => "application/json"},
       list_records_json(num_records)]
    end

    records = zone.records
    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
  end

  it "lists records with name set" do
    num_records = 3
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params["name"].must_equal record_name
      [200, {"Content-Type" => "application/json"},
       list_records_json(num_records)]
    end

    records = zone.records name: record_name
    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
  end

  it "lists records with name and type set" do
    num_records = 3
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params["name"].must_equal record_name
      env.params["type"].must_equal record_type
      [200, {"Content-Type" => "application/json"},
       list_records_json(num_records)]
    end

    records = zone.records name: record_name, type: record_type
    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
  end

  it "paginates records" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_records_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_records_json(2)]
    end

    first_records = zone.records
    first_records.count.must_equal 3
    first_records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    first_records.token.wont_be :nil?
    first_records.token.must_equal "next_page_token"

    second_records = zone.records token: first_records.token
    second_records.count.must_equal 2
    second_records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    second_records.token.must_be :nil?
  end

  it "paginates records with next? and next" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_records_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_records_json(2)]
    end

    first_records = zone.records
    first_records.count.must_equal 3
    first_records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    first_records.next?.must_equal true

    second_records = first_records.next
    second_records.count.must_equal 2
    second_records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    second_records.next?.must_equal false
  end

  it "loads all records with all" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_records_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_records_json(2)]
    end

    all_records = zone.records
    all_records.count.must_equal 3
    all_records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    all_records.next?.must_equal true

    all_records.all
    all_records.count.must_equal 5
    all_records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    all_records.next?.must_equal false

    # Calling all again does nothing, returns self
    all_records.must_equal all_records.all
  end

  it "paginates records with max set" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type" => "application/json"},
       list_records_json(3, "next_page_token")]
    end

    records = zone.records max: 3
    records.count.must_equal 3
    records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    records.token.wont_be :nil?
    records.token.must_equal "next_page_token"
  end

  it "paginates records without max set" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type" => "application/json"},
       list_records_json(3, "next_page_token")]
    end

    records = zone.records
    records.count.must_equal 3
    records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    records.token.wont_be :nil?
    records.token.must_equal "next_page_token"
  end

  it "can create a record" do
    record = zone.record record_name, record_type, record_ttl, record_data

    record.name.must_equal record_name
    record.ttl.must_equal  record_ttl
    record.type.must_equal record_type
    record.data.must_equal record_data
  end

  it "adds and removes records with update" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."
    to_remove = zone.record "example.net.", "A", 18600, "example.org."

    mock_connection.post "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      json = JSON.parse env.body
      json["additions"].count.must_equal 1
      json["deletions"].count.must_equal 1
      json["additions"].first.must_equal to_add.to_gapi
      json["deletions"].first.must_equal to_remove.to_gapi
      [200, {"Content-Type" => "application/json"},
       create_change_json(to_add, to_remove)]
    end

    change = zone.update to_add, to_remove
    change.must_be_kind_of Gcloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.first.name.must_equal to_add.name
    change.additions.first.type.must_equal to_add.type
    change.additions.first.ttl.must_equal  to_add.ttl
    change.additions.first.data.must_equal to_add.data
    change.deletions.first.name.must_equal to_remove.name
    change.deletions.first.type.must_equal to_remove.type
    change.deletions.first.ttl.must_equal  to_remove.ttl
    change.deletions.first.data.must_equal to_remove.data
  end

  it "adds records" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."

    mock_connection.post "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      json = JSON.parse env.body
      json["additions"].count.must_equal 1
      json["deletions"].count.must_equal 0
      json["additions"].first.must_equal to_add.to_gapi
      json["deletions"].must_be :empty?
      [200, {"Content-Type" => "application/json"},
       create_change_json(to_add, [])]
    end

    change = zone.add to_add
    change.must_be_kind_of Gcloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.first.name.must_equal to_add.name
    change.additions.first.ttl.must_equal  to_add.ttl
    change.additions.first.type.must_equal to_add.type
    change.additions.first.data.must_equal to_add.data
    change.deletions.must_be :empty?
 end

  it "removes records" do
    to_remove = zone.record "example.net.", "A", 18600, "example.org."

    mock_connection.post "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      json = JSON.parse env.body
      json["additions"].count.must_equal 0
      json["deletions"].count.must_equal 1
      json["additions"].must_be :empty?
      json["deletions"].first.must_equal to_remove.to_gapi
      [200, {"Content-Type" => "application/json"},
       create_change_json([], to_remove)]
    end

    change = zone.remove to_remove
    change.must_be_kind_of Gcloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.must_be :empty?
    change.deletions.first.name.must_equal to_remove.name
    change.deletions.first.type.must_equal to_remove.type
    change.deletions.first.ttl.must_equal  to_remove.ttl
    change.deletions.first.data.must_equal to_remove.data
  end

  def create_change_json to_add, to_remove
    hash = random_change_hash
    hash["id"] = "dns-change-created"
    hash["additions"] = Array(to_add).map &:to_gapi
    hash["deletions"] = Array(to_remove).map &:to_gapi
    hash.to_json
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

  def list_records_json count = 2, token = nil
    seed = rand 99999
    name = "example-#{seed}.com."
    records = count.times.map do
      random_record_hash name, "A", seed, ["1.2.3.4"]
    end
    hash = { "kind" => "dns#resourceRecordSet", "rrsets" => records }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end
end
