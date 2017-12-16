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

describe Google::Cloud::Dns::Zone, :mock_dns do
  # Create a zone object with the project's mocked connection object
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone_gapi) { random_zone_gapi zone_name, zone_dns }
  let(:zone) { Google::Cloud::Dns::Zone.from_gapi zone_gapi, dns.service }
  let(:soa) { Google::Cloud::Dns::Record.new "example.com.", "SOA", 18600, "ns-cloud-b1.googledomains.com. dns-admin.google.com. 0 21600 3600 1209600 300" }
  let(:updated_soa) { Google::Cloud::Dns::Record.new "example.com.", "SOA", 18600, "ns-cloud-b1.googledomains.com. dns-admin.google.com. 1 21600 3600 1209600 300" }



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
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi, [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]

    dns.service.mocked_service = mock
    zonefile = zone.to_zonefile
    mock.verify

    zonefile.must_equal zone_export_expected.strip
  end

  it "exports records to a zonefile file" do
    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, list_records_gapi, [project, zone.id, {max_results: nil, name: nil, page_token: nil, type: nil}]

    dns.service.mocked_service = mock
    Tempfile.open "google-cloud" do |tmpfile|
      zone.export tmpfile
      mock.verify

      File.read(tmpfile).must_equal zone_export_expected.strip
    end
  end

  it "imports records from a zonefile" do
    to_add = [
      zone.record("example.com.", "MX", 86400, ["10 mail.another.com.", "20 mail.yetanother.com."]),
      zone.record("www", "A", 3600, ["192.168.0.2"])
    ]

    mock = Minitest::Mock.new
    mock.expect :list_resource_record_sets, lookup_records_gapi(soa), [project, zone.id, {max_results: nil, name: "example.com.", page_token: nil, type: "SOA"}]
    new_change = Google::Apis::DnsV1::Change.new(
      kind: "dns#change",
      additions: (to_add.map(&:to_gapi) << updated_soa.to_gapi),
      deletions: Array(soa.to_gapi)
    )
    mock.expect :create_change, create_change_gapi(to_add, []), [project, zone.id, new_change]

    dns.service.mocked_service = mock
    change = zone.import zonefile_io
    mock.verify

    change.must_be_kind_of Google::Cloud::Dns::Change
    change.id.must_equal "dns-change-created"
    record_must_be change.additions[0], to_add[0]
    record_must_be change.additions[1], to_add[1]
    change.deletions.must_be :empty?
  end

  def list_records_gapi
    records = []
    ns_data = (1..4).map { |i| "ns-cloud-b#{i}.googledomains.com." }
    records << random_record_gapi("example.net.", "NS", 21600, ns_data)
    records << random_record_gapi("example.net.", "SOA", 21600, ["ns-cloud-b1.googledomains.com. dns-admin.google.com. 0 21600 3600 1209600 300"])
    records << random_record_gapi("www.example.net.", "A", 18600, ["127.0.0.1"])

    Google::Apis::DnsV1::ListResourceRecordSetsResponse.new(
      rrsets: records
    )
  end

  def record_must_be actual, expected
    actual.name.must_equal expected.name
    actual.type.must_equal expected.type
    actual.ttl.must_equal expected.ttl
    actual.data.must_equal expected.data
  end
end
