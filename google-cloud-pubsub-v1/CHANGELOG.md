# Release History

### 1.8.0 (2025-03-11)

#### Features

* deprecate `enabled` field for message transforms and add `disabled` field ([#29306](https://github.com/googleapis/google-cloud-ruby/issues/29306)) 

### 1.7.1 (2025-02-05)

#### Documentation

* Fixed some documentation formatting ([#28914](https://github.com/googleapis/google-cloud-ruby/issues/28914)) 

### 1.7.0 (2025-01-31)

#### Features

* Added support for message transforms to Topic and Subscription ([#28801](https://github.com/googleapis/google-cloud-ruby/issues/28801)) 

### 1.6.0 (2025-01-28)

#### Features

* Update Ruby version requirement to 3.0 
#### Documentation

* Clarify behavior of protobuf message fields that are part of mutually-exclusive sets 
* Include note about validating externally-provided credentials 

### 1.5.0 (2025-01-15)

#### Features

* Add Kafka-based sources to IngestionDataSourceSettings proto and IngestionFailureEvent proto ([#28200](https://github.com/googleapis/google-cloud-ruby/issues/28200)) 

### 1.4.0 (2024-12-10)

#### Features

* Provide opt-in debug logging 

### 1.3.0 (2024-10-15)

#### Features

* Support for the IngestionFailureEvent type ([#27430](https://github.com/googleapis/google-cloud-ruby/issues/27430)) 

### 1.2.0 (2024-09-30)

#### Features

* Support for Analytics Hub subscription info 
* Support for Cloud Storage and platform logs settings in IngestionDataSourceSettings 

### 1.1.2 (2024-09-11)

#### Documentation

* Update documentation to note new maximum 31 day subscription message retention ([#27306](https://github.com/googleapis/google-cloud-ruby/issues/27306)) 

### 1.1.1 (2024-08-30)

#### Documentation

* Add field `experimental_features` to message `PythonSettings` ([#27011](https://github.com/googleapis/google-cloud-ruby/issues/27011)) 

### 1.1.0 (2024-07-25)

#### Features

* Added CloudStorageConfig#max_messages ([#26456](https://github.com/googleapis/google-cloud-ruby/issues/26456)) 

### 1.0.0 (2024-07-09)

#### Features

* Bump version to 1.0.0 

### 0.25.0 (2024-06-26)

#### Features

* Support use_topic_schema in Cloud Storage Subscriptions ([#26139](https://github.com/googleapis/google-cloud-ruby/issues/26139)) 

### 0.24.0 (2024-05-31)

#### Features

* Support service account email for export subscriptions ([#26009](https://github.com/googleapis/google-cloud-ruby/issues/26009)) 

### 0.23.0 (2024-04-15)

#### Features

* add custom datetime format for Cloud Storage subscriptions ([#25438](https://github.com/googleapis/google-cloud-ruby/issues/25438)) 

### 0.22.0 (2024-02-26)

#### Features

* Updated minimum Ruby version to 2.7 ([#24875](https://github.com/googleapis/google-cloud-ruby/issues/24875)) 

### 0.21.2 (2024-02-16)

#### Documentation

* Fixes in Pub/Sub ingestion comments ([#24818](https://github.com/googleapis/google-cloud-ruby/issues/24818)) 

### 0.21.1 (2024-02-01)

#### Bug Fixes

* Eliminated a harmless but annoying warning in the protobuf class files 

### 0.21.0 (2024-01-25)

#### Features

* add ingestion_data_source_settings field to Topic 
* add state field to Topic 
* Added enforce_in_transit flag in the message storage policy ([#24470](https://github.com/googleapis/google-cloud-ruby/issues/24470)) 

### 0.20.2 (2024-01-19)

#### Bug Fixes

* Fix universe_domain and endpoint compatibility in deprecated embedded IAM client ([#24446](https://github.com/googleapis/google-cloud-ruby/issues/24446)) 

### 0.20.1 (2024-01-12)

#### Bug Fixes

* Ensure endpoints are correct for mixin clients ([#24032](https://github.com/googleapis/google-cloud-ruby/issues/24032)) 

### 0.20.0 (2024-01-11)

#### Features

* Support for universe_domain ([#23783](https://github.com/googleapis/google-cloud-ruby/issues/23783)) 
#### Bug Fixes

* Subscriber and publisher configs honor the base default configs from the high-level pubsub client ([#23796](https://github.com/googleapis/google-cloud-ruby/issues/23796)) 

### 0.19.0 (2023-12-08)

#### Features

* Added use_table_schema field to BigQueryConfig ([#23582](https://github.com/googleapis/google-cloud-ruby/issues/23582)) 

### 0.18.1 (2023-10-23)

#### Documentation

* Update some reference docs ([#23444](https://github.com/googleapis/google-cloud-ruby/issues/23444)) 

### 0.18.0 (2023-09-12)

#### Features

* Support for channel pool configuration ([#22922](https://github.com/googleapis/google-cloud-ruby/issues/22922)) 

### 0.17.4 (2023-09-04)

#### Bug Fixes

* Adjust retry delays for the publish and streaming_pull calls ([#22799](https://github.com/googleapis/google-cloud-ruby/issues/22799)) 

### 0.17.3 (2023-07-28)

#### Documentation

* clarified where ordering_key will be written if write_metadata is set ([#22601](https://github.com/googleapis/google-cloud-ruby/issues/22601)) 

### 0.17.2 (2023-06-27)

#### Documentation

* Clarify naming pattern for Storage's filename suffix ([#22451](https://github.com/googleapis/google-cloud-ruby/issues/22451)) 

### 0.17.1 (2023-06-06)

#### Bug Fixes

* Don't use self-signed JWT credentials if the global configuration endpoint has been modified 

### 0.17.0 (2023-05-31)

#### Features

* Support for pushing JSON representations of a PubsubMessage to a push endpoint ([#21687](https://github.com/googleapis/google-cloud-ruby/issues/21687)) 
* Uses binary protobuf definitions for better forward compatibility 

### 0.16.0 (2023-05-18)

#### Features

* add cloud storage subscription fields ([#21576](https://github.com/googleapis/google-cloud-ruby/issues/21576)) 

### 0.15.1 (2023-02-23)

#### Documentation

* Minor updates ([#20492](https://github.com/googleapis/google-cloud-ruby/issues/20492)) 

### 0.15.0 (2023-02-17)

#### Features

* ModifyAckDeadlineConfirmation includes a list of ack IDs that failed with temporary issues ([#20445](https://github.com/googleapis/google-cloud-ruby/issues/20445)) 
#### Bug Fixes

* Make INTERNAL a retryable error for the pull RPC 

### 0.14.0 (2023-02-16)

#### Features

* AcknowledgeConfirmation includes a list of ack IDs that failed with temporary issues ([#20431](https://github.com/googleapis/google-cloud-ruby/issues/20431)) 
#### Documentation

* Various fixes and clarifications in reference documentation 

### 0.13.1 (2023-02-13)

#### Documentation

* Deprecated the revision_id parameter to commit_schema_revision and delete_schema_revision ([#20139](https://github.com/googleapis/google-cloud-ruby/issues/20139)) 

### 0.13.0 (2023-01-12)

#### Features

* Added support for schema evolution, including managing schema revisions, and schema commit and rollback ([#19981](https://github.com/googleapis/google-cloud-ruby/issues/19981)) 

### 0.12.1 (2023-01-05)

#### Documentation

* Update some reference documents ([#19901](https://github.com/googleapis/google-cloud-ruby/issues/19901)) 

### 0.12.0 (2022-10-21)

#### Features

* Provide easier access to IAM functionality via the standard IAMPolicy client class ([#19315](https://github.com/googleapis/google-cloud-ruby/issues/19315)) 

### 0.11.0 (2022-07-07)

#### Features

* Updated minimum Ruby version to 2.6 ([#18443](https://github.com/googleapis/google-cloud-ruby/issues/18443)) 

### 0.10.0 (2022-05-19)

#### Features

* add BigQuery configuration and state for Subscriptions

### 0.9.0 (2022-04-20)

#### Features

* Support for update masks when setting IAM policies

### 0.8.0 / 2022-04-01

#### Features

* increase GRPC max metadata size to 4 MB

### 0.7.1 / 2022-02-15

#### Bug Fixes

* Fix misspelled field name StreamingPullResponse#acknowledge_confirmation (was acknowlege_confirmation)

### 0.7.0 / 2022-02-08

#### Features

* Support acknowledgment confirmations when exactly-once delivery is enabled
* Support exactly-once delivery when creating a subscription

### 0.6.2 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 0.6.1 / 2021-11-08

#### Documentation

* Added simple code snippets to RPC method documentation

### 0.6.0 / 2021-08-11

#### Features

* Support setting message retention duration on a topic

#### Bug Fixes

* Honor client-level timeout configuration

### 0.5.2 / 2021-07-12

#### Documentation

* Clarify some language around authentication configuration

### 0.5.1 / 2021-07-08

#### Bug Fixes

* Removed a proto file that is duplicated from the iam-v1 gem

### 0.5.0 / 2021-07-07

#### Features

* Add subscription properties to streaming pull response

### 0.4.1 / 2021-06-17

#### Bug Fixes

* Support future 1.x versions of gapic-common

### 0.4.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

#### Documentation

* Remove experimental note for schema APIs

### 0.3.0 / 2021-02-02

#### Features

* Use self-signed JWT credentials when possible

### 0.2.1 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds.

### 0.2.0 / 2021-01-05

#### Features

* add schema service ([#8413](https://www.github.com/googleapis/google-cloud-ruby/issues/8413))

### 0.1.2 / 2020-08-10

#### Bug Fixes

* Allow special symbolic credentials in client configs

### 0.1.1 / 2020-08-05

#### Bug Fixes

* Fix retries by converting error names to integer codes

#### Documentation

* Remove experimental warning for ordering keys properties

### 0.1.0 / 2020-07-27

Initial release.
