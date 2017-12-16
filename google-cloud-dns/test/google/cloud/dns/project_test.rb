# Copyright 2015 Google LLC
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

describe Google::Cloud::Dns::Project, :mock_dns do
  it "knows the project identifier" do
    dns.project.must_equal project
  end

  it "knows its quota information" do
    mock = Minitest::Mock.new
    mock.expect :get_project, random_project_gapi, [project]

    dns.service.mocked_service = mock
    dns.reload!
    mock.verify

    dns.id.must_equal project
    dns.number.must_equal 123456789
    dns.zones_quota.must_equal 101
    dns.records_per_zone.must_equal 1002
    dns.additions_per_change.must_equal 103
    dns.deletions_per_change.must_equal 104
    dns.total_data_per_change.must_equal 8000
    dns.data_per_record.must_equal 105
  end

  it "finds a zone" do
    found_zone = "example.net."
    mock = Minitest::Mock.new
    mock.expect :get_managed_zone, random_zone_gapi(found_zone, nil), [project, found_zone]

    dns.service.mocked_service = mock
    zone = dns.zone found_zone
    mock.verify

    zone.must_be_kind_of Google::Cloud::Dns::Zone
    zone.name.must_equal found_zone
  end

  it "returns nil when it cannot find a zone" do
    stub = Object.new
    def stub.get_managed_zone *args
      raise Google::Apis::ClientError.new nil, status_code: 404
    end

    dns.service.mocked_service = stub
    zone = dns.zone "example.org."
    zone.must_be :nil?
  end

  it "lists zones" do
    num_zones = 3
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(num_zones), [project, {max_results: nil, page_token: nil}]

    dns.service.mocked_service = mock
    zones = dns.zones
    mock.verify

    zones.size.must_equal num_zones
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
  end

  it "paginates zones" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: nil, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(2), [project, {max_results: nil, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    first_zones = dns.zones
    first_zones.count.must_equal 3
    first_zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    first_zones.token.wont_be :nil?
    first_zones.token.must_equal "next_page_token"

    second_zones = dns.zones token: first_zones.token
    mock.verify

    second_zones.count.must_equal 2
    second_zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    second_zones.token.must_be :nil?
  end

  it "paginates zones with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: 3, page_token: nil}]

    dns.service.mocked_service = mock
    zones = dns.zones max: 3
    mock.verify

    zones.count.must_equal 3
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    zones.token.wont_be :nil?
    zones.token.must_equal "next_page_token"
  end

  it "paginates zones without max set" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: nil, page_token: nil}]

    dns.service.mocked_service = mock
    zones = dns.zones
    mock.verify

    zones.count.must_equal 3
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    zones.token.wont_be :nil?
    zones.token.must_equal "next_page_token"
  end

  it "paginates zones with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: nil, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(2), [project, {max_results: nil, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    first_zones = dns.zones
    first_zones.count.must_equal 3
    first_zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    first_zones.next?.must_equal true

    second_zones = first_zones.next
    mock.verify

    second_zones.count.must_equal 2
    second_zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    second_zones.next?.must_equal false
  end

  it "paginates zones with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: 3, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(2), [project, {max_results: 3, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    first_zones = dns.zones max: 3
    first_zones.count.must_equal 3
    first_zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    first_zones.next?.must_equal true

    second_zones = first_zones.next
    mock.verify

    second_zones.count.must_equal 2
    second_zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
    second_zones.next?.must_equal false
  end

  it "paginates zones with all" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: nil, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(2), [project, {max_results: nil, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    zones = dns.zones.all.to_a
    mock.verify

    zones.count.must_equal 5
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
  end

  it "paginates zones with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: 3, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(2), [project, {max_results: 3, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    zones = dns.zones(max: 3).all.to_a
    mock.verify

    zones.count.must_equal 5
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
  end

  it "iterates all zones with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: nil, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(3, "second_page_token"), [project, {max_results: nil, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    zones = dns.zones.all.take(5)
    mock.verify

    zones.count.must_equal 5
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
  end

  it "iterates all zones with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_managed_zones, list_zones_gapi(3, "next_page_token"), [project, {max_results: nil, page_token: nil}]
    mock.expect :list_managed_zones, list_zones_gapi(3, "second_page_token"), [project, {max_results: nil, page_token: "next_page_token"}]

    dns.service.mocked_service = mock
    zones = dns.zones.all(request_limit: 1).to_a
    mock.verify

    zones.count.must_equal 6
    zones.each { |z| z.must_be_kind_of Google::Cloud::Dns::Zone }
  end

  it "creates a zone" do
    mock = Minitest::Mock.new
    managed_zone_gapi = create_zone_gapi "example-zone", "example.net."
    mock.expect :create_managed_zone, managed_zone_gapi, [project, managed_zone_gapi]

    dns.service.mocked_service = mock
    zone = dns.create_zone "example-zone", "example.net."
    mock.verify

    zone.must_be_kind_of Google::Cloud::Dns::Zone
    zone.name.must_equal "example-zone"
    zone.dns.must_equal "example.net."
    zone.description.must_equal ""
    zone.name_server_set.must_be :nil?
  end

  it "creates a zone with a description" do
    mock = Minitest::Mock.new
    managed_zone_gapi = create_zone_gapi "example-zone", "example.net.", description: "Example Zone Description"
    mock.expect :create_managed_zone, managed_zone_gapi, [project, managed_zone_gapi]

    dns.service.mocked_service = mock
    zone = dns.create_zone "example-zone", "example.net.",
                            description: "Example Zone Description"
    mock.verify

    zone.must_be_kind_of Google::Cloud::Dns::Zone
    zone.name.must_equal "example-zone"
    zone.dns.must_equal "example.net."
    zone.description.must_equal "Example Zone Description"
    zone.name_server_set.must_be :nil?
  end

  it "creates a zone with a name_server_set" do
    mock = Minitest::Mock.new
    managed_zone_gapi = create_zone_gapi "example-zone", "example.net.", name_server_set: "example-set"
    mock.expect :create_managed_zone, managed_zone_gapi, [project, managed_zone_gapi]

    dns.service.mocked_service = mock
    zone = dns.create_zone "example-zone", "example.net.",
                            name_server_set: "example-set"
    mock.verify

    zone.must_be_kind_of Google::Cloud::Dns::Zone
    zone.name.must_equal "example-zone"
    zone.dns.must_equal "example.net."
    zone.description.must_equal ""
    zone.name_server_set.must_equal "example-set"
  end

  it "reload! calls to the API" do
    mock = Minitest::Mock.new
    mock.expect :get_project, random_project_gapi, [project]

    dns.service.mocked_service = mock
    dns.reload!
    mock.verify
  end

  def list_zones_gapi count = 2, token = nil
    zones = count.times.map do
      seed = rand 99999
      random_zone_gapi "example-#{seed}-zone", "example-#{seed}.com."
    end
    Google::Apis::DnsV1::ListManagedZonesResponse.new(
      kind: "dns#managedZonesListResponse",
      managed_zones: zones,
      next_page_token: token
    )
  end

  def create_zone_gapi name, dns, options = {}
    Google::Apis::DnsV1::ManagedZone.new(
      kind: "dns#managedZone",
      name: name,
      dns_name: dns,
      description: (options[:description] || ""),
      name_server_set: options[:name_server_set]
    )
  end
end
