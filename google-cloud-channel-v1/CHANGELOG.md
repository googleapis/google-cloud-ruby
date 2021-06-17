# Release History

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
