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

describe Gcloud::Dns::Zone, :fqdn, :mock_dns do
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone) { Gcloud::Dns::Zone.from_gapi random_zone_hash(zone_name, zone_dns), dns.connection }

  it "knows a fully qualified domain name when given one" do
    zone.fqdn("example.org.").must_equal "example.org."
  end

  it "creates a fully qualified domain name when not given one" do
    zone.fqdn("example.net").must_equal "example.net."
  end

  it "uses the zone's fully qualified domain name when given nil" do
    zone.fqdn(nil).must_equal "example.com."
  end

  it "uses the zone's fully qualified domain name when given empty string" do
    zone.fqdn("").must_equal "example.com."
    zone.fqdn("  ").must_equal "example.com." # spaces
    zone.fqdn("\t").must_equal "example.com." # tab
    zone.fqdn("\n").must_equal "example.com." # new lines
  end

  it "uses the zone's fully qualified domain name when given @" do
    zone.fqdn("").must_equal "example.com."
  end

  it "prepends the zone's fully qualified domain name when given a subdomain" do
    zone.fqdn("www").must_equal "www.example.com."
  end
end
