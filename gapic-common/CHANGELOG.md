# Release History

### 0.8.0 / 2022-01-05

* Add generic LROs helpers. These used to implement Nonstandard (not conforming to AIP-151) Cloud LROs, and also can be used to implement AIP-151 LROs.
* Reimplement AIP-151 LRO helpers using the generic LRO functionality.

### 0.7.0 / 2021-08-03

* Require googleauth 0.17 for proper support of JWT credentials with custom scopes

### 0.6.0 / 2021-07-22

* Added helper for REST pagination

### 0.5.0 / 2021-06-15

* Provide a way to create `x-goog-api-client` headers with rest library version and/or without grpc library version

### 0.4.3 / 2021-06-10

* Fix file permissions.

### 0.4.2 / 2021-06-07

* Expand googleauth dependency to include 1.x
* Add a REST PUT method helper to Gapic::Rest.

### 0.4.1 / 2021-04-15

* Provide a default value for the 'body' in the REST POST method in Gapic::Rest.

### 0.4.0 / 2021-02-23

* Support for the REST calls via the Gapic::Rest::ClientStub and other classes in Gapic::Rest
  REST support is still being developed. Notably the full retries handling is not implemented yet.

### 0.3.4 / 2020-08-07

* Support the :this_channel_is_insecure gRPC pseudo-credential, used by tests and emulators.

### 0.3.3 / 2020-08-05

* Retry configs properly handle error name strings.

### 0.3.2 / 2020-07-30

* Alias PagedEnumerable#next_page to PagedEnumerable#next_page!

### 0.3.1 / 2020-06-19

* Fix file permissions

### 0.3.0 / 2020-06-18

* Update the dependency on google-protobuf to 3.12.2

### 0.2.1 / 2020-06-02

* Fix a crash when resetting a config field to nil when it has a parent but no default

### 0.2.0 / 2020-03-17

* Support default call options in Gapic::Operation
* Fix implicit kwarg warnings under Ruby 2.7

### 0.1.0 / 2020-01-09

Initial release
