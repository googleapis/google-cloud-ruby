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


  # Actual output of gcloud command line tool:
  # $ gcloud dns record-sets export example-zone.txt --zone-file-format --zone example-zone
  let(:zone_export_expected) {
    <<-EOS
example.net. 21600 IN NS ns-cloud-b1.googledomains.com.
example.net. 21600 IN NS ns-cloud-b2.googledomains.com.
example.net. 21600 IN NS ns-cloud-b3.googledomains.com.
example.net. 21600 IN NS ns-cloud-b4.googledomains.com.
example.net. 21600 IN SOA ns-cloud-b1.googledomains.com. dns-admin.google.com. 0 21600 3600 1209600 300
www.example.net. 18600 IN A 127.0.0.1
EOS
  }

  # Zone file example from http://www.zytrax.com/books/dns/ch6/mydomain.html
  let(:zonefile_io) {
    zonefile = <<-EOS
$ORIGIN example.com.
$TTL	86400 ; 24 hours could have been written as 24h or 1d
@  1h  IN  SOA ns1.example.com. hostmaster.example.com. (
            2002022401 ; serial
            3H ; refresh
            15 ; retry
            1w ; expire
            3h ; minimum
           )
       IN  NS     ns1.example.com. ; in the domain
       IN  NS     ns2.smokeyjoe.com. ; external to domain
       IN  MX  10 mail.another.com. ; external mail provider
       IN  MX  20 mail.yetanother.com. ; external mail provider
www 1h IN  A      192.168.0.2  ;web server definition
EOS
    StringIO.new zonefile
  }

  it "exports records to a zonefile string" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      [200, {"Content-Type" => "application/json"},
       list_records_json]
    end

    zonefile = zone.to_zonefile
    zonefile.must_equal zone_export_expected.strip
  end

  it "exports records to a zonefile file" do
    mock_connection.get "/dns/v1/projects/#{project}/managedZones/#{zone.id}/rrsets" do |env|
      [200, {"Content-Type" => "application/json"},
       list_records_json]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      zone.export tmpfile
      File.read(tmpfile).must_equal zone_export_expected.strip
    end
  end

  it "imports records from a zonefile" do
    to_add = [
      zone.record("example.com.", "MX", 86400, ["10 mail.another.com.", "20 mail.yetanother.com."]),
      zone.record("www", "A", 3600, ["192.168.0.2"])
    ]

    mock_connection.post "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      json = JSON.parse env.body
      json["additions"].count.must_equal 2
      json["deletions"].count.must_equal 0
      json["additions"][0].must_equal to_add[0].to_gapi
      json["additions"][1].must_equal to_add[1].to_gapi
      json["deletions"].must_be :empty?
      [200, {"Content-Type" => "application/json"},
       create_change_json(to_add, [])]
    end

    change = zone.import zonefile_io
    change.must_be_kind_of Gcloud::Dns::Change
    change.id.must_equal "dns-change-created"
    record_must_be change.additions[0], to_add[0]
    record_must_be change.additions[1], to_add[1]
    change.deletions.must_be :empty?
  end

  it "imports records including SOA and NS with nameservers option" do
    to_add = [
      zone.record("@", "SOA", 3600, ["ns1.example.com. hostmaster.example.com. 2002022401 3H 15 1w 3h"]),
      zone.record("example.com.", "MX", 86400, ["10 mail.another.com.", "20 mail.yetanother.com."]),
      zone.record("www", "A", 3600, ["192.168.0.2"]),
      zone.record("example.com.", "NS", 86400, ["ns1.example.com.", "ns2.smokeyjoe.com."])
    ]

    mock_connection.post "/dns/v1/projects/#{project}/managedZones/#{zone.id}/changes" do |env|
      json = JSON.parse env.body
      json["additions"].count.must_equal 4
      json["deletions"].count.must_equal 0
      json["additions"][0].must_equal to_add[0].to_gapi
      json["additions"][1].must_equal to_add[1].to_gapi
      json["additions"][2].must_equal to_add[2].to_gapi
      json["additions"][3].must_equal to_add[3].to_gapi
      json["deletions"].must_be :empty?
      [200, {"Content-Type" => "application/json"},
       create_change_json(to_add, [])]
    end

    change = zone.import zonefile_io, nameservers: true
    change.must_be_kind_of Gcloud::Dns::Change
    change.id.must_equal "dns-change-created"
    record_must_be change.additions[0], to_add[0]
    record_must_be change.additions[1], to_add[1]
    record_must_be change.additions[2], to_add[2]
    record_must_be change.additions[3], to_add[3]
    change.deletions.must_be :empty?
  end

  def list_records_json
    records = []
    ns_data = (1..4).map { |i| "ns-cloud-b#{i}.googledomains.com." }
    records << random_record_hash("example.net.", "NS", 21600, ns_data)
    records << random_record_hash("example.net.", "SOA", 21600, ["ns-cloud-b1.googledomains.com. dns-admin.google.com. 0 21600 3600 1209600 300"])
    records << random_record_hash("www.example.net.", "A", 18600, ["127.0.0.1"])

    hash = { "kind" => "dns#resourceRecordSet", "rrsets" => records }
    hash.to_json
  end

  def create_change_json to_add, to_remove
    hash = random_change_hash
    hash["id"] = "dns-change-created"
    hash["additions"] = Array(to_add).map &:to_gapi
    hash["deletions"] = Array(to_remove).map &:to_gapi
    hash.to_json
  end

  def record_must_be actual, expected
    actual.name.must_equal expected.name
    actual.type.must_equal expected.type
    actual.ttl.must_equal expected.ttl
    actual.data.must_equal expected.data
  end
end
