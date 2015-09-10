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

describe Gcloud::Dns::Project, :mock_dns do
  it "knows the project identifier" do
    dns.project.must_equal project
  end

  it "finds a zone" do
    found_zone = "example.net"

    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{found_zone}" do |env|
      [200, {"Content-Type" => "application/json"},
       find_zone_json(found_zone)]
    end

    zone = dns.zone found_zone
    zone.must_be_kind_of Gcloud::Dns::Zone
    zone.name.must_equal found_zone
  end

  it "returns nil when it cannot find a zone" do
    unfound_zone = "example.org"

    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{unfound_zone}" do |env|
      [404, {"Content-Type" => "application/json"},
       ""]
    end

    zone = dns.zone unfound_zone
    zone.must_be :nil?
  end

  it "lists zones" do
    num_zones = 3
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      [200, {"Content-Type" => "application/json"},
       list_zones_json(num_zones)]
    end

    zones = dns.zones
    zones.size.must_equal num_zones
    zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
  end

  it "paginates zones" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_zones_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_zones_json(2)]
    end

    first_zones = dns.zones
    first_zones.count.must_equal 3
    first_zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    first_zones.token.wont_be :nil?
    first_zones.token.must_equal "next_page_token"

    second_zones = dns.zones token: first_zones.token
    second_zones.count.must_equal 2
    second_zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    second_zones.token.must_be :nil?
  end

  it "paginates zones with next? and next" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_zones_json(3, "next_page_token")]
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_zones_json(2)]
    end

    first_zones = dns.zones
    first_zones.count.must_equal 3
    first_zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    first_zones.next?.must_equal true

    second_zones = first_zones.next
    second_zones.count.must_equal 2
    second_zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    second_zones.next?.must_equal false
  end

  it "paginates zones with max set" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type" => "application/json"},
       list_zones_json(3, "next_page_token")]
    end

    zones = dns.zones max: 3
    zones.count.must_equal 3
    zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    zones.token.wont_be :nil?
    zones.token.must_equal "next_page_token"
  end

  it "paginates zones without max set" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type" => "application/json"},
       list_zones_json(3, "next_page_token")]
    end

    zones = dns.zones
    zones.count.must_equal 3
    zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    zones.token.wont_be :nil?
    zones.token.must_equal "next_page_token"
  end

  it "creates a zone" do
    mock_connection.post "/dns/v1/projects/#{project}/managedZones" do |env|
      json = JSON.parse(env.body)
      json["kind"].must_equal "dns#managedZone"
      json["name"].must_equal "example-zone"
      json["dnsName"].must_equal "example.net"
      json["description"].must_be :nil?
      json["nameServerSet"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       create_zone_json("example-zone", "example.net")]
    end

    zone = dns.create_zone "example-zone", "example.net"
    zone.must_be_kind_of Gcloud::Dns::Zone
    zone.name.must_equal "example-zone"
    zone.dns.must_equal "example.net"
    zone.description.must_be :nil?
    zone.name_server_set.must_be :nil?
  end

  it "creates a zone with a description" do
    mock_connection.post "/dns/v1/projects/#{project}/managedZones" do |env|
      json = JSON.parse(env.body)
      json["kind"].must_equal "dns#managedZone"
      json["name"].must_equal "example-zone"
      json["dnsName"].must_equal "example.net"
      json["description"].must_equal "Example Zone Description"
      json["nameServerSet"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       create_zone_json("example-zone", "example.net", description: json["description"])]
    end

    zone = dns.create_zone "example-zone", "example.net",
                            description: "Example Zone Description"
    zone.must_be_kind_of Gcloud::Dns::Zone
    zone.name.must_equal "example-zone"
    zone.dns.must_equal "example.net"
    zone.description.must_equal "Example Zone Description"
    zone.name_server_set.must_be :nil?
  end

  it "creates a zone with a name_server_set" do
    mock_connection.post "/dns/v1/projects/#{project}/managedZones" do |env|
      json = JSON.parse(env.body)
      json["kind"].must_equal "dns#managedZone"
      json["name"].must_equal "example-zone"
      json["dnsName"].must_equal "example.net"
      json["description"].must_be :nil?
      json["nameServerSet"].must_equal "example-set"
      [200, {"Content-Type"=>"application/json"},
       create_zone_json("example-zone", "example.net", name_server_set: json["nameServerSet"])]
    end

    zone = dns.create_zone "example-zone", "example.net",
                            name_server_set: "example-set"
    zone.must_be_kind_of Gcloud::Dns::Zone
    zone.name.must_equal "example-zone"
    zone.dns.must_equal "example.net"
    zone.description.must_be :nil?
    zone.name_server_set.must_equal "example-set"
  end

  def find_zone_json name, dns = nil
    random_zone_hash(name, dns).to_json
  end

  def list_zones_json count = 2, token = nil
    zones = count.times.map { random_zone_hash("example-#{rand(99999)}.com") }
    hash = { "kind" => "dns#managedZonesListResponse", "managedZones" => zones }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end

  def create_zone_json name, dns, options = {}
    hash = random_zone_hash name, dns
    hash["description"]   = options[:description]
    hash["nameServerSet"] = options[:name_server_set]
    hash.to_json
  end
end
