# Changelog

### 4.0.0 (2026-05-13)

### ⚠ BREAKING CHANGES

* An existing value `DEMAND_SUBCHANNEL_ALL` is removed from enum `Dimension`
* Changed field behavior for an existing field `display_name` in message `.google.ads.admanager.v1.Application`
* Removed UNIFIED_PRICING_RULE_ID dimension
* Removed UNIFIED_PRICING_RULE_NAME dimension
* Remove unused AdManagerError type
* New REQUIRED field `display_name` in message `.google.ads.admanager.v1.Label`
* New REQUIRED field `types` in message `.google.ads.admanager.v1.Label`

#### Features

* A new field `app_store_display_name` is added to message `.google.ads.admanager.v1.Application` 
* A new field `app_store_id` is added to message `.google.ads.admanager.v1.Application` 
* A new field `app_stores` is added to message `.google.ads.admanager.v1.Application` 
* A new field `application_code` is added to message `.google.ads.admanager.v1.Application` 
* A new field `approval_status` is added to message `.google.ads.admanager.v1.Application` 
* A new field `archived` is added to message `.google.ads.admanager.v1.Application` 
* A new field `developer` is added to message `.google.ads.admanager.v1.Application` 
* A new field `download_url` is added to message `.google.ads.admanager.v1.Application` 
* A new field `free` is added to message `.google.ads.admanager.v1.Application` 
* A new field `platform` is added to message `.google.ads.admanager.v1.Application` 
* A new field `webview_claiming_status` is added to message `.google.ads.admanager.v1.Application` 
* A new message `ApplicationApprovalStatusEnum` is added 
* A new message `ApplicationPlatformEnum` is added 
* A new message `ApplicationStoreEnum` is added 
* A new message `BatchArchiveApplicationsRequest` is added 
* A new message `BatchArchiveApplicationsResponse` is added 
* A new message `BatchCreateApplicationsRequest` is added 
* A new message `BatchCreateApplicationsResponse` is added 
* A new message `BatchUnarchiveApplicationsRequest` is added 
* A new message `BatchUnarchiveApplicationsResponse` is added 
* A new message `BatchUpdateApplicationsRequest` is added 
* A new message `BatchUpdateApplicationsResponse` is added 
* A new message `CreateApplicationRequest` is added 
* A new message `UpdateApplicationRequest` is added 
* A new message `WebviewClaimingStatusEnum` is added 
* A new method `BatchArchiveApplications` is added to service `ApplicationService` 
* A new method `BatchCreateApplications` is added to service `ApplicationService` 
* A new method `BatchUnarchiveApplications` is added to service `ApplicationService` 
* A new method `BatchUpdateApplications` is added to service `ApplicationService` 
* A new method `CreateApplication` is added to service `ApplicationService` 
* A new method `UpdateApplication` is added to service `ApplicationService` 
* Add readonly OAuth scope 
* added new API dimension: CREATIVE_SSL_SCAN_RESULT 
* added new PUBLIC dimension: CREATIVE_SSL_COMPLIANCE_OVERRIDE_NAME 
* added new PUBLIC dimension: CREATIVE_SSL_SCAN_RESULT_NAME 
* added new PUBLIC dimension: LINE_ITEM_AVERAGE_NUMBER_OF_VIEWERS 
* added new PUBLIC dimension: TARGETS_CUSTOMER_MATCHING_LIST 
* added new PUBLIC metric: AD_SERVER_ACTIVE_VIEW_REVENUE 
* Added child publisher resource. 
* Add ProposalLineItem service and messages to the API. 
* This is referenced for delegation_type in mcm_earnings 
* Expose both `get` and `list` methods for RichMediaAdsCompanies to external clients. 
* Added McmEarnings service 
* New REQUIRED field `display_name` in message `.google.ads.admanager.v1.Label` 
* New REQUIRED field `types` in message `.google.ads.admanager.v1.Label` 
#### Bug Fixes

* An existing value `DEMAND_SUBCHANNEL_ALL` is removed from enum `Dimension` 
* Changed field behavior for an existing field `display_name` in message `.google.ads.admanager.v1.Application` 
* Remove unused AdManagerError type 
* Removed UNIFIED_PRICING_RULE_ID dimension 
* Removed UNIFIED_PRICING_RULE_NAME dimension 
#### Documentation

* `UNIFIED_PRICING_RULE_ID` in enum `Dimension` is deprecated 
* `UNIFIED_PRICING_RULE_NAME` in enum `Dimension` is deprecated 
* A comment for enum value `DEMAND_SUBCHANNEL_NAME` in enum `Dimension` is changed 
* A comment for enum value `DEMAND_SUBCHANNEL` in enum `Dimension` is changed 
* A comment for enum value `PRICING_RULE_ID` in enum `Dimension` is changed 
* A comment for enum value `PRICING_RULE_NAME` in enum `Dimension` is changed 
* A comment for enum value `UNIFIED_PRICING_RULE_ID` in enum `Dimension` is changed 
* A comment for enum value `UNIFIED_PRICING_RULE_NAME` in enum `Dimension` is changed 
* A comment for field `display_name` in message `.google.ads.admanager.v1.Application` is changed 
* A comment for field `filter` in message `.google.ads.admanager.v1.ListApplicationsRequest` is changed 
* Clarify the behavior of the date_time_range filter when combined with a PENDING manual_review_status. 
* Expand regex to regular expression 
* Remove usage of and/or slashes 
* Replace 'via' in all docs 
* Replace all curly quotes with regular quotes 

### 3.1.0 (2026-03-19)

#### Features

* Upgrade dependencies for Ruby v4.0 and drop Ruby v3.1 support

### 3.0.0 (2025-12-17)

### ⚠ BREAKING CHANGES

* Added proto3 optional to Network primitive fields ([#32254](https://github.com/googleapis/google-cloud-ruby/issues/32254))

#### Bug Fixes

* Added proto3 optional to Network primitive fields ([#32254](https://github.com/googleapis/google-cloud-ruby/issues/32254)) 

### 2.1.0 (2025-11-21)

#### Features

* Added Application resource ([#31801](https://github.com/googleapis/google-cloud-ruby/issues/31801)) 

### 2.0.1 (2025-09-12)

#### Documentation

* Add examples to wrapper libraries README.md ([#31320](https://github.com/googleapis/google-cloud-ruby/issues/31320)) 

### 2.0.0 (2025-07-21)

### ⚠ BREAKING CHANGES

* Updated google-ads-ad_manager-v1 dependency to version 2.x ([#30695](https://github.com/googleapis/google-cloud-ruby/issues/30695))

#### Features

* Support for Contact company display name 
* Support for custom targeting key 
* Support for the AdBreakService 
* Support for the BandwidthGroupService 
* Support for the DeviceCategoryService 
* Support for the GeoTargetService 
* Support for the OperatingSystemService and OperatingSystemVersionService 
* Support for the PrivateAuctionService and PrivateAuctionDealService 
* Support for the ProgrammaticBuyerService 
* Updated google-ads-ad_manager-v1 dependency to version 2.x ([#30695](https://github.com/googleapis/google-cloud-ruby/issues/30695)) 

### 1.0.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 1.0.0 (2025-02-13)

### ⚠ BREAKING CHANGES

* Updated google-ads-ad_manager-v1 dependency to version 1.x ([#29028](https://github.com/googleapis/google-cloud-ruby/issues/29028))

#### Features

* Bump version to 1.0.0 ([#29159](https://github.com/googleapis/google-cloud-ruby/issues/29159)) 
* Updated google-ads-ad_manager-v1 dependency to version 1.x ([#29028](https://github.com/googleapis/google-cloud-ruby/issues/29028)) 

### 0.2.0 (2025-01-29)

#### Features

* Provide methods to determine whether services are available with the currently installed versioned client ([#28526](https://github.com/googleapis/google-cloud-ruby/issues/28526)) 
* Update Ruby version requirement to 3.0 

### 0.1.0 (2024-10-28)

#### Features

* Initial generation of google-ads-ad_manager ([#27518](https://github.com/googleapis/google-cloud-ruby/issues/27518)) 

## Release History
