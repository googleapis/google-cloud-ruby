# Changelog

### 0.3.0 (2026-05-06)

### ⚠ BREAKING CHANGES

* update publisher_name in PairIdInfo to be required
* update match_rate_percentage in PairIdInfo to be required
* feat: update advertiser_identifier_count in PairIdInfo to be optional
* changed `conversion_value` field to be optional in message `Event`

#### Features

* add `AgeRange` and `Gender` enums to support demographic breakdown in marketing insights 
* add `GOOGLE_AD_MANAGER_AUDIENCE_LINK` to the `AccountType` enum 
* add `IngestPpidDataStatus` to `IngestAudienceMembersStatus` to report the status of PPID data ingestion 
* add `IngestUserIdDataStatus` to `IngestAudienceMembersStatus` to report the status of user ID data ingestion 
* add `MarketingDataInsightsService` for retrieving marketing data insights for a given user list 
* add `PartnerLink` resource 
* add `PartnerLinkService` for creating and managing links between advertiser and data partner accounts 
* add `PpidData` to `AudienceMember` to support Publisher Provided ID (PPID) in audience member ingestion 
* add `RemovePpidDataStatus` to `RemoveAudienceMembersStatus` to report the status of PPID data removal 
* add `RemoveUserIdDataStatus` to `RemoveAudienceMembersStatus` to report the status of user ID data removal 
* add `UserIdData` to `AudienceMember` to support User ID in audience member ingestion 
* add `UserList` resource 
* add `UserListDirectLicense` resource 
* add `UserListDirectLicenseService` for creating and managing direct user list licenses 
* add `UserListGlobalLicense` resource 
* add `UserListGlobalLicenseCustomerInfo` resource 
* add `UserListGlobalLicenseService` for creating and managing global user list licenses 
* add `UserListService` for creating and managing user lists 
* add EU_POLITICAL_ADVERTISING_DECLARATION_REQUIRED to the ErrorReason enum for campaigns missing the EU political advertising declaration 
* add INVALID_MERCHANT_ID to the ErrorReason enum for when the merchant_id field is not valid 
* Add irb as explicit dependency for Ruby 4.0 compatibility 
* add new `ErrorReason` values for licensing, user list operations, and permission checks 
* deprecate INVALID_COUNTRY_CODE and add MEMBERSHIP_DURATION_TOO_LONG to the ErrorReason enum 
* publish client batch config schema 
* publish new error reasons 
* Update minimum Ruby to v3.2 and required dependencies for Ruby v4.0 
* upgrade protobuf from v25.7 to v31.0 
#### Bug Fixes

* changed `conversion_value` field to be optional in message `Event` 
* feat: update advertiser_identifier_count in PairIdInfo to be optional 
* update match_rate_percentage in PairIdInfo to be required 
* update publisher_name in PairIdInfo to be required 
#### Documentation

* a comment for enum `ErrorReason` is changed to clarify that it is subject to future additions 
* a comment for field `pair_data` in message `AudienceMember` is changed to clarify it is only available to data partners 
* a comment for message `PairData` is changed to clarify it is only available to data partners 
* add comments to resources and methods to clarify which are available only to data partners 
* describe additional URI format for kek_uri in GcpEncryptionInfo and AwsKmsEncryptionInfo 
* fix documentation formatting 
* update filter field documentation to clarify case requirements and improve examples 
* update license year 
* update SelectiveGapicGeneration usage doc ([#32407](https://github.com/googleapis/google-cloud-ruby/issues/32407)) 
* update various comments 

### 0.2.0 (2025-11-11)

#### Features

* add `additional_user_properties` to `UserProperties` for sending additional key-value pairs of user properties 
* add `AwsWrappedKeyInfo` to `EncryptionInfo` for supporting data encryption using AWS KMS keys ([#32161](https://github.com/googleapis/google-cloud-ruby/issues/32161)) 

### 0.1.0 (2025-10-29)

#### Features

* Initial generation of google-ads-data_manager-v1 ([#32124](https://github.com/googleapis/google-cloud-ruby/issues/32124)) 

## Release History
