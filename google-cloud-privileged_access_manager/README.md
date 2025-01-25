# Ruby Client for the Privileged Access Manager API

Privileged Access Manager (PAM) helps you on your journey towards least privilege and helps mitigate risks tied to privileged access misuse or abuse. PAM allows you to shift from always-on standing privileges towards on-demand access with just-in-time, time-bound, and approval-based access elevations. PAM allows IAM administrators to create entitlements that can grant just-in-time, temporary access to any resource scope. Requesters can explore eligible entitlements and request the access needed for their task. Approvers are notified when approvals await their decision. Streamlined workflows facilitated by using PAM can support various use cases, including emergency access for incident responders, time-boxed access for developers for critical deployment or maintenance, temporary access for operators for data ingestion and audits, JIT access to service accounts for automated tasks, and more.

## Overview

Privileged Access Manager (PAM) is a Google Cloud native, managed solution
to secure, manage and audit privileged access while ensuring operational
velocity and developer productivity.

PAM enables just-in-time, time-bound, approval-based access elevations,
and auditing of privileged access elevations and activity. PAM lets you
define the rules of who can request access, what they can request access
to, and if they should be granted access with or without approvals based
on the sensitivity of the access and emergency of the situation.

## Concepts

### Entitlement

An entitlement is an eligibility or license that allows specified users
(requesters) to request and obtain access to specified resources subject
to a set of conditions such as duration, etc. entitlements can be granted
to both human and non-human principals.

### Grant

A grant is an instance of active usage against the entitlement. A user can
place a request for a grant against an entitlement. The request may be
forwarded to an approver for their decision. Once approved, the grant is
activated, ultimately giving the user access (roles/permissions) on a
resource per the criteria specified in entitlement.

### How does PAM work

PAM creates and uses a service agent (Google-managed service account) to
perform the required IAM policy changes for granting access at a
specific
resource/access scope. The service agent requires getIAMPolicy and
setIAMPolicy permissions at the appropriate (or higher) access scope
-
Organization/Folder/Project to make policy changes on the resources listed
in PAM entitlements.

When enabling PAM for a resource scope, the user/ principal performing
that action should have the appropriate permissions at that resource
scope
(resourcemanager.\\{projects|folders|organizations}.setIamPolicy,
resourcemanager.\\{projects|folders|organizations}.getIamPolicy, and
resourcemanager.\\{projects|folders|organizations}.get) to list and grant
the service agent/account the required access to perform IAM policy
changes.

Actual client classes for the various versions of this API are defined in
_versioned_ client gems, with names of the form `google-cloud-privileged_access_manager-v*`.
The gem `google-cloud-privileged_access_manager` is the main client library that brings the
verisoned gems in as dependencies, and provides high-level methods for
constructing clients. More information on versioned clients can be found below
in the section titled *Which client should I use?*.

View the [Client Library Documentation](https://cloud.google.com/ruby/docs/reference/google-cloud-privileged_access_manager/latest)
for this library, google-cloud-privileged_access_manager, to see the convenience methods for
constructing client objects. Reference documentation for the client objects
themselves can be found in the client library documentation for the versioned
client gems:
[google-cloud-privileged_access_manager-v1](https://cloud.google.com/ruby/docs/reference/google-cloud-privileged_access_manager-v1/latest).

See also the [Product Documentation](https://cloud.google.com/iam/docs/pam-overview)
for more usage information.

## Quick Start

```
$ gem install google-cloud-privileged_access_manager
```

In order to use this library, you first need to go through the following steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
1. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
1. [Enable the API.](https://console.cloud.google.com/apis/library/privilegedaccessmanager.googleapis.com)
1. [Set up authentication.](AUTHENTICATION.md)

## Debug Logging

This library comes with opt-in Debug Logging that can help you troubleshoot
your application's integration with the API. When logging is activated, key
events such as requests and responses, along with data payloads and metadata
such as headers and client configuration, are logged to the standard error
stream.

**WARNING:** Client Library Debug Logging includes your data payloads in
plaintext, which could include sensitive data such as PII for yourself or your
customers, private keys, or other security data that could be compromising if
leaked. Always practice good data hygiene with your application logs, and follow
the principle of least access. Google also recommends that Client Library Debug
Logging be enabled only temporarily during active debugging, and not used
permanently in production.

To enable logging, set the environment variable `GOOGLE_SDK_RUBY_LOGGING_GEMS`
to the value `all`. Alternatively, you can set the value to a comma-delimited
list of client library gem names. This will select the default logging behavior,
which writes logs to the standard error stream. On a local workstation, this may
result in logs appearing on the console. When running on a Google Cloud hosting
service such as [Google Cloud Run](https://cloud.google.com/run), this generally
results in logs appearing alongside your application logs in the
[Google Cloud Logging](https://cloud.google.com/logging/) service.

Debug logging also requires that the versioned clients for this service be
sufficiently recent, released after about Dec 10, 2024. If logging is not
working, try updating the versioned clients in your bundle or installed gems:
[google-cloud-privileged_access_manager-v1](https://cloud.google.com/ruby/docs/reference/google-cloud-privileged_access_manager-v1/latest).

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
client library with a name such as `google-cloud-privileged_access_manager`,
and lower-level _versioned_ client libraries with names such as
`google-cloud-privileged_access_manager-v1`.
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
`google-cloud-privileged_access_manager`.
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
is part of the name, e.g. `google-cloud-privileged_access_manager-v1`.

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
