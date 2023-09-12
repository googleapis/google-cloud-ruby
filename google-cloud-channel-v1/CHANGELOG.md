# Release History

### 0.22.0 (2023-09-12)

#### Features

* Added billing_account field to CreateEntitlementPurchase and ChangeOfferPurchase 
* Added CHANNEL_PARTNER_NOT_AUTHORIZED_FOR_SKU as a transfer ineligibility reason 
* Support for boolean offer parameters 
* Support for the query_eligible_billing_accounts RPC ([#22911](https://github.com/googleapis/google-cloud-ruby/issues/22911)) 
* The list_transferable_offers and change_offer calls now take a billing_account argument 
* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.21.0 (2023-06-16)

#### Features

* Add support for ListSkuGroups and ListSkuGroupBillableSkus APIs ([#22409](https://github.com/googleapis/google-cloud-ruby/issues/22409)) 

### 0.20.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21673](https://github.com/googleapis/google-cloud-ruby/issues/21673)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.19.0 (2023-05-19)

#### Features

* support partition_keys to filter results from FetchReportResults 

### 0.18.0 (2023-05-08)

#### Features

* Added billing account field to the Entitlement resource ([#21551](https://github.com/googleapis/google-cloud-ruby/issues/21551)) 

### 0.17.0 (2023-03-15)

#### Features

* Add EntitlementChange to record event history for Entitlement orders ([#20898](https://github.com/googleapis/google-cloud-ruby/issues/20898)) 

### 0.16.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.15.0 (2022-12-14)

#### Features

* Added support for granular repricing configurations via SkuGroups ([#19848](https://github.com/googleapis/google-cloud-ruby/issues/19848)) 

### 0.14.0 (2022-11-10)

#### Features

* Added Offer#deal_code field ([#19400](https://github.com/googleapis/google-cloud-ruby/issues/19400)) 

### 0.13.0 (2022-10-19)

#### Features

* Support for CloudChannelReportsService operations, including run_report_job, fetch_report_results, and list_reports ([#19296](https://github.com/googleapis/google-cloud-ruby/issues/19296)) 

### 0.12.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 
#### Bug Fixes

* Fixed a crash when making certain long-running-operations status calls ([#18441](https://github.com/googleapis/google-cloud-ruby/issues/18441)) 

### 0.11.0 (2022-04-28)

#### Features

* Support for repricing

### 0.10.0 (2022-04-22)

#### Features

* add support for filters in ListCustomersRequest

### 0.9.5 / 2022-02-15

#### Documentation

* Clarification of the provisioning_id description
* Minor updates to reference documentation

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
