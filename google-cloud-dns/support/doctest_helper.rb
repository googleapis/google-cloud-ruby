# Copyright 2016 Google LLC
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

require "google/cloud/dns"

class File
  def self.read *args
    "fake file data"
  end
  def self.open f, opts
    "fake file data"
  end
end

class Zonefile
  def soa
    {ttl: 86400}
  end
end

module Google
  module Cloud
    module Dns
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
  end
end

def mock_dns
  Google::Cloud::Dns.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    dns = Google::Cloud::Dns::Project.new(Google::Cloud::Dns::Service.new("my-project", credentials))

    dns.service.mocked_service = Minitest::Mock.new
    yield dns.service.mocked_service
    dns
  end
end

YARD::Doctest.configure do |doctest|
  doctest.before "Google::Cloud#dns" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
    end
  end
  doctest.before "Google::Cloud.dns" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
    end
  end

  doctest.before "Google::Cloud::Dns.new" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
    end
  end

  doctest.skip "Google::Cloud::Dns::Credentials" # some other mock is messing up this test

  doctest.before "Google::Cloud::Dns::Change" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_changes, list_changes_gapi, list_changes_args
    end
  end

  doctest.before "Google::Cloud::Dns::Change#wait_until_done!" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :get_change, find_change_gapi(true), ["my-project", 123456789, 1234567890]
      mock.expect :get_change, find_change_gapi, ["my-project", 123456789, 1234567890]
    end
  end

  doctest.before "Google::Cloud::Dns::Project" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
    end
  end

  doctest.before "Google::Cloud::Dns::Project#zones" do
    mock_dns do |mock|
      mock.expect :list_managed_zones, list_zones_gapi, ["my-project", {:max_results=>nil, :page_token=>nil}]
    end
  end

  doctest.before "Google::Cloud::Dns::Project#find_zones" do
    mock_dns do |mock|
      mock.expect :list_managed_zones, list_zones_gapi, ["my-project", {:max_results=>nil, :page_token=>nil}]
    end
  end

  doctest.before "Google::Cloud::Dns::Project#create_zone" do
    mock_dns do |mock|
      mock.expect :create_managed_zone, zone_gapi, ["my-project", Google::Apis::DnsV1::ManagedZone]
    end
  end

  doctest.before "Google::Cloud::Dns::Project#project" do
    mock_dns do |mock|
    end
  end

  doctest.before "Google::Cloud::Dns::Project#id" do
    mock_dns do |mock|
    end
  end

  doctest.before "Google::Cloud::Dns::Record" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "SOA")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
      mock.expect :list_resource_record_sets, lookup_records_gapi(3), list_resource_record_sets_args
    end
  end

  doctest.before "Google::Cloud::Dns::Zone" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#delete" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
      mock.expect :delete_managed_zone, nil, ["my-project", 123456789]
    end
  end

  # Skip duplicates for alias
  doctest.skip "Google::Cloud::Dns::Zone#find_change"
  doctest.skip "Google::Cloud::Dns::Zone#get_change"

  doctest.before "Google::Cloud::Dns::Zone#change" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :get_change, find_change_gapi, ["my-project", 123456789, "2"]
    end
  end

  # Skip duplicates for alias
  doctest.skip "Google::Cloud::Dns::Zone#find_changes"

  doctest.before "Google::Cloud::Dns::Zone#changes" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_changes, list_changes_gapi, list_changes_args
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#changes@The changes can be sorted by change sequence:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_changes, list_changes_gapi, ["my-project", 123456789, {:max_results=>nil, :page_token=>nil, :sort_by=>"changeSequence", :sort_order=>"descending"}]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#changes@The changes can be sorted by change sequence:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_changes, list_changes_gapi, ["my-project", 123456789, {:max_results=>nil, :page_token=>nil, :sort_by=>"changeSequence", :sort_order=>"descending"}]
    end
  end

  # Skip duplicates for alias
  doctest.skip "Google::Cloud::Dns::Zone#new_record"

  doctest.before "Google::Cloud::Dns::Zone#record" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "SOA")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  # Skip duplicates for alias
  doctest.skip "Google::Cloud::Dns::Zone#find_records"

  doctest.before "Google::Cloud::Dns::Zone#records" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#records@Records can be filtered by name and type:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "www.example.com.", type: "A")
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#records@Retrieve all records:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.")
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#import" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#update@Using a block:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "TXT")
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "MX")
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "www.example.com.", type: "CNAME")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#update@Or you can provide the record objects to add and remove:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "SOA")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#update@Using a lambda or Proc to update current SOA serial number:" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "SOA")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#add" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "SOA")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#remove" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "A")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#replace" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "A")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#modify" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "MX")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#find_records" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "www.example.com.", type: "A")
    end
  end

  doctest.before "Google::Cloud::Dns::Zone#fqdn" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
    end
  end

  # Doctest also matches `#next?`
  doctest.before "Google::Cloud::Dns::Change::List#next" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_changes, list_changes_gapi, list_changes_args
    end
  end

  doctest.before "Google::Cloud::Dns::Change::List#all" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_changes, list_changes_gapi, list_changes_args
    end
  end

  # Doctest also matches `#next?`
  doctest.before "Google::Cloud::Dns::Record::List#next" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.")
    end
  end

  doctest.before "Google::Cloud::Dns::Record::List#all" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.")
    end
  end

  # Doctest also matches `#next?`
  doctest.before "Google::Cloud::Dns::Zone::List#next" do
    mock_dns do |mock|
      mock.expect :list_managed_zones, list_zones_gapi, ["my-project", {:max_results=>nil, :page_token=>nil}]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone::List#all" do
    mock_dns do |mock|
      mock.expect :list_managed_zones, list_zones_gapi, ["my-project", {:max_results=>nil, :page_token=>nil}]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone::Transaction" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "TXT")
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "MX")
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "www.example.com.", type: "CNAME")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone::Transaction#add" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "SOA")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone::Transaction#replace" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "example.com.", type: "MX")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end

  doctest.before "Google::Cloud::Dns::Zone::Transaction#modify" do
    mock_dns do |mock|
      mock.expect :get_managed_zone, zone_gapi, ["my-project", "example-com"]
      mock.expect :list_resource_record_sets, lookup_records_gapi, list_resource_record_sets_args(name: "www.example.com.", type: "CNAME")
      mock.expect :create_change, lookup_records_gapi, ["my-project", 123456789, Google::Apis::DnsV1::Change]
    end
  end
end

# Fixture helpers

def list_changes_args
  ["my-project", 123456789, {:max_results=>nil, :page_token=>nil, :sort_by=>nil, :sort_order=>nil}]
end

def list_resource_record_sets_args name: nil, type: nil
  ["my-project", 123456789, {:max_results=>nil, :name=>name, :page_token=>nil, :type=>type}]
end

def zone_gapi
  Google::Apis::DnsV1::ManagedZone.new(
    kind: "dns#managedZone",
    name: "example-com",
    dns_name: "example.com",
    description: "",
    id: 123456789,
    name_servers: [ "virtual-dns-1.google.example",
                   "virtual-dns-2.google.example" ],
    creation_time: "2015-01-01T00:00:00-00:00"
  )
end

def create_zone_gapi
  Google::Apis::DnsV1::ManagedZone.new(
    kind: "dns#managedZone",
    name: "example-com",
    dns_name: "example.com",
    description: ""
  )
end

def list_zones_gapi count = 2, token = nil
  zones = count.times.map do
    zone_gapi
  end
  Google::Apis::DnsV1::ListManagedZonesResponse.new(
    kind: "dns#managedZonesListResponse",
    managed_zones: zones,
    next_page_token: token
  )
end

def change_gapi
  Google::Apis::DnsV1::Change.new(
    kind: "dns#change",
    id: "dns-change-1234567890",
    additions: [],
    deletions: [],
    start_time: "2015-01-01T00:00:00-00:00",
    status: "done"
  )
end

def find_change_gapi pending = false
  change = change_gapi
  change.id = 1234567890
  if pending
    change.status = "pending"
  end
  change
end

def list_changes_gapi count = 2, token = nil
  changes = count.times.map do
    ch = change_gapi
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
    record_gapi name, "A", seed, ["1.2.3.4"]
  end
  resp = Google::Apis::DnsV1::ListResourceRecordSetsResponse.new rrsets: records
  resp.next_page_token = token unless token.nil?
  resp
end

def soa
  Google::Cloud::Dns::Record.new(
    "www.example.com.",
    "SOA",
    18600,
    "ns-cloud-b1.googledomains.com. dns-admin.google.com. 0 21600 3600 1209600 300"
  )
end

def lookup_records_gapi count = 2
  rrsets = count.times.map { soa.to_gapi }
  Google::Apis::DnsV1::ListResourceRecordSetsResponse.new rrsets: rrsets
end
