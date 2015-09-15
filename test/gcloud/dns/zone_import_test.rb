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
  let(:zone_file_path) { "acceptance/data/db.example.com" }
  let(:zone_name) { "example-zone" }
  let(:zone_dns) { "example.com." }
  let(:zone_hash) { random_zone_hash zone_name, zone_dns }
  let(:zone) { Gcloud::Dns::Zone.from_gapi zone_hash, dns.connection }

  it "imports records" do
    # replace records return value with change, after Zone#add_records implemented
    records = zone.import zone_file_path
    records.size.must_equal 16
    records.each { |z| z.must_be_kind_of Gcloud::Dns::Record }
    record_must_be records[0], "example.com.", "MX", 3600, ["10 mail.example.com."]
    record_must_be records[1], "@", "MX", 3600, ["20 mail2.example.com.","50 mail3"]
    record_must_be records[2], "example.com.", "A", 3600, ["192.0.2.1"]
    record_must_be records[3], "ns", "A", 3600, ["192.0.2.2"]
    record_must_be records[4], "mail", "A", 3600, ["192.0.2.3"]
    record_must_be records[5], "mail2", "A", 3600, ["192.0.2.4"]
    record_must_be records[6], "mail3", "A", 3600, ["192.0.2.5"]
    record_must_be records[7], "example.com.", "AAAA", 3600, ["2001:db8:10::1"]
    record_must_be records[8], "ns", "AAAA", 3600, ["2001:db8:10::2"]
    record_must_be records[9], "example.com.", "NS", 3600, ["ns","ns.somewhere.example."]
    record_must_be records[10], "www", "CNAME", 3600, ["example.com."]
    record_must_be records[11], "wwwtest", "CNAME", 3600, ["www"]
    record_must_be records[12], "sip.example.com.", "TXT", 3600, ["\"text; containing ; spaces; and; semicolons ;\""]
    record_must_be records[13], "2.1.0.10.in-addr.arpa.", "PTR", 3600, ["server.example.com."]
    record_must_be records[14], "sip.example.com.", "SRV", 3600, ["0 5 5060 sip.example.com."]
    record_must_be records[15], "2.1.2.1", "NAPTR", 3600, ["10 100 \"u\" \"E2U+sip\" \"!^.*$!sip:info@example.com!\" .","10 101 \"u\" \"E2U+h323\" \"!^.*$!h323:info@example.com!\" .","10 102 \"u\" \"E2U+msg\" \"!^.*$!mailto:info@example.com!\" ."]
  end

  def record_must_be record, name, type, ttl, data
    record.name.must_equal name
    record.type.must_equal type
    record.ttl.must_equal ttl
    record.data.must_equal data
  end
end
