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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/dns"

##
# Monkey-Patch Google API Client to support Mocks
module Google::Apis::Core::Hashable
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, the Google API Client objects do not match with ===.
  # Therefore, we must add this capability.
  # This module seems like as good a place as any...
  def === other
    return(to_h === other.to_h) if other.respond_to? :to_h
    super
  end
end

class MockDns < Minitest::Spec
  let(:project) { dns.service.project }
  let(:credentials) { dns.service.credentials }
  let(:dns) { Google::Cloud::Dns::Project.new(Google::Cloud::Dns::Service.new("test", OpenStruct.new)) }

  def random_project_gapi
    Google::Apis::DnsV1::Project.new(
      kind: "dns#project",
      number: 123456789,
      id: project,
      quota: Google::Apis::DnsV1::Quota.new(
        kind: "dns#quota",
        managed_zones: 101,
        rrsets_per_managed_zone: 1002,
        rrset_additions_per_change: 103,
        rrset_deletions_per_change: 104,
        total_rrdata_size_per_change: 8000,
        resource_records_per_rrset: 105
      )
    )
  end

  def random_zone_gapi zone_name, zone_dns
    Google::Apis::DnsV1::ManagedZone.new(
      kind: "dns#managedZone",
      name: zone_name,
      dns_name: zone_dns,
      description: "",
      id: 123456789,
      name_servers: [ "virtual-dns-1.google.example",
                     "virtual-dns-2.google.example" ],
      creation_time: "2015-01-01T00:00:00-00:00"
    )
  end

  def random_change_gapi
    Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      id: "dns-change-1234567890",
      additions: [],
      deletions: [],
      start_time: "2015-01-01T00:00:00-00:00",
      status: "done"
    )
  end

  def random_record_gapi name, type, ttl, data
    Google::Apis::DnsV1::ResourceRecordSet.new(
      kind: "dns#resourceRecordSet",
      name: name,
      rrdatas: data,
      ttl: ttl,
      type: type
    )
  end

  def done_change_gapi change_id = nil
    change = random_change_gapi
    change.id = change_id if change_id
    change.additions = [ random_record_gapi("example.net.", "A", 18600, ["example.com."]) ]
    change.deletions = [ random_record_gapi("example.net.", "A", 18600, ["example.org."]) ]
    change
  end

  def pending_change_gapi change_id = nil
    change = done_change_gapi change_id
    change.status = "pending"
    change
  end

  def create_change_gapi to_add, to_remove
    change = random_change_gapi
    change.id = "dns-change-created"
    change.additions = Array(to_add).map(&:to_gapi)
    change.deletions = Array(to_remove).map(&:to_gapi)
    change
  end

  def lookup_records_gapi record
    Google::Apis::DnsV1::ListResourceRecordSetsResponse.new rrsets: [record.to_gapi]
  end

  # Register this spec type for when :dns is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_dns
  end
end
