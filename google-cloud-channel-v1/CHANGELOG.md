# Release History

### 0.9.4 / 2022-01-20

#### Documentation

* Updating reference documentation.

### 0.9.3 / 2022-01-11

#### Bug Fixes

* Honor quota project in auxiliary operations clients

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.2 / 2021-12-07

#### Documentation

* Minor clarifications in the documentation

### 0.9.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation
* Clarifications in the documentation for entitlement parameters

### 0.9.0 / 2021-11-02

#### Features

* Add a path helper for partner link resources

### 0.8.0 / 2021-09-08

#### Features

* Support for import_customer RPC

### 0.7.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.7.1 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.0 / 2021-06-17

#### Features

* Support lookup_offer call
  * Update descriptions of APIs.
  * Add additional_bindings to HTTP annotations of Customer related APIs (list/create/get/update/delete).
  * Add a new LookupOffer RPC and LookupOfferRequest proto.
  * Add a new enum value LICENSE_CAP_CHANGED to enum EntitlementEvent.Type.

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.6.0 / 2021-04-26

#### Features

* Support for Value#bool_value and TransferableSku#legacy_sku

### 0.5.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0
* Support setting a billing account for an offer payment plan

### 0.4.0 / 2021-02-23

#### Bug Fixes

* **BREAKING CHANGE**: Removed unlaunched fields TransferableSku#is_commitment, TransferableSku#commitment_end_timestamp, and CreateChannelPartnerLinkRequest#domain

### 0.3.0 / 2021-02-03

#### Features

* Add support for Pub/Sub subscribers

### 0.2.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.1.1 / 2021-01-15

#### Documentation

* Timeout config description correctly gives the units as seconds

### 0.1.0 / 2021-01-12

Initial release.
