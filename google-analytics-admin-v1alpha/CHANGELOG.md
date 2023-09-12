# Release History

### 0.25.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22916](https://github.com/googleapis/google-cloud-ruby/issues/22916)) 

### 0.24.0 (2023-09-07)

#### Features

* Support CRUD operations on SKAdNetworkConversionValueSchema ([#22874](https://github.com/googleapis/google-cloud-ruby/issues/22874)) 

### 0.23.0 (2023-08-15)

#### Features

* add `UpdateConversionEvent` method to the Admin API v1 alpha 
* add the `ConversionCountingMethod` enum 
* add the `counting_method` field to the `ConversionEvent` type 
#### Bug Fixes

* rename the `enterprise_daily_export_enabled` field to `fresh_daily_export_enabled` in the `BigQueryLink` resource ([#22766](https://github.com/googleapis/google-cloud-ruby/issues/22766)) 

### 0.22.0 (2023-07-28)

### ⚠ BREAKING CHANGES

* update the `ReportingAttributionModel` enum

#### Bug Fixes

* update the `ReportingAttributionModel` enum 

### 0.21.0 (2023-06-23)

#### Features

* support AdsWebConversionDataExportScope 
#### Documentation

* announce the deprecation of first-click, linear, time-decay and position-based attribution models 

### 0.20.0 (2023-06-06)

#### Features

* Uses binary protobuf definitions for better forward compatibility ([#21671](https://github.com/googleapis/google-cloud-ruby/issues/21671)) 
#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.19.0 (2023-05-15)

#### Features

* add AUDIENCE, EVENT_CREATE_RULE options to the ChangeHistoryResourceType enum 
* add AdSenseLink type to the Admin API v1alpha 
* add audience, event_create_rule fields to the ChangeHistoryResource.resource oneof field 
* add CreateEventCreateRule, UpdateEventCreateRule,DeleteEventCreateRule, ListEventCreateRules methods to the Admin API v1alpha 
* add EventCreateRule, MatchingCondition types to the Admin API v1alpha 
* add FetchConnectedGa4Property method to the Admin API v1alpha 
* add GetAdSenseLink, CreateAdSenseLink, DeleteAdSenseLink, ListAdSenseLinks methods to the Admin API v1alpha 

### 0.18.0 (2023-05-04)

#### Features

* Added ChangeHistoryResource#channel_group 
* Added CustomDimension::DimensionScope::ITEM 
* Support for fetch_connected_ga4_property 
* Support for managing channel groups 

### 0.17.0 (2023-03-23)

#### Features

* Add account-level binding for the RunAccessReport method ([#20951](https://github.com/googleapis/google-cloud-ruby/issues/20951)) 
* add enhanced_measurement_settings option to the ChangeHistoryResource.resource oneof field 
* add ENHANCED_MEASUREMENT_SETTINGS option to the ChangeHistoryResourceType enum 
* add intraday_export_enabled field to the BigQueryLink resource 

### 0.16.0 (2023-03-08)

#### Features

* Support REST transport ([#20624](https://github.com/googleapis/google-cloud-ruby/issues/20624)) 

### 0.15.0 (2023-02-21)

#### Features

* Added support for access bindings ([#20481](https://github.com/googleapis/google-cloud-ruby/issues/20481)) 
* Added support for expanded data sets 

### 0.14.0 (2023-02-13)

### ⚠ BREAKING CHANGES

* Removed the PARTIAL_REGEXP match type for StringFilter
* Removed the LESS_THAN_OR_EQUAL and GREATER_THAN_OR_EQUAL operation types for NumericFilter

#### Features

* Support for AccessQuota#tokens_per_project_per_hour 
* Support for RPCs for getting and listing BigQueryLink resources 
* Support for RPCs for managing SearchAds360Link resources ([#20137](https://github.com/googleapis/google-cloud-ruby/issues/20137)) 
* Support for RPCs for setting and fetching AutomatedGa4ConfigurationOptOut resources 
* Support for search_ads_360_link, bigquery_link and expanded_data_set fields in ChangeHistoryResource 
* Support for the EXPANDED_DATA_SET and CHANNEL_GROUP values for ChangeHistoryResourceType 
#### Bug Fixes

* Removed the LESS_THAN_OR_EQUAL and GREATER_THAN_OR_EQUAL operation types for NumericFilter 
* Removed the PARTIAL_REGEXP match type for StringFilter 

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
