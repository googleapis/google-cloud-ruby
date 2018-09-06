# Google Cloud DNS

Google Cloud DNS is a high-performance, resilient, global DNS service that
provides a cost-effective way to make your applications and services
available to your users. This programmable, authoritative DNS service can
be used to easily publish and manage DNS records using the same
infrastructure relied upon by Google. To learn more, read [What is Google
Cloud DNS?](https://cloud.google.com/dns/what-is-cloud-dns).

The goal of google-cloud is to provide an API that is comfortable to
Rubyists. Your authentication credentials are detected automatically in
Google Cloud Platform environments such as Google Compute Engine, Google
App Engine and Google Kubernetes Engine. In other environments you can
configure authentication easily, either directly in your code or via
environment variables. Read more about the options for connecting in the
{file:AUTHENTICATION.md Authentication Guide}.

## Creating Zones

To get started with Google Cloud DNS, use your DNS Project to create a new
Zone. The second argument to {Google::Cloud::Dns::Project#create_zone}
must be a unique domain name for which you can [verify
ownership](https://www.google.com/webmasters/verification/home).
Substitute a domain name of your own (ending with a dot to signify that it
is [fully
qualified](https://en.wikipedia.org/wiki/Fully_qualified_domain_name)) as
you follow along with these examples.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.create_zone "example-com", "example.com."
puts zone.id # unique identifier defined by the server
```

For more information, see [Managing
Zones](https://cloud.google.com/dns/zones/).

## Listing Zones

You can retrieve all the zones in your project.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zones = dns.zones
zones.each do |zone|
  puts "#{zone.name} - #{zone.dns}"
end
```

You can also retrieve a single zone by either name or id.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
```

## Listing Records

When you create a zone, the Cloud DNS service automatically creates two
Record instances for it, providing configuration for Cloud DNS
nameservers. Let's take a look at these records.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
records = zone.records
records.count #=> 2
records.map &:type #=> ["NS", "SOA"]
zone.records.first.data.count #=> 4
zone.records.first.data #=> ["ns-cloud-d1.googledomains.com.", ...]
```

Note that {Google::Cloud::Dns::Record#data} returns an array. The Cloud
DNS service only allows the zone to have one Record instance for each name
and type combination. It supports multiple "resource records" (in this
case, the four nameserver addresses) via this `data` collection.

## Managing Records

You can easily add your own records to the zone. Each call to
{Google::Cloud::Dns::Zone#add} results in a new Cloud DNS Change instance.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
change = zone.add "www", "A", 86400, ["1.2.3.4"]
change.additions.map &:type #=> ["A", "SOA"]
change.deletions.map &:type #=> ["SOA"]
```

Whenever you change the set of records belonging to a zone, the zone's
start of authority (SOA) record should be updated with a higher serial
number. The google-cloud library automates this update for you, deleting
the old SOA record and adding an updated one, as shown in the example
above. You can disable or modify this behavior, of course. See
{Google::Cloud::Dns::Zone#update} for details.

You can retrieve records by name and type. The name argument can be a
subdomain (e.g., `www`) fragment for convenience, but notice that the
retrieved record's domain name is always fully-qualified.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
records = zone.records "www", "A"
records.first.name #=> "www.example.com."
```

You can use {Google::Cloud::Dns::Zone#replace} to update the `ttl` and
`data` for a record.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
change = zone.replace "www", "A", 86400, ["5.6.7.8"]
```

Or, you can use {Google::Cloud::Dns::Zone#modify} to update just the `ttl`
or `data`, without the risk of inadvertently changing values that you wish
to leave unchanged.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
change = zone.modify "www", "A" do |r|
  r.ttl = 3600 # change only the TTL
end
```

You can also delete records by name and type.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
change = zone.remove "www", "A"
record = change.deletions.first
```

The best way to add, remove, and update multiple records in a single
[transaction](https://cloud.google.com/dns/records) is to call
{Google::Cloud::Dns::Zone#update} with a block. See
{Google::Cloud::Dns::Zone::Transaction}.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
change = zone.update do |tx|
  tx.add     "www", "A",  86400, "1.2.3.4"
  tx.remove  "example.com.", "TXT"
  tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
                                           "20 mail2.example.com."]
  tx.modify "www.example.com.", "CNAME" do |r|
    r.ttl = 86400 # only change the TTL
  end
end
```

Finally, you can add and delete records by reference, using
{Google::Cloud::Dns::Zone#update}.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
to_add = zone.record "www", "AAAA", 86400, ["2607:f8b0:400a:801::1005"]
to_delete = zone.records "www", "A"
change = zone.update to_add, to_delete
```

## Listing Changes

Because the transactions you execute against your zone do not always
complete immediately, you can retrieve and inspect changes.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
changes = zone.changes
changes.each do |change|
  puts "#{change.id} - #{change.started_at} - #{change.status}"
end
```

## Importing and exporting zone files

You can import from a zone file. Because the Cloud DNS service only allows
the zone to have one Record instance for each name and type combination,
lines may be merged as needed into records with multiple `data` values.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"
change = zone.import "path/to/db.example.com"
```

You can also export to a zone file.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new
zone = dns.zone "example-com"

zone.export "path/to/db.example.com"
```

## Configuring retries and timeout

You can configure how many times API requests may be automatically
retried. When an API request fails, the response will be inspected to see
if the request meets criteria indicating that it may succeed on retry,
such as `500` and `503` status codes or a specific internal error code
such as `rateLimitExceeded`. If it meets the criteria, the request will be
retried after a delay. If another error occurs, the delay will be
increased before a subsequent attempt, until the `retries` limit is
reached.

You can also set the request `timeout` value in seconds.

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new retries: 10, timeout: 120
```

## Additional information

Google Cloud DNS can be configured to use logging. To learn more, see the
{file:LOGGING.md Logging guide}.
