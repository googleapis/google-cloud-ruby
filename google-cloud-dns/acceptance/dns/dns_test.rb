# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "dns_helper"
require "tempfile"

# This test is a ruby version of gcloud-node's dns test.
describe Google::Cloud::Dns, :dns do
  let(:dns) { $dns }
  let(:zone_dns) { $dns_domain + "." }
  let(:zone_name) { $dns_prefix }
  let(:zone) { $dns_zone ||= (dns.zone(zone_name) || dns.create_zone(zone_name, zone_dns)) }

  let(:records) {
    [ a_record, aaaa_record, cname_record, mx_record, naptr_record,
      ns_record, prt_record, soa_record, spf_record, srv_record, txt_record]
  }
  let(:a_record)  { zone.record zone.dns, "A", 86400, "1.2.3.4" }
  let(:aaaa_record) { zone.record zone.dns, "AAAA", 86400, "2607:f8b0:400a:801::1005" }
  let(:cname_record) { zone.record "redirect.#{zone.dns}", "CNAME", 86400, "example.com." }
  let(:mx_record) { zone.record zone.dns, "MX", 86400, [ "10 mail.#{zone.dns}",
                                                         "20 mail2.#{zone.dns}"] }
  let(:naptr_record) { zone.record "2.1.2.1.5.5.5.0.7.7.1.e164.arpa.", "NAPTR", 300,
    [ "100 10 \"u\" \"sip+E2U\" \"!^.*$!sip:information@foo.se!i\" .",
       "102 10 \"u\" \"smtp+E2U\" \"!^.*$!mailto:information@foo.se!i\" ." ] }
  let(:ns_record) { zone.record zone.dns, "NS", 86400, "ns-cloud1.googledomains.com." }
  let(:ptr_record) { zone.record "2.1.0.10.in-addr.arpa.", "PTR", 60, "server.#{zone.dns}" }
  let(:soa_record) { zone.record zone.dns, "SOA", 21600,
    [ "ns-cloud1.googledomains.com. dns-admin.google.com. 1 21600 3600 1209600 300" ] }
  let(:spf_record) { zone.record zone.dns, "SPF", 21600, "\"v=spf1\" \"mx:#{zone.dns.gsub(/.$/, "")}\" \"-all\"" }
  let(:srv_record) { zone.record "sip.#{zone.dns}", "SRV", 21600, "0 5 5060 sip.#{zone.dns}" }
  let(:txt_record) { zone.record zone.dns, "TXT", 21600,
    "\"google-site-verification=xxxxxxxxxxxxYYYYYYXXX\"" }

  before do
    zone.clear!
  end

  it "lists all zones" do
    all_zones = dns.zones.all(request_limit: 3).to_a
    all_zones.count.wont_equal 0
  end

  it "creates and deletes a zone" do
    create_zone_name = "#{zone_name}-crtst1"
    create_zone_dns  = "crtst1.#{zone_dns}"
    dns.zone(create_zone_name).must_be :nil?
    create_zone = dns.create_zone create_zone_name, create_zone_dns
    create_zone.wont_be :nil?
    create_zone.must_be_kind_of Google::Cloud::Dns::Zone
    dns.zone(create_zone_name).wont_be :nil?
    create_zone.delete force: true
    dns.zone(create_zone_name).must_be :nil?
  end

  it "knows its attributes" do
    zone.name.must_equal zone_name
    zone.dns.must_equal zone.dns
    zone.description.must_equal ""
    zone.id.wont_be :nil?
    zone.name_servers.each do |name_server|
      name_server.must_include ".googledomains.com."
    end
    zone.name_server_set.must_be :nil?
    zone.created_at.must_be_kind_of Time
  end

  it "return 0 or more zones" do
    zone.records.all.count.must_be :>=, 0
  end

  describe "Zones" do
    it "gets the metadata for a zone" do
      zone.name.must_equal zone_name
      zone.dns.must_equal  zone_dns
      zone.created_at.wont_be :nil?
    end

    it "supports all types of records" do
      zone.add(zone.dns, "A", 86400, "1.2.3.4").wait_until_done!
      zone.replace(zone.dns, "AAAA", 86400, "2607:f8b0:400a:801::1005").wait_until_done!
      zone.update do |tx|
        tx.add "redirect.#{zone.dns}", "CNAME", 86400, "example.com."
        tx.add zone.dns, "MX", 86400, [ "10 mail.#{zone.dns}",
                                        "20 mail2.#{zone.dns}"]
        tx.replace zone.dns, "NS", 86400, "ns-cloud1.googledomains.com."
        tx.replace zone.dns, "SOA", 21600,
          "ns-cloud1.googledomains.com. dns-admin.google.com. 1 21600 3600 1209600 300"
        tx.add zone.dns, "SPF", 21600, "v=spf1 mx:#{zone.dns.gsub(/.$/, "")} -all"
        tx.add "sip.#{zone.dns}", "SRV", 21600, "0 5 5060 sip.#{zone.dns}"
        tx.add zone.dns, "TXT", 21600, "google-site-verification=xxxxxxxxxxxxYYYYYYXXX"
      end.wait_until_done!

      records = zone.records.all
      records.must_include a_record
      records.must_include aaaa_record
      records.must_include cname_record
      records.must_include mx_record
      records.must_include ns_record
      records.must_include soa_record
      records.must_include spf_record
      records.must_include srv_record
      records.must_include txt_record
    end

    it "imports records from a zone file" do
      import_zone_name = "#{zone_name}-import"
      import_zone_dns  = "import.#{zone_dns}"
      import_zone = dns.create_zone import_zone_name, import_zone_dns
      import_zone.clear!

      Tempfile.open "zonefile" do |tmpfile|
        tmpfile.write create_zonefile_contents(import_zone_dns)
        tmpfile.rewind

        import_zone.import(tmpfile.path).wait_until_done!

        imported_records = import_zone.records.all
        imported_records.must_include import_zone.record("@", "A", 3600, "192.0.2.1")
        imported_records.must_include import_zone.record("@", "AAAA", 3600, "2001:db8:10::1")
        imported_records.must_include import_zone.record("@", "MX", 3600, ["10 mail.#{import_zone.dns}",
                                                                           "20 mail2.#{import_zone.dns}",
                                                                           "50 mail3.#{import_zone.dns}"])
      end
    end

    it "exports records to a zone file" do
      export_zone_name = "#{zone_name}-export"
      export_zone_dns  = "export.#{zone_dns}"
      export_zone = dns.create_zone export_zone_name, export_zone_dns

      export_zone.add export_zone.dns, "A", 86400, "1.2.3.4"
      export_zone.add export_zone.dns, "AAAA", 86400, "2607:f8b0:400a:801::1005"
      export_zone.add "redirect.#{export_zone.dns}", "CNAME", 86400, "example.com."
      export_zone.add export_zone.dns, "MX", 86400, [ "10 mail.#{export_zone.dns}",
                                                      "20 mail2.#{export_zone.dns}"]

      Tempfile.open "zonefile" do |tmpfile|
        export_zone.export tmpfile

        exported_zonefile = tmpfile.read
        exported_zonefile.must_include "#{export_zone.dns} 86400 IN A 1.2.3.4"
        exported_zonefile.must_include "#{export_zone.dns} 86400 IN AAAA 2607:f8b0:400a:801::1005"
        exported_zonefile.must_include "redirect.#{export_zone.dns} 86400 IN CNAME example.com."
        exported_zonefile.must_include "#{export_zone.dns} 86400 IN MX 10 mail.#{export_zone.dns}"
        exported_zonefile.must_include "#{export_zone.dns} 86400 IN MX 20 mail2.#{export_zone.dns}"
      end
    end
  end

  describe "Changes" do
    it "creates a change" do
      change = zone.replace zone.dns, "A", 86400, "5.6.7.8"
      change.must_be_kind_of Google::Cloud::Dns::Change
      change.wait_until_done!
      change.must_be :done?
      change.status.must_equal "done"
      new_a_record = change.additions.first
      new_a_record.name.must_equal zone.dns
      new_a_record.type.must_equal "A"
      new_a_record.ttl.must_equal 86400
      new_a_record.data.must_equal ["5.6.7.8"]
    end

    it "gets a list of changes" do
      zone.changes.count.must_be :>=, 0
    end

    it "gets a single change" do
      all_changes = zone.changes.all
      all_changes.count.must_be :>=, 0
      change = zone.change all_changes.first.id
      change.must_be_kind_of Google::Cloud::Dns::Change
    end
  end

  describe "Records" do
    it "returns 0 or more records" do
      zone.records.all.count.must_be :>=, 0
    end

    it "retrieve records by name and type" do
      change = zone.add "retrieve.#{zone.dns}", "A", 86400, "9.10.11.12"
      change.wait_until_done!

      zone.records("retrieve.#{zone.dns}", "A").all.count.must_be :>=, 1
    end

    it "replaces records" do
      zone.records("replace.#{zone.dns}", "A").all.count.must_be :zero?

      change = zone.add "replace.#{zone.dns}", "A", 86400, "1.2.3.4"
      change.wait_until_done!

      zone.records("replace.#{zone.dns}", "A").all.count.wont_be :zero?

      change = zone.replace "replace.#{zone.dns}", "A", 86400, "5.6.7.8"
      change.wait_until_done!

      zone.records("replace.#{zone.dns}", "A").all.count.wont_be :zero?
    end
  end

  def create_zonefile_contents zonefile_domain
    <<-ZONEFILE
$ORIGIN #{zonefile_domain}                                    ; designates the start of this zone file in the namespace
$TTL 1h                                                       ; default expiration time of all resource records without their own TTL value
#{zonefile_domain}     IN  SOA   ns.#{zonefile_domain} username.#{zonefile_domain} ( 2007120710 1d 2h 4w 1h )
#{zonefile_domain}     IN  NS    ns                           ; ns.example.com is a nameserver for example.com
#{zonefile_domain}     IN  NS    ns.somewhere.example.        ; ns.somewhere.example is a backup nameserver for example.com
#{zonefile_domain}     IN  MX    10 mail.#{zonefile_domain}   ; mail.example.com is the mailserver for example.com
#{zonefile_domain}     IN  MX    20 mail2.#{zonefile_domain}  ; equivalent to above line, "@" represents zone origin
#{zonefile_domain}     IN  MX    50 mail3.#{zonefile_domain}  ; equivalent to above line, but using a relative host name
#{zonefile_domain}     IN  A     192.0.2.1                    ; IPv4 address for example.com
                       IN  AAAA  2001:db8:10::1               ; IPv6 address for example.com
ns                     IN  A     192.0.2.2                    ; IPv4 address for ns.example.com
                       IN  AAAA  2001:db8:10::2               ; IPv6 address for ns.example.com
www                    IN  CNAME #{zonefile_domain}           ; www.example.com is an alias for example.com
wwwtest                IN  CNAME www.#{zonefile_domain}        ; wwwtest.example.com is another alias for www.example.com
mail                   IN  A     192.0.2.3                    ; IPv4 address for mail.example.com
mail2                  IN  A     192.0.2.4                    ; IPv4 address for mail2.example.com
mail3                  IN  A     192.0.2.5                    ; IPv4 address for mail3.example.com
sip.#{zonefile_domain} IN  SRV   0 5 5060 sip.#{zonefile_domain}
sip.#{zonefile_domain} IN  TXT   "text; containing ; spaces; and; semicolons ;" ; comment about the text
ZONEFILE
  end
end if $dns_domain # only run if this global is set.
