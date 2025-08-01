# Release History

### 2.3.1 (2025-07-15)

#### Documentation

* clarify documentation for cases when multiple parameters are mutually exclusive for an RPC method ([#30623](https://github.com/googleapis/google-cloud-ruby/issues/30623)) 

### 2.3.0 (2025-05-12)

#### Features

* Updated core dependencies including gapic-common 
* Updated required Ruby version to 3.1 

### 2.2.2 (2025-04-29)

#### Documentation

* update documentation URL ([#30031](https://github.com/googleapis/google-cloud-ruby/issues/30031)) 

### 2.2.1 (2025-04-29)

#### Bug Fixes

* Fixed several issues with validating credential configs 

### 2.2.0 (2025-04-25)

#### Features

* MigrationConfig now includes the time when the Tag Template migration was enabled ([#29523](https://github.com/googleapis/google-cloud-ruby/issues/29523)) 

### 2.1.1 (2025-04-18)

#### Documentation

* clarify sql variant in comment for LookupEntryRequest ([#29454](https://github.com/googleapis/google-cloud-ruby/issues/29454)) 

### 2.1.0 (2025-03-14)

#### Features

* Documented the service as deprecated ([#29352](https://github.com/googleapis/google-cloud-ruby/issues/29352)) 

### 2.0.0 (2025-02-07)

### ⚠ BREAKING CHANGES

* Fixed incorrect pagination on certain REST RPC methods ([#28823](https://github.com/googleapis/google-cloud-ruby/issues/28823))

#### Bug Fixes

* Fixed incorrect pagination on certain REST RPC methods ([#28823](https://github.com/googleapis/google-cloud-ruby/issues/28823)) 

### 1.4.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.3.1 (2025-01-08)

#### Documentation

* Fixed a link ([#28119](https://github.com/googleapis/google-cloud-ruby/issues/28119)) 

### 1.3.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.2.0 (2024-12-04)

#### Features

* Support for dataplex transfers 
* Support for the set_config, retrieve_config, and retrieve_effective_config RPCs 

### 1.1.0 (2024-11-14)

#### Features

* A new enum `DataplexTransferStatus` is added 
* A new field `dataplex_transfer_status` is added to message `.google.cloud.datacatalog.v1.TagTemplate` 
* A new field `feature_online_store_spec` is added to message `.google.cloud.datacatalog.v1.Entry` ([#27611](https://github.com/googleapis/google-cloud-ruby/issues/27611)) 
* A new message `FeatureOnlineStoreSpec` is added 
* A new value `CUSTOM_TEXT_EMBEDDING` is added to enum `ModelSourceType` 
* A new value `FEATURE_GROUP` is added to enum `EntryType` 
* A new value `FEATURE_ONLINE_STORE` is added to enum `EntryType` 
* A new value `FEATURE_VIEW` is added to enum `EntryType` 
* A new value `GENIE` is added to enum `ModelSourceType` 
* A new value `MARKETPLACE` is added to enum `ModelSourceType` 
#### Documentation

* A comment for field `name` in message `.google.cloud.datacatalog.v1.Entry` is changed 
* A comment for field `name` in message `.google.cloud.datacatalog.v1.EntryGroup` is changed 
* A comment for field `name` in message `.google.cloud.datacatalog.v1.Tag` is changed 
* A comment for field `name` in message `.google.cloud.datacatalog.v1.TagTemplate` is changed 
* A comment for field `name` in message `.google.cloud.datacatalog.v1.TagTemplateField` is changed 

### 1.0.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` 

### 1.0.0 (2024-07-08)

#### Features

* Bump version to 1.0.0 

### 0.23.0 (2024-03-18)

#### Features

* Add range_element_type field to ColumnSchema ([#25383](https://github.com/googleapis/google-cloud-ruby/issues/25383)) 

### 0.22.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24868](https://github.com/googleapis/google-cloud-ruby/issues/24868)) 

### 0.21.2 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.21.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.21.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23777](https://github.com/googleapis/google-cloud-ruby/issues/23777)) 

### 0.20.1 (2024-01-09)

#### Documentation

* Correct documentation of identifier fields ([#23747](https://github.com/googleapis/google-cloud-ruby/issues/23747)) 

### 0.20.0 (2023-09-29)

#### Features

* add dataset_spec and model_spec to Entry and enable vertex AI ingestion to dataplex 

### 0.19.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22918](https://github.com/googleapis/google-cloud-ruby/issues/22918)) 

### 0.18.1 (2023-09-04)

#### Documentation

* fix typo in reference docs ([#22852](https://github.com/googleapis/google-cloud-ruby/issues/22852)) 

### 0.18.0 (2023-08-04)

#### Features

* Support admin_search in SearchCatalog() API ([#22691](https://github.com/googleapis/google-cloud-ruby/issues/22691)) 

### 0.17.0 (2023-07-07)

#### Features

* added rpc RenameTagTemplateFieldEnumValue ([#22481](https://github.com/googleapis/google-cloud-ruby/issues/22481)) 

### 0.16.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.16.0 (2023-05-31)

#### Features

* search_catalog returns the approximate total number of entries matched by the query 
* Support job_id argument to the import_entries call 
* Support project and location arguments to the lookup_entry call 
* Support spanner and bigtable integration ([#21692](https://github.com/googleapis/google-cloud-ruby/issues/21692)) 
* Uses binary protobuf definitions for better forward compatibility 
#### Bug Fixes

* Update timeouts and retry policies 

### 0.15.0 (2023-03-23)

#### Features

* Add support for  a ReconcileTags() API method 
* Add support for entries associated with Looker and CloudSQL 
* Add support for field proto_reference_documentation_uri to proto reference documentation. 
* Add support for new ImportEntries() API, including format of the dump 
* Add support for overrides_by_request_protocol to backend.proto ([#20901](https://github.com/googleapis/google-cloud-ruby/issues/20901)) 
* Add support for SERVICE_NOT_VISIBLE and GCP_SUSPENDED into error reason 

### 0.14.0 (2023-03-08)

#### Features

* Support REST transport ([#20625](https://github.com/googleapis/google-cloud-ruby/issues/20625)) 

### 0.13.0 (2023-02-17)

#### Features

* Include the iam_policy mixin client ([#20454](https://github.com/googleapis/google-cloud-ruby/issues/20454)) 

### 0.12.1 (2022-11-09)

#### Documentation

* update documentation 

### 0.12.0 (2022-07-02)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.11.0 (2022-04-14)

#### Features

* Support for integrating with Dataplex
* Support for update masks when setting IAM policies
* Support for DataCatalog entry name
* Support for detailed storage properties
* Update grpc-google-iam-v1 dependency to 1.1

### 0.10.0 / 2022-02-16

#### Features

* Support for modifications to business context and starring.

### 0.9.1 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.9.0 / 2021-11-11

#### Features

* Return the latest BigQuery shard resource in a table, and the display name and description for search catalog results

### 0.8.3 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.8.2 / 2021-08-23

#### Documentation

* Fix links to the search syntax reference

### 0.8.1 / 2021-08-11

#### Bug Fixes

* Honor client-level timeout configuration

### 0.8.0 / 2021-07-29

#### Features

* Support for the replace_taxonomy call

### 0.7.3 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.7.2 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.7.1 / 2021-04-27

#### Documentation

* Fix formatting in PolicyTagManager documentation

### 0.7.0 / 2021-03-31

#### Features

* Support PolicyTagManager client

### 0.6.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 0.5.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.4.6 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.4.5 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.4.4 / 2020-08-06

#### Bug Fixes

* Fix retry logic by checking the correct numeric error codes

### 0.4.3 / 2020-06-18

#### Documentation

* Add documentation and API enablement links to the readme

### 0.4.2 / 2020-06-08

#### Bug Fixes

* Eliminate a Ruby warning that appeared in some cases when accessing rpc-scoped configs

#### Documentation

* Fixed broken links in the reference documentation

### 0.4.1 / 2020-05-26

#### Bug Fixes

* Removed unused google/cloud/common_resources_pb file

### 0.4.0 / 2020-05-20

#### Features

* The quota_project can be set via configuration

### 0.3.1 / 2020-05-05

#### Documentation

* Clarify that timeouts are in seconds.

### 0.3.0 / 2020-04-20

#### Features

* Support Scope#restricted_locations and SearchCatalogResponse#unreachable

#### Documentation

* Document asia-northeast3 region

### 0.2.0 / 2020-04-13

#### Features

* Support additional path helpers, IAM features, and other updates.
  * Added location_path helper for the DataCatalog service.
  * Added support for IAM policy options.
  * Added support for IAM policy binding conditions.
  * Added support for IAM audit config deltas.
  * Expanded the readme to include quickstart and logging information.
  * Added documentation for package and service modules.
  * Fixed and expanded documentation for the two method calling conventions.
  * Fixed some circular require warnings.

### 0.1.0 / 2020-04-06

* Initial release
