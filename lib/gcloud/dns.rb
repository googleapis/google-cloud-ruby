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

module Gcloud
  ##
  # Creates a new `Project` instance connected to the DNS service.
  # Each call creates a new connection.
  #
  # For more information on connecting to Google Cloud see the [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # @param [String] project Identifier for a DNS project. If not present, the
  #   default project for the credentials is used.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/ndev.clouddns.readwrite`
  #
  # @return [Gcloud::Dns::Project]
  #
  # @example
  #   require "gcloud"
  #
  #   dns = Gcloud.dns "my-dns-project",
  #                    "/path/to/keyfile.json"
  #
  #   zone = dns.zone "example-com"
  #
  def self.dns project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Dns::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Dns::Credentials.default scope: scope
    else
      credentials = Gcloud::Dns::Credentials.new keyfile, scope: scope
    end
    Gcloud::Dns::Project.new project, credentials
  end

  ##
  # # Google Cloud DNS
  #
  # Google Cloud DNS is a high-performance, resilient, global DNS service that
  # provides a cost-effective way to make your applications and services
  # available to your users. This programmable, authoritative DNS service can be
  # used to easily publish and manage DNS records using the same infrastructure
  # relied upon by Google. To learn more, read [What is Google Cloud
  # DNS?](https://cloud.google.com/dns/what-is-cloud-dns).
  #
  # Gcloud's goal is to provide an API that is familiar and comfortable to
  # Rubyists. Authentication is handled by {Gcloud#dns}. You can provide the
  # project and credential information to connect to the Cloud DNS service, or
  # if you are running on Google Compute Engine this configuration is taken care
  # of for you. You can read more about the options for connecting in the
  # [Authentication
  # Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).
  #
  # ## Creating Zones
  #
  # To get started with Google Cloud DNS, use your DNS Project to create a new
  # Zone. The second argument to {Gcloud::Dns::Project#create_zone} must be a
  # unique domain name for which you can [verify
  # ownership](https://www.google.com/webmasters/verification/home). Substitute
  # a domain name of your own (ending with a dot to signify that it is [fully
  # qualified](https://en.wikipedia.org/wiki/Fully_qualified_domain_name)) as
  # you follow along with these examples.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.create_zone "example-com", "example.com."
  # puts zone.id # unique identifier defined by the server
  # ```
  #
  # For more information, see [Managing
  # Zones](https://cloud.google.com/dns/zones/).
  #
  # ## Listing Zones
  #
  # You can retrieve all the zones in your project.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zones = dns.zones
  # zones.each do |zone|
  #   puts "#{zone.name} - #{zone.dns}"
  # end
  # ```
  #
  # You can also retrieve a single zone by either name or id.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # ```
  #
  # ## Listing Records
  #
  # When you create a zone, the Cloud DNS service automatically creates two
  # Record instances for it, providing configuration for Cloud DNS nameservers.
  # Let's take a look at these records.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # records = zone.records
  # records.count #=> 2
  # records.map &:type #=> ["NS", "SOA"]
  # zone.records.first.data.count #=> 4
  # zone.records.first.data #=> ["ns-cloud-d1.googledomains.com.", ...]
  # ```
  #
  # Note that {Gcloud::Dns::Record#data} returns an array. The Cloud DNS service
  # only allows the zone to have one Record instance for each name and type
  # combination. It supports multiple "resource records" (in this case, the four
  # nameserver addresses) via this `data` collection.
  #
  # ## Managing Records
  #
  # You can easily add your own records to the zone. Each call to
  # {Gcloud::Dns::Zone#add} results in a new Cloud DNS Change instance.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # change = zone.add "www", "A", 86400, ["1.2.3.4"]
  # change.additions.map &:type #=> ["A", "SOA"]
  # change.deletions.map &:type #=> ["SOA"]
  # ```
  #
  # Whenever you change the set of records belonging to a zone, the zone's start
  # of authority (SOA) record should be updated with a higher serial number. The
  # gcloud library automates this update for you, deleting the old SOA record
  # and adding an updated one, as shown in the example above. You can disable or
  # modify this behavior, of course. See {Gcloud::Dns::Zone#update} for details.
  #
  # You can retrieve records by name and type. The name argument can be a
  # subdomain (e.g., `www`) fragment for convenience, but notice that the
  # retrieved record's domain name is always fully-qualified.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # records = zone.records "www", "A"
  # records.first.name #=> "www.example.com."
  # ```
  #
  # You can use {Gcloud::Dns::Zone#replace} to update the `ttl` and `data` for a
  # record.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # change = zone.replace "www", "A", 86400, ["5.6.7.8"]
  # ```
  #
  # Or, you can use {Gcloud::Dns::Zone#modify} to update just the `ttl` or
  # `data`, without the risk of inadvertently changing values that you wish to
  # leave unchanged.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # change = zone.modify "www", "A" do |r|
  #   r.ttl = 3600 # change only the TTL
  # end
  # ```
  #
  # You can also delete records by name and type.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # change = zone.remove "www", "A"
  # record = change.deletions.first
  # ```
  #
  # The best way to add, remove, and update multiple records in a single
  # [transaction](https://cloud.google.com/dns/records) is to call
  # {Gcloud::Dns::Zone#update} with a block. See
  # {Gcloud::Dns::Zone::Transaction}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # change = zone.update do |tx|
  #   tx.add     "www", "A",  86400, "1.2.3.4"
  #   tx.remove  "example.com.", "TXT"
  #   tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
  #                                            "20 mail2.example.com."]
  #   tx.modify "www.example.com.", "CNAME" do |r|
  #     r.ttl = 86400 # only change the TTL
  #   end
  # end
  # ```
  #
  # Finally, you can add and delete records by reference, using
  # {Gcloud::Dns::Zone#update}.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # to_add = zone.record "www", "AAAA", 86400, ["2607:f8b0:400a:801::1005"]
  # to_delete = zone.records "www", "A"
  # change = zone.update to_add, to_delete
  # ```
  #
  # ## Listing Changes
  #
  # Because the transactions you execute against your zone do not always
  # complete immediately, you can retrieve and inspect changes.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # changes = zone.changes
  # changes.each do |change|
  #   puts "#{change.id} - #{change.started_at} - #{change.status}"
  # end
  # ```
  #
  # ## Importing and exporting zone files
  #
  # You can import from a zone file. Because the Cloud DNS service only allows
  # the zone to have one Record instance for each name and type combination,
  # lines may be merged as needed into records with multiple `data` values.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  # change = zone.import "path/to/db.example.com"
  # ```
  #
  # You can also export to a zone file.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # dns = gcloud.dns
  # zone = dns.zone "example-com"
  #
  # zone.export "path/to/db.example.com"
  # ```
  #
  module Dns
  end
end
