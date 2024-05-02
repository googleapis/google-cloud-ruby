# Ruby Client for the Last Mile Fleet Solution Delivery API

Enables Fleet Engine for access to the On Demand Rides and Deliveries and Last Mile Fleet Solution APIs. Customer's use of Google Maps Content in the Cloud Logging Services is subject to the Google Maps Platform Terms of Service located at https://cloud.google.com/maps-platform/terms.

Enables Fleet Engine for access to the On Demand Rides and Deliveries and Last Mile Fleet Solution APIs. Customer's use of Google Maps Content in the Cloud Logging Services is subject to the Google Maps Platform Terms of Service located at https://cloud.google.com/maps-platform/terms.

Actual client classes for the various versions of this API are defined in
_versioned_ client gems, with names of the form `google-maps-fleet_engine-delivery-v*`.
The gem `google-maps-fleet_engine-delivery` is the main client library that brings the
verisoned gems in as dependencies, and provides high-level methods for
constructing clients. More information on versioned clients can be found below
in the section titled *Which client should I use?*.

View the [Client Library Documentation](https://rubydoc.info/gems/google-maps-fleet_engine-delivery)
for this library, google-maps-fleet_engine-delivery, to see the convenience methods for
constructing client objects. Reference documentation for the client objects
themselves can be found in the client library documentation for the versioned
client gems:
[google-maps-fleet_engine-delivery-v1](https://rubydoc.info/gems/google-maps-fleet_engine-delivery-v1).

See also the [Product Documentation](https://developers.google.com/maps/documentation/transportation-logistics/mobility)
for more usage information.

## Quick Start

```
$ gem install google-maps-fleet_engine-delivery
```

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Enable the API.](https://console.cloud.google.com/apis/library/fleetengine.googleapis.com)
1. {file:AUTHENTICATION.md Set up authentication.}

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
client library with a name such as `google-maps-fleet_engine-delivery`,
and lower-level _versioned_ client libraries with names such as
`google-maps-fleet_engine-delivery-v1`.
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
`google-maps-fleet_engine-delivery`.
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
is part of the name, e.g. `google-maps-fleet_engine-delivery-v1`.

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
