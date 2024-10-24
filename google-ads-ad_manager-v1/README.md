# Ruby Client for the Google Ad Manager V1 API

Manage your Ad Manager inventory, run reports and more.

The Ad Manager API enables an app to integrate with Google Ad Manager. You can read Ad Manager data and run reports using the API.

https://github.com/googleapis/google-cloud-ruby

This gem is a _versioned_ client. It provides basic client classes for a
specific version of the Google Ad Manager V1 API. Most users should consider using
the main client gem,
[google-ads-ad_manager](https://rubygems.org/gems/google-ads-ad_manager).
See the section below titled *Which client should I use?* for more information.

## Installation

```
$ gem install google-ads-ad_manager-v1
```

## Before You Begin

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Enable the API.](https://console.cloud.google.com/apis/library/admanager.googleapis.com)
1. [Set up authentication.](AUTHENTICATION.md)

## Quick Start

```ruby
require "google/ads/admanager/v1"

client = ::Google::Ads::Admanager::V1::AdUnitService::Rest::Client.new
request = ::Google::Ads::Admanager::V1::GetAdUnitRequest.new # (request fields as keyword arguments...)
response = client.get_ad_unit request
```

View the [Client Library Documentation](https://rubydoc.info/gems/google-ads-ad_manager-v1)
for class and method documentation.

See also the [Product Documentation](https://developers.google.com/ad-manager/api/beta)
for general usage information.


## Google Cloud Samples

To browse ready to use code samples check [Google Cloud Samples](https://cloud.google.com/docs/samples).

## Supported Ruby Versions

This library is supported on Ruby 2.7+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Older versions of Ruby _may_
still work, but are unsupported and not recommended. See
https://www.ruby-lang.org/en/downloads/branches/ for details about the Ruby
support schedule.

## Which client should I use?

Most modern Ruby client libraries for Google APIs come in two flavors: the main
client library with a name such as `google-ads-ad_manager`,
and lower-level _versioned_ client libraries with names such as
`google-ads-ad_manager-v1`.
_In most cases, you should install the main client._

### What's the difference between the main client and a versioned client?

A _versioned client_ provides a basic set of data types and client classes for
a _single version_ of a specific service. (That is, for a service with multiple
versions, there might be a separate versioned client for each service version.)
Most versioned clients are written and maintained by a code generator.

The _main client_ is designed to provide you with the _recommended_ client
interfaces for the service. There will be only one main client for any given
service, even a service with multiple versions. The main client includes
factory methods for constructing the client objects we recommend for most
users. In some cases, those will be classes provided by an underlying versioned
client; in other cases, they will be handwritten higher-level client objects
with additional capabilities, convenience methods, or best practices built in.
Generally, the main client will default to a recommended service version,
although in some cases you can override this if you need to talk to a specific
service version.

### Why would I want to use the main client?

We recommend that most users install the main client gem for a service. You can
identify this gem as the one _without_ a version in its name, e.g.
`google-ads-ad_manager`.
The main client is recommended because it will embody the best practices for
accessing the service, and may also provide more convenient interfaces or
tighter integration into frameworks and third-party libraries. In addition, the
documentation and samples published by Google will generally demonstrate use of
the main client.

### Why would I want to use a versioned client?

You can use a versioned client if you are content with a possibly lower-level
class interface, you explicitly want to avoid features provided by the main
client, or you want to access a specific service version not be covered by the
main client. You can identify versioned client gems because the service version
is part of the name, e.g. `google-ads-ad_manager-v1`.

### What about the google-apis-<name> clients?

Client library gems with names that begin with `google-apis-` are based on an
older code generation technology. They talk to a REST/JSON backend (whereas
most modern clients talk to a [gRPC](https://grpc.io/) backend) and they may
not offer the same performance, features, and ease of use provided by more
modern clients.

The `google-apis-` clients have wide coverage across Google services, so you
might need to use one if there is no modern client available for the service.
However, if a modern client is available, we generally recommend it over the
older `google-apis-` clients.
