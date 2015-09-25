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

require "gcloud"
require "gcloud/dns/project"

#--
# Google Cloud DNS
module Gcloud
  ##
  # Creates a new +Project+ instance connected to the DNS service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +project+::
  #   Identifier for a DNS project. If not present, the default project for
  #   the credentials is used. (+String+)
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   * +https://www.googleapis.com/auth/ndev.clouddns.readwrite+
  #
  # === Returns
  #
  # Gcloud::Dns::Project
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #
  def self.dns project = nil, keyfile = nil, options = {}
    project ||= Gcloud::Dns::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Dns::Credentials.default options
    else
      credentials = Gcloud::Dns::Credentials.new keyfile, options
    end
    Gcloud::Dns::Project.new project, credentials
  end

  # rubocop:disable all
  # Disabled rubocop because necessary URLs violate line length limit.

  ##
  # = Google Cloud DNS
  #
  # Google Cloud DNS is a high-performance, resilient, global DNS service that
  # provides a cost-effective way to make your applications and services
  # available to your users. This programmable, authoritative DNS service can be
  # used to easily publish and manage DNS records using the same infrastructure
  # relied upon by Google. To learn more, read {What is Google Cloud
  # DNS?}[https://cloud.google.com/dns/what-is-cloud-dns].
  #
  # Gcloud's goal is to provide an API that is familiar and comfortable to
  # Rubyists. Authentication is handled by Gcloud#bigquery. You can provide
  # the project and credential information to connect to the BigQuery service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you. You can read more about the options for connecting in the
  # {Authentication Guide}[link:AUTHENTICATION.md].
  #
  # == Creating Zones
  #
  # To get started with Google Cloud DNS, use your DNS Project to create a new
  # Zone. The second argument to Project#create_zone must be a globally unique
  # domain name for which you can {verify
  # ownership}[https://www.google.com/webmasters/verification/home]. Substitute
  # a domain name of your own (ending with a dot to signify that it is {fully
  # qualified}[https://en.wikipedia.org/wiki/Fully_qualified_domain_name]) as
  # you follow along with these examples.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.create_zone "example-com", "example.com."
  #   puts zone.id # unique identifier defined by the server
  #
  # For more information, see {Managing
  # Zones}[https://cloud.google.com/dns/zones/].
  #
  # == Listing Zones
  #
  # You can retrieve all the zones in your project.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zones = dns.zones
  #   zones.each do |zone|
  #     puts zone.name
  #   end
  #
  # You can also retrieve a single zone by either name or id.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #
  # == Listing Records
  #
  # When you create a zone, the Cloud DNS service automatically creates two
  # records for it, providing configuration for Cloud DNS nameservers. Let's
  # take a look at these records.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   records = zone.records
  #   records.count #=> 2
  #   records.map &:type #=> ["NS", "SOA"]
  #   zone.records.first.data #=> ["ns-cloud-d1.googledomains.com.", ...]
  #
  # You can also retrieve records by +name+ and +type+. The +name+ argument can
  # be just a prefix (e.g., +www+) for convenience, but notice that the
  # retrieved record's name is always fully-qualified.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   records = zone.records "www", "A"
  #   records.first.name #=> "www.example.com."
  #
  # == Managing Records
  #
  # You can easily add your own records to the zone. Each call to Zone#add
  # results in a new Cloud DNS Change.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   change = zone.add "example.com.", "A", 86400, ["1.2.3.4"]
  #   record = change.additions.first
  #
  # You can also delete records by name and type.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   change = zone.remove "example.com.", "A"
  #
  # Or, you can delete a record by reference, using Zone#update. Note that although the
  # Zone#records method returns an array, the Cloud DNS service only allows the
  # zone to have one record for each name and type combination.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   record_to_delete = zone.records "example.com.", "MX"
  #   change = zone.update [], record_to_delete
  #
  # You can use Zone#replace to update the +ttl+ and +data+ for a record.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   change = zone.replace "example.com.", "A", 86400, ["5.6.7.8"]
  #
  # Or, you can use Zone#modify to update just the +ttl+ or +data+, without the
  # risk of inadvertently changing values that you wish to leave unchanged.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   change = zone.modify "example.com.", "MX" do |mx|
  #     mx.ttl = 3600 # change only the TTL
  #   end
  #
  # The best way to add, remove, and update multiple in a single
  # {transaction}[https://cloud.google.com/dns/records/#modifying_records_using_transactions]
  # is to call +update+ with a block. See Zone::Transaction.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   change = zone.update do |tx|
  #     tx.add     "example.com.", "A",  86400, "1.2.3.4"
  #     tx.remove  "example.com.", "TXT"
  #     tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
  #                                              "20 mail2.example.com."]
  #     tx.modify "www.example.com.", "CNAME" do |cname|
  #       cname.ttl = 86400 # only change the TTL
  #     end
  #   end
  #
  # == Listing Changes
  #
  # Because the transactions you execute against your zone do not complete
  # immediately, you can retrieve and inspect changes.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   changes = zone.changes
  #   changes.each do |change|
  #     puts "#{change.name} - #{change.status}"
  #   end
  #
  # == Importing and exporting zone files
  #
  # You can import from a zone file.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #   change = zone.import "path/to/db.example.com"
  #
  # And export to a zone file.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   dns = gcloud.dns
  #   zone = dns.zone "example-com"
  #
  #   zone.export "path/to/db.example.com"
  module Dns
  end

  # rubocop:enable all
end
