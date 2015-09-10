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
end
