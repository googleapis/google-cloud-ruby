# Copyright 2014 Google Inc. All rights reserved.
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
require "json"
require "uri"

describe "Gcloud Dns Backoff", :mock_dns do

  it "lists zones with backoff" do
    num_zones = 3
    2.times do
      mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
        [500, {"Content-Type" => "application/json"}, nil]
      end
    end
    mock_connection.get "/dns/v1/projects/#{project}/managedZones" do |env|
      [200, {"Content-Type" => "application/json"},
       list_zones_json(num_zones)]
    end

    assert_backoff_sleep 1, 2 do
      zones = dns.zones
      zones.size.must_equal num_zones
      zones.each { |z| z.must_be_kind_of Gcloud::Dns::Zone }
    end
  end

  def list_zones_json count = 2, token = nil
    zones = count.times.map do
      seed = rand 99999
      random_zone_hash "example-#{seed}-zone", "example-#{seed}.com."
    end
    hash = { "kind" => "dns#managedZonesListResponse", "managedZones" => zones }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end

  def assert_backoff_sleep *args
    mock = Minitest::Mock.new
    args.each { |intv| mock.expect :sleep, nil, [intv] }
    callback = ->(retries) { mock.sleep retries }
    backoff = Gcloud::Backoff.new backoff: callback

    Gcloud::Backoff.stub :new, backoff do
      yield
    end

    mock.verify
  end
end
