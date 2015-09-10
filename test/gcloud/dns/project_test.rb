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

  def find_zone_json name, dns = nil
    random_zone_hash(name, dns).to_json
  end
end
