# Release History

### 0.13.0 (2022-08-09)

#### Features

* Support for run_access_report ([#18985](https://github.com/googleapis/google-cloud-ruby/issues/18985)) 
* support CRUD operations for audience 

### 0.12.0 (2022-07-01)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.11.1 (2022-05-13)

#### Bug Fixes

* Fixed custom metric and custom dimension resource paths

### 0.11.0 / 2022-03-09

#### Features

* BREAKING CHANGE: remove `WebDataStream`, `IosAppDataStream`, `AndroidAppDataStream` resources and corresponding operations, as they are replaced by the `DataStream` resource
* BREAKING CHANGE: move the `GlobalSiteTag` resource from the property level to the data stream level
* add `restricted_metric_type` field to the `CustomMetric` resource

### 0.10.0 / 2022-01-11

#### Features

* BREAKING CHANGE: Removed methods related to enhanced measurement settings
* Added support for the acknowledge_user_data_collection call
* Added support for data stream management calls
* Display Video 360 Advertiser Link resources may be returned from change history
* The parent account name is provided on Property resources
* Various clarifications in the reference documentation

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.9.0 / 2021-08-25

#### Features

* Support new RPCs involving DisplayVideo360AdvertiserLink and DataRetentionSettings

### 0.8.2 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.8.1 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 0.8.0 / 2021-06-17

#### Features

* Management of MeasurementProtocolSecrets, GoogleSignalsSettings, ConversionEvents, CustomDimensions, and CustomMetrics

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.0 / 2021-05-06

#### ⚠ BREAKING CHANGES

* Remove create_ios_app_data_stream and create_android_app_data_stream

#### Features

* Support search_change_history_events call

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

#### Documentation

* Clarify field name formats, and note that app streams must be linked to a Firebase app

### 0.5.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.4.0 / 2021-01-20

#### ⚠ BREAKING CHANGES

* **analytics-admin-v1alpha:** Paginate list_firebase_links and update a number of resource fields

### 0.3.0 / 2020-12-08

#### Features

* Support name for GlobalSiteTag

### 0.2.2 / 2020-11-09

#### Documentation

* Updated several field descriptions, including noting required fields

### 0.2.1 / 2020-11-02

#### Documentation

* Use the "GA4" product name in service descriptions

### 0.2.0 / 2020-10-14

#### Features

* Support list_account_summaries method

### 0.1.1 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.0 / 2020-08-06

Initial release.
