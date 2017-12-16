# Copyright 2015 Google LLC
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

describe Google::Cloud::Dns::Zone, :mock_dns do
  # Create a zone object with the project's mocked connection object
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone_gapi) { random_zone_gapi zone_name, zone_dns }
  let(:zone) { Google::Cloud::Dns::Zone.from_gapi zone_gapi, dns.service }
  let(:record_name) { "example.com." }
  let(:record_type) { "A" }
  let(:record_ttl)  { 86400 }
  let(:record_data) { ["1.2.3.4"] }
  let(:soa) { Google::Cloud::Dns::Record.new "example.com.", "SOA", 18600, "ns-cloud-b1.googledomains.com. dns-admin.google.com. 0 21600 3600 1209600 300" }
  let(:updated_soa) { Google::Cloud::Dns::Record.new "example.com.", "SOA", 18600, "ns-cloud-b1.googledomains.com. dns-admin.google.com. 1 21600 3600 1209600 300" }

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
    mock = Minitest::Mock.new
    mock.expect :delete_managed_zone, nil, [project, zone.id]

    dns.service.mocked_service = mock
    zone.delete
    mock.verify
  end

  it "can forcefuly delete itself" do
    mock = Minitest::Mock.new
    # get all records
    existing_records = list_records_gapi(5)
    mock.expect :list_resource_record_sets, existing_records, [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]

    # delete non-essential records and update SOA
    mock.expect :list_resource_record_sets, existing_records, [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: [],
      deletions: existing_records.rrsets
    )
    mock.expect :create_change, done_change_gapi, [project, zone.id, new_change]

    # delete zone call
    mock.expect :delete_managed_zone, nil, [project, zone.id]

    dns.service.mocked_service = mock
    zone.delete force: true
    mock.verify
  end

  it "can clear all non-essential records" do
    mock = Minitest::Mock.new
    # get all records
    existing_records = list_records_gapi(5)
    mock.expect :list_resource_record_sets, existing_records, [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]

    # delete non-essential records and update SOA
    mock.expect :list_resource_record_sets, existing_records, [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: [],
      deletions: existing_records.rrsets
    )
    mock.expect :create_change, done_change_gapi, [project, zone.id, new_change]

    dns.service.mocked_service = mock
    zone.clear!
    mock.verify
  end

  it "finds a change" do
    found_change = "dns-change-1234567890"
    mock = Minitest::Mock.new
    mock.expect :get_change, find_change_gapi(found_change), [project, zone.id, found_change]

    dns.service.mocked_service = mock
    change = zone.change found_change
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal found_change
  end

  it "returns nil when it cannot find a change" do
    stub = Object.new
    def stub.get_change *args
      raise Google::Apis::ClientError.new nil, status_code: 404
    end

    dns.service.mocked_service = stub
    change = zone.change "dns-change-0987654321"
    change.must_be :nil?
  end

  it "lists changes" do
    num_changes = 3
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(num_changes), [project, zone.id, {max_results: nil, page_token: nil, sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock
    changes = zone.changes
    mock.verify

    changes.size.must_equal num_changes
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "lists changes with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: 3, page_token: nil, sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock
    changes = zone.changes max: 3
    mock.verify

    changes.count.must_equal 3
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    changes.token.wont_be :nil?
    changes.token.must_equal "next_page_token"
  end

  it "lists changes with order set to asc" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: "changeSequence", sort_order: "ascending"}]

    dns.service.mocked_service = mock
    changes = zone.changes order: :asc
    mock.verify

    changes.count.must_equal 3
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    changes.token.wont_be :nil?
    changes.token.must_equal "next_page_token"
  end

  it "lists changes with order set to desc" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: "changeSequence", sort_order: "descending"}]

    dns.service.mocked_service = mock
    changes = zone.changes order: :desc
    mock.verify

    changes.count.must_equal 3
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    changes.token.wont_be :nil?
    changes.token.must_equal "next_page_token"
  end

  it "paginates changes" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock

    first_changes = zone.changes
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    first_changes.token.wont_be :nil?
    first_changes.token.must_equal "next_page_token"

    second_changes = zone.changes token: first_changes.token
    mock.verify

    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    second_changes.token.must_be :nil?
  end

  it "paginates changes with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock

    first_changes = zone.changes
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    first_changes.next?.must_equal true

    second_changes = first_changes.next
    mock.verify

    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    second_changes.next?.must_equal false
  end

  it "paginates changes with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: 3, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: 3, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock

    first_changes = zone.changes max: 3
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    first_changes.next?.must_equal true

    second_changes = first_changes.next
    mock.verify

    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    second_changes.next?.must_equal false
  end

  it "paginates changes with next? and next and order set to asc" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: "changeSequence", sort_order: "ascending"}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: "changeSequence", sort_order: "ascending"}]

    dns.service.mocked_service = mock

    first_changes = zone.changes order: :asc
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    first_changes.next?.must_equal true

    second_changes = first_changes.next
    mock.verify

    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    second_changes.next?.must_equal false
  end

  it "paginates changes with next? and next and order set to desc" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: "changeSequence", sort_order: "descending"}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: "changeSequence", sort_order: "descending"}]

    dns.service.mocked_service = mock

    first_changes = zone.changes order: :desc
    first_changes.count.must_equal 3
    first_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    first_changes.next?.must_equal true

    second_changes = first_changes.next
    mock.verify

    second_changes.count.must_equal 2
    second_changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
    second_changes.next?.must_equal false
  end

  it "paginates changes with all" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock

    changes = zone.changes.all.to_a
    mock.verify

    changes.count.must_equal 5
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "paginates changes with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: 3, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: 3, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock
    changes = zone.changes(max: 3).all.to_a
    mock.verify

    changes.count.must_equal 5
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "paginates changes with all and order set to asc" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: "changeSequence", sort_order: "ascending"}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: "changeSequence", sort_order: "ascending"}]

    dns.service.mocked_service = mock

    changes = zone.changes(order: :asc).all.to_a
    mock.verify

    changes.count.must_equal 5
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "paginates changes with all and order set to desc" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: "changeSequence", sort_order: "descending"}]
    mock.expect :list_changes, list_changes_gapi(2), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: "changeSequence", sort_order: "descending"}]

    dns.service.mocked_service = mock
    changes = zone.changes(order: :desc).all.to_a
    mock.verify

    changes.count.must_equal 5
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "paginates changes with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(3, "second_page_token"), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock

    changes = zone.changes.all.take(5)
    mock.verify

    changes.count.must_equal 5
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "paginates changes with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_changes, list_changes_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, page_token: nil, sort_by: nil, sort_order: nil}]
    mock.expect :list_changes, list_changes_gapi(3, "second_page_token"), [project, zone.id, {max_results: nil, page_token: "next_page_token", sort_by: nil, sort_order: nil}]

    dns.service.mocked_service = mock

    changes = zone.changes.all(request_limit: 1).to_a
    mock.verify

    changes.count.must_equal 6
    changes.each { |z| z.must_be_kind_of Google::Cloud::Dns::Change }
  end

  it "lists records" do
    num_records = 3
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(num_records), [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]

    dns.service.mocked_service = mock
    records = zone.records
    mock.verify

    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "lists records with name param" do
    num_records = 3
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(num_records), [project, zone.id, {max_results: nil, name: record_name, page_token: nil, type: nil}]

    dns.service.mocked_service = mock
    records = zone.records record_name
    mock.verify

    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "lists records with name and type params" do
    num_records = 3
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(num_records), [project, zone.id, {max_results: nil, name: record_name, page_token: nil, type: record_type}]

    dns.service.mocked_service = mock
    records = zone.records record_name, record_type
    mock.verify

    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "lists records with subdomain and type params" do
    num_records = 3
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(num_records), [project, zone.id, {max_results: nil, name: "www.example.com.", page_token: nil, type: "A"}]

    dns.service.mocked_service = mock
    records = zone.records "www", "A"
    mock.verify

    records.size.must_equal num_records
    records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "paginates records" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(2), [project, zone.id, {max_results: nil, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    first_records = zone.records
    first_records.count.must_equal 3
    first_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    first_records.token.wont_be :nil?
    first_records.token.must_equal "next_page_token"

    second_records = zone.records token: first_records.token
    mock.verify

    second_records.count.must_equal 2
    second_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    second_records.token.must_be :nil?
  end

  it "paginates records with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(2), [project, zone.id, {max_results: nil, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    first_records = zone.records
    first_records.count.must_equal 3
    first_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    first_records.next?.must_equal true

    second_records = first_records.next
    mock.verify

    second_records.count.must_equal 2
    second_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    second_records.next?.must_equal false
  end

  it "paginates records with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: 3, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(2), [project, zone.id, {max_results: 3, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    first_records = zone.records max: 3
    first_records.count.must_equal 3
    first_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    first_records.next?.must_equal true

    second_records = first_records.next
    mock.verify

    second_records.count.must_equal 2
    second_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    second_records.next?.must_equal false
  end

  it "loads all records with all" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(2), [project, zone.id, {max_results: nil, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    all_records = zone.records.all.to_a
    mock.verify

    all_records.count.must_equal 5
    all_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "paginates records with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: 3, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(2), [project, zone.id, {max_results: 3, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    all_records = zone.records(max: 3).all.to_a
    mock.verify

    all_records.count.must_equal 5
    all_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "loads all records with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(2), [project, zone.id, {max_results: nil, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    all_records = zone.records.all.take(5)
    mock.verify

    all_records.count.must_equal 5
    all_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "loads all records with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi(3, "next_page_token"), [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]
    mock.expect :list_resource_record_sets, list_records_gapi(3, "second_page_token"), [project, zone.id, {max_results: nil, name: nil, page_token: "next_page_token", type: nil}]

    dns.service.mocked_service = mock

    all_records = zone.records.all(request_limit: 1).to_a
    mock.verify

    all_records.count.must_equal 6
    all_records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
  end

  it "can create a record" do
    record = zone.record record_name, record_type, record_ttl, record_data

    record.name.must_equal record_name
    record.type.must_equal record_type
    record.ttl.must_equal  record_ttl
    record.data.must_equal record_data
  end

  it "creates a record with a fully domain name when not given one" do
    record = zone.record "example.com", record_type, record_ttl, record_data

    record.name.must_equal "example.com." # it appends "."
    record.type.must_equal record_type
    record.ttl.must_equal  record_ttl
    record.data.must_equal record_data
  end

  it "creates a record when given nil for the domain name" do
    record = zone.record nil, record_type, record_ttl, record_data

    record.name.must_equal "example.com."
    record.type.must_equal record_type
    record.ttl.must_equal  record_ttl
    record.data.must_equal record_data
  end

  it "creates a record when given an empty string for the domain name" do
    record = zone.record "", record_type, record_ttl, record_data

    record.name.must_equal "example.com."
    record.type.must_equal record_type
    record.ttl.must_equal  record_ttl
    record.data.must_equal record_data
  end

  it "creates a record when given '@' for the domain name" do
    record = zone.record "@", record_type, record_ttl, record_data

    record.name.must_equal "example.com."
    record.type.must_equal record_type
    record.ttl.must_equal  record_ttl
    record.data.must_equal record_data
  end

  it "creates a record with a qualified name when given only a subdomain" do
    record = zone.record "www", record_type, record_ttl, record_data

    record.name.must_equal "www.example.com."
    record.type.must_equal record_type
    record.ttl.must_equal  record_ttl
    record.data.must_equal record_data
  end

  it "creates a record without changing name when it is a NAPTR record" do
    record = zone.record "1.2.3.4", "NAPTR", 3600, "10 100 \"U\" \"E2U+sip\" \"!^\\+44111555(.+)$!sip:7\\1@sip.example.com!\" ."

    record.name.must_equal "1.2.3.4"
    record.type.must_equal "NAPTR"
    record.ttl.must_equal  3600
    record.data.must_equal ["10 100 \"U\" \"E2U+sip\" \"!^\\+44111555(.+)$!sip:7\\1@sip.example.com!\" ."]
  end

  it "adds and removes records with update" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."
    to_remove = zone.record "example.net.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi(to_add, to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.update to_add, to_remove
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
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

  it "returns nil when calling update without any records to change" do
    change = zone.update [], []
    change.must_be :nil?
  end

  it "returns nil when calling update with records that have not changed" do
    a_record = zone.record zone.dns, "A", 18600, "0.0.0.0"
    change = zone.update a_record, a_record
    change.must_be :nil?
  end

  it "only updates the records that have changed" do
    a_record = zone.record zone.dns, "A", 18600, "example.com."
    cname_record = zone.record zone.dns, "CNAME", 86400, "example.com."
    mx_record = zone.record zone.dns, "MX", 86400, ["10 mail.#{zone.dns}",
                                                    "20 mail2.#{zone.dns}"]
    to_add = [a_record, cname_record, mx_record]
    to_remove = to_add.map(&:dup)
    to_remove.first.data = ["example.org."]

    mock = Minitest::Mock.new
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.first.to_gapi) << updated_soa.to_gapi),
      deletions: (Array(to_remove.first.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([to_add.first], [to_remove.first]), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.update to_add, to_remove
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.first.name.must_equal to_add.first.name
    change.additions.first.type.must_equal to_add.first.type
    change.additions.first.ttl.must_equal  to_add.first.ttl
    change.additions.first.data.must_equal to_add.first.data
    change.deletions.first.name.must_equal to_remove.first.name
    change.deletions.first.type.must_equal to_remove.first.type
    change.deletions.first.ttl.must_equal  to_remove.first.ttl
    change.deletions.first.data.must_equal to_remove.first.data
  end

  it "adds a record" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."

    mock = Minitest::Mock.new
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: Array(soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([to_add, updated_soa], soa), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.add "example.net.", "A", 18600, "example.com."
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.first.name.must_equal to_add.name
    change.additions.first.type.must_equal to_add.type
    change.additions.first.ttl.must_equal  to_add.ttl
    change.additions.first.data.must_equal to_add.data
    change.additions[1].data.must_equal updated_soa.data
    change.deletions.first.data.must_equal soa.data
  end

  it "adds a record with a subdomain" do
    to_add = zone.record "www.example.com.", "A", 18600, "example.net."

    mock = Minitest::Mock.new
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: Array(soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([to_add, updated_soa], soa), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.add "www", "A", 18600, "example.net."
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.first.name.must_equal to_add.name
    change.additions.first.type.must_equal to_add.type
    change.additions.first.ttl.must_equal  to_add.ttl
    change.additions.first.data.must_equal to_add.data
    change.additions[1].data.must_equal updated_soa.data
    change.deletions.first.data.must_equal soa.data
  end

  it "updates without updating soa" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."

    mock = Minitest::Mock.new
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: Array(to_add.to_gapi),
      deletions: []
    )
    mock.expect :create_change, create_change_gapi(to_add, []), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.update to_add, skip_soa: true
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.first.name.must_equal to_add.name
    change.additions.first.type.must_equal to_add.type
    change.additions.first.ttl.must_equal  to_add.ttl
    change.additions.first.data.must_equal to_add.data
    change.deletions.must_be :empty?
  end

  it "updates with an integer for soa_serial" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."
    expected_soa = updated_soa
    expected_soa.data = ["ns-cloud-b1.googledomains.com. dns-admin.google.com. 10 21600 3600 1209600 300"]

    mock = Minitest::Mock.new
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << expected_soa.to_gapi),
      deletions: Array(soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([to_add, expected_soa], soa), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.update to_add, [], soa_serial: 10
    mock.verify

    change.additions[1].data.must_equal expected_soa.data
  end

  it "updates with a lambda for soa_serial" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."
    expected_soa = updated_soa
    expected_soa.data = ["ns-cloud-b1.googledomains.com. dns-admin.google.com. 10 21600 3600 1209600 300"]

    mock = Minitest::Mock.new
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << expected_soa.to_gapi),
      deletions: Array(soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([to_add, expected_soa], soa), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.update to_add, [], soa_serial: lambda { |sn| sn + 10 }
    mock.verify

    change.additions[1].data.must_equal expected_soa.data
  end

  it "removes records by name and type" do
    to_remove = zone.record "example.net.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    # The request for the records to remove.
    mock.expect :list_resource_record_sets, lookup_records_gapi(to_remove), [project, zone.id, {max_results: nil, name: "example.net.", page_token: nil, type: "A"}]
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: Array(updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([], to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.remove "example.net.", "A"
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.must_be :empty?
    change.deletions.first.name.must_equal to_remove.name
    change.deletions.first.type.must_equal to_remove.type
    change.deletions.first.ttl.must_equal  to_remove.ttl
    change.deletions.first.data.must_equal to_remove.data
  end

  it "removes records by subdomain name and type" do
    to_remove = zone.record "www.example.com.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    # The request for the records to remove.
    mock.expect :list_resource_record_sets, lookup_records_gapi(to_remove), [project, zone.id, {max_results: nil, name: "www.example.com.", page_token: nil, type: "A"}]
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: Array(updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi([], to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.remove "www", "A"
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    change.additions.must_be :empty?
    change.deletions.first.name.must_equal to_remove.name
    change.deletions.first.type.must_equal to_remove.type
    change.deletions.first.ttl.must_equal  to_remove.ttl
    change.deletions.first.data.must_equal to_remove.data
  end

  it "replaces records by name and type" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."
    to_remove = zone.record "example.net.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    # The request for the records to remove.
    mock.expect :list_resource_record_sets, lookup_records_gapi(to_remove), [project, zone.id, {max_results: nil, name: "example.net.", page_token: nil, type: "A"}]
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi(to_add, to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.replace "example.net.", "A", 18600, "example.com."
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
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

  it "replaces records by subdomain and type" do
    to_add = zone.record "www.example.com.", "A", 18600, "example.net."
    to_remove = zone.record "www.example.com.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    # The request for the records to remove.
    mock.expect :list_resource_record_sets, lookup_records_gapi(to_remove), [project, zone.id, {max_results: nil, name: "www.example.com.", page_token: nil, type: "A"}]
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi(to_add, to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.replace "www", "A", 18600, "example.net."
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
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

  it "modifies records by name and type" do
    to_add = zone.record "example.net.", "A", 18600, "example.com."
    to_remove = zone.record "example.net.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    # The request for the records to remove.
    mock.expect :list_resource_record_sets, lookup_records_gapi(to_remove), [project, zone.id, {max_results: nil, name: "example.net.", page_token: nil, type: "A"}]
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi(to_add, to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.modify "example.net.", "A" do |a|
      a.data = ["example.com."]
    end
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
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

  it "modifies records by subdomain and type" do
    to_add = zone.record "www.example.com.", "A", 18600, "example.net."
    to_remove = zone.record "www.example.com.", "A", 18600, "example.org."

    mock = Minitest::Mock.new
    # The request for the records to remove.
    mock.expect :list_resource_record_sets, lookup_records_gapi(to_remove), [project, zone.id, {max_results: nil, name: "www.example.com.", page_token: nil, type: "A"}]
    # The request for the SOA record, to update its serial number.
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (Array(to_add.to_gapi) << updated_soa.to_gapi),
      deletions: (Array(to_remove.to_gapi) << soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi(to_add, to_remove), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.modify "www", "A" do |a|
      a.data = ["example.net."]
    end
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
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

  it "allows for multiple changes in one update using the DSL" do
    a_to_add = zone.record "example.com.", "A", 18600, "127.0.0.1"
    txt_to_remove = zone.record "example.com.", "TXT", 1, "Hello world!"
    mx_to_add = zone.record "example.com.", "MX", 18600, ["mail1.example.com", "mail2.example.com"]
    mx_to_remove = zone.record "example.com.", "MX", 18600, ["mail1.example.net", "mail2.example.net"]
    cname_to_add = zone.record "www.example.com.", "CNAME", 18600, "example.com."
    cname_to_remove = zone.record "www.example.com.", "CNAME", 360, "example.com."

    mock = Minitest::Mock.new
    # mock the lookup for TXT
    mock.expect :list_resource_record_sets, lookup_records_gapi(txt_to_remove), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "TXT"}]
    # mock the lookup for MX
    mock.expect :list_resource_record_sets, lookup_records_gapi(mx_to_remove), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "MX"}]
    # mock the lookup for CNAME
    mock.expect :list_resource_record_sets, lookup_records_gapi(cname_to_remove), [project, zone.id, {max_results: nil, name: "www.example.com.", page_token: nil, type: "CNAME"}]

    # The request to remove the records.
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: [a_to_add.to_gapi, mx_to_add.to_gapi, cname_to_add.to_gapi],
      deletions: [txt_to_remove.to_gapi, mx_to_remove.to_gapi, cname_to_remove.to_gapi]
    )
    mock.expect :create_change, create_change_gapi([a_to_add, mx_to_add], [txt_to_remove, mx_to_remove]), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    zone.update skip_soa: true do |tx|
      tx.add "example.com.", "A", 18600, "127.0.0.1"
      tx.remove "example.com.", "TXT"
      tx.replace "example.com.", "MX", 18600, ["mail1.example.com", "mail2.example.com"]
      tx.modify "www.example.com.", "CNAME" do |cname|
        cname.ttl = 18600
      end
    end
    mock.verify
  end

  def find_change_gapi change_id
    change = random_change_gapi
    change.id = change_id
    change
  end

  def list_changes_gapi count = 2, token = nil
    changes = count.times.map do
      ch = random_change_gapi
      ch.id = "dns-change-#{rand 9999999}"
      ch
    end
    resp = Google::Apis::DnsV1::ListChangesResponse.new changes: changes
    resp.next_page_token = token unless token.nil?
    resp
  end

  def list_records_gapi count = 2, token = nil
    seed = rand 99999
    name = "example-#{seed}.com."
    records = count.times.map do
      random_record_gapi name, "A", seed, ["1.2.3.4"]
    end
    resp = Google::Apis::DnsV1::ListResourceRecordSetsResponse.new rrsets: records
    resp.next_page_token = token unless token.nil?
    resp
  end
end
