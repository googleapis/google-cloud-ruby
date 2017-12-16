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

describe Google::Cloud::Dns::Importer, :mock_dns do
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone_gapi) { random_zone_gapi zone_name, zone_dns }
  let(:zone) { Google::Cloud::Dns::Zone.from_gapi zone_gapi, dns.service }
  # Zone file example from https://en.wikipedia.org/wiki/Zone_file
  let(:zonefile_path) { "acceptance/data/db.example.com" }

  # Zone file example from http://www.zytrax.com/books/dns/ch6/mydomain.html
  let(:zonefile) {
    <<-EOS
$TTL	86400 ; 24 hours could have been written as 24h or 1d
; $TTL used for all RRs without explicit TTL value
$ORIGIN example.com.
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
; server host definitions
ns1    IN  A      192.168.0.1  ;name server definition
www 1h IN  A      192.168.0.2  ;web server definition
ftp    IN  CNAME  www.example.com.  ;ftp server definition
; non server domain hosts
bill   IN  A      192.168.0.3
example.com. IN A 192.168.0.4
@      IN  A      192.168.0.5
       IN  A      192.168.0.6
EOS
  }

  let(:zonefile_io) { StringIO.new zonefile }

  it "imports records from zonefile file path" do
    importer = Google::Cloud::Dns::Importer.new zone, zonefile_path
    records = importer.records
    records.size.must_be :>=, 16
    records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    record_must_be records[0], "example.com.", "SOA", 3600, ["ns.example.com. username.example.com. 2007120710 1d 2h 4w 1h"]
    record_must_be records[1], "example.com.", "MX", 3600, ["10 mail.example.com.", "20 mail2.example.com.", "50 mail3"]
    record_must_be records[2], "example.com.", "A", 3600, ["192.0.2.1"]
    record_must_be records[3], "ns.example.com.", "A", 3600, ["192.0.2.2"]
    record_must_be records[4], "mail.example.com.", "A", 3600, ["192.0.2.3"]
    record_must_be records[5], "mail2.example.com.", "A", 3600, ["192.0.2.4"]
    record_must_be records[6], "mail3.example.com.", "A", 3600, ["192.0.2.5"]
    record_must_be records[7], "example.com.", "AAAA", 3600, ["2001:db8:10::1"]
    record_must_be records[8], "ns.example.com.", "AAAA", 3600, ["2001:db8:10::2"]
    record_must_be records[9], "example.com.", "NS", 3600, ["ns","ns.somewhere.example."]
    record_must_be records[10], "www.example.com.", "CNAME", 3600, ["example.com."]
    record_must_be records[11], "wwwtest.example.com.", "CNAME", 3600, ["www"]
    record_must_be records[12], "sip.example.com.", "TXT", 3600, ["\"text; containing ; spaces; and; semicolons ;\""]
    record_must_be records[13], "2.1.0.10.in-addr.arpa.", "PTR", 3600, ["server.example.com."]
    record_must_be records[14], "sip.example.com.", "SRV", 3600, ["0 5 5060 sip.example.com."]
    record_must_be records[15], "2.1.2.1", "NAPTR", 3600, ["10 100 \"u\" \"E2U+sip\" \"!^.*$!sip:info@example.com!\" .","10 101 \"u\" \"E2U+h323\" \"!^.*$!h323:info@example.com!\" .","10 102 \"u\" \"E2U+msg\" \"!^.*$!mailto:info@example.com!\" ."]
    record_must_be records[16], "example.com.", "SPF", 3600, [""] if records.size > 16 # zonefile 1.06
  end

  it "imports records from zonefile IO instance" do
    importer = Google::Cloud::Dns::Importer.new zone, zonefile_io
    records = importer.records
    records.size.must_equal 8
    records.each { |z| z.must_be_kind_of Google::Cloud::Dns::Record }
    record_must_be records[0], "example.com.", "SOA", 3600, ["ns1.example.com. hostmaster.example.com. 2002022401 3H 15 1w 3h"]
    record_must_be records[1], "example.com.", "MX", 86400, ["10 mail.another.com."]
    record_must_be records[2], "ns1.example.com.", "A", 86400, ["192.168.0.1"]
    record_must_be records[3], "www.example.com.", "A", 3600, ["192.168.0.2"]
    record_must_be records[4], "bill.example.com.", "A", 86400, ["192.168.0.3"]
    record_must_be records[5], "example.com.", "A", 86400, ["192.168.0.4", "192.168.0.5", "192.168.0.6"]
    record_must_be records[6], "example.com.", "NS", 86400, ["ns1.example.com.", "ns2.smokeyjoe.com."]
    record_must_be records[7], "ftp.example.com.", "CNAME", 86400, ["www.example.com."]
  end

  it "accepts an only option string" do
    importer = Google::Cloud::Dns::Importer.new zone, zonefile_io
    records = importer.records only: "A"
    records.size.must_equal 4
    record_must_be records[0], "ns1.example.com.", "A", 86400, ["192.168.0.1"]
    record_must_be records[1], "www.example.com.", "A", 3600, ["192.168.0.2"]
    record_must_be records[2], "bill.example.com.", "A", 86400, ["192.168.0.3"]
    record_must_be records[3], "example.com.", "A", 86400, ["192.168.0.4", "192.168.0.5", "192.168.0.6"]
  end

  it "accepts an only option array" do
    importer = Google::Cloud::Dns::Importer.new zone, zonefile_io
    records = importer.records only: ["A","NS"]
    records.size.must_equal 5
    record_must_be records[0], "ns1.example.com.", "A", 86400, ["192.168.0.1"]
    record_must_be records[1], "www.example.com.", "A", 3600, ["192.168.0.2"]
    record_must_be records[2], "bill.example.com.", "A", 86400, ["192.168.0.3"]
    record_must_be records[3], "example.com.", "A", 86400, ["192.168.0.4", "192.168.0.5", "192.168.0.6"]
    record_must_be records[4], "example.com.", "NS", 86400, ["ns1.example.com.", "ns2.smokeyjoe.com."]
  end

  it "accepts an except option string" do
    importer = Google::Cloud::Dns::Importer.new zone, zonefile_io
    records = importer.records except: "A"
    records.size.must_equal 4
    record_must_be records[0], "example.com.", "SOA", 3600, ["ns1.example.com. hostmaster.example.com. 2002022401 3H 15 1w 3h"]
    record_must_be records[1], "example.com.", "MX", 86400, ["10 mail.another.com."]
    record_must_be records[2], "example.com.", "NS", 86400, ["ns1.example.com.", "ns2.smokeyjoe.com."]
    record_must_be records[3], "ftp.example.com.", "CNAME", 86400, ["www.example.com."]
  end

  it "accepts an except option array" do
    importer = Google::Cloud::Dns::Importer.new zone, zonefile_io
    records = importer.records except: ["A","CNAME"]
    records.size.must_equal 3
    record_must_be records[0], "example.com.", "SOA", 3600, ["ns1.example.com. hostmaster.example.com. 2002022401 3H 15 1w 3h"]
    record_must_be records[1], "example.com.", "MX", 86400, ["10 mail.another.com."]
    record_must_be records[2], "example.com.", "NS", 86400, ["ns1.example.com.", "ns2.smokeyjoe.com."]
  end

  def record_must_be record, name, type, ttl, data
    record.name.must_equal name
    record.type.must_equal type
    record.ttl.must_equal ttl
    record.data.must_equal data
  end
end
