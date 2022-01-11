# Release History

### 1.2.3 / 2022-01-11

#### Documentation

* Fix titles of documentation pages
* Remove some broken images and fix outdated content in authentication documentation

### 1.2.2 / 2021-07-12

#### Documentation

* Clarified some language around authentication configuration

### 1.2.1 / 2021-06-30

#### Bug Fixes

* Expand dependencies to include future 1.x releases of versioned clients

### 1.2.0 / 2021-03-08

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.1.3 / 2021-02-02

#### Documentation

* Clarify the role of main vs versioned clients in the readme

### 1.1.2 / 2021-01-19

#### Documentation

* Timeout config description correctly gives the units as seconds

### 1.1.1 / 2020-05-26

#### Documentation

* Cover exception changes in the migration guide

### 1.1.0 / 2020-05-21

#### Features

* The endpoint, scope, and quota_project can be set via configuration

### 1.0.0 / 2020-05-18

This is a major update with significant new features, improved documentation, and a fair number of breaking changes.

Among the highlights:

* Separate client libraries are now provided for specific service versions.
* A new configuration mechanism makes it easier to control parameters such as endpoint address, network timeouts, and retry.
* A consistent method interface using keyword arguments for all fields, and supporting request proto objects.
* Helper methods for generating resource paths are more accessible.

See the MIGRATING file in the documentation for more detailed information, and instructions for migrating from earlier versions.

### 0.15.0 / 2020-03-18

#### Features

* Support for hybrid DLP jobs
  * Add StorageConfig#hybrid_options field
  * Add DlpServiceClient#finish_dlp_job call
  * Add DlpServiceClient#hybrid_inspect_dlp_job call
  * Add DlpServiceClient#hybrid_inspect_job_trigger call

### 0.14.0 / 2020-03-11

#### Features

* Support separate project setting for quota/billing

### 0.13.2 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 0.13.1 / 2020-01-15

#### Documentation

* Update documentation

### 0.13.0 / 2019-12-18

#### Features

* Add location_id to many operations
* Add Action#publish_to_stackdriver

#### Documentation

* Update documentation

### 0.12.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 0.12.0 / 2019-10-29

This release require Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support auto-discovered credentials

### 0.11.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.11.0 / 2019-07-08

* Add Action#publish_findings_to_cloud_data_catalog
* Support overriding service host and port
* Add AVRO constant to FileType and BytesType

### 0.10.0 / 2019-06-11

* Add StoredInfoTypeVersion#stats (StoredInfoTypeStats)
* Document start_time and end_time in filters
* Add VERSION constant

### 0.9.1 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update documentation for common types.

### 0.9.0 / 2019-04-09

* Update V2::DlpServiceClient:
  * Add Add filter optional argument to list_job_triggers
    * Add ListJobTriggersRequest#filter
  * Add activate_job_trigger
    * Add ActivateJobTriggerRequest
* Update V2 classes:
  * Add InfoTypeDescription#description
  * Add Action#job_notification_emails
    * Add Action::JobNotificationEmails class
  * Add CustomInfoType::Regex#group_indexes
  * Add RecordKey#id_values
  * Add FileType::IMAGE enumerated value
* Add CryptoDeterministicConfig
* Add PrimitiveTransformation#crypto_deterministic_config
* Update documented regex to allow underscores in values for template_id, job_id, trigger_id, and stored_info_type_id
* Extract gRPC header values from request
* Update documentation

### 0.8.0 / 2018-11-15

* Add StoredInfoType CRUD+List access methods:
  * DlpServiceClient#create_stored_info_type
  * DlpServiceClient#get_stored_info_type
  * DlpServiceClient#update_stored_info_type
  * DlpServiceClient#delete_stored_info_type
  * DlpServiceClient#list_stored_info_types
* Add BigQueryOptions#excluded_fields value.
* Add order_by argument to DlpServiceClient#list_dlp_jobs
* Add ListDlpJobsRequest#order_by
* Add CloudStorageOptions::FileSet#regex_file_set
  * Returns newly added CloudStorageRegexFileSet object
* Update documentation.

### 0.7.0 / 2018-10-03

* Add order_by argument to the following methods and resources:
  * DlpServiceClient#list_inspect_templates
  * DlpServiceClient#list_deidentify_templates
  * ListInspectTemplatesRequest#order_by
  * ListDeidentifyTemplatesRequest#order_by
  * ListStoredInfoTypesRequest#order_by
* Add InspectConfig#rule_set
  * Add InspectionRuleSet, InspectionRule, ExclusionRule,
    ExcludeInfoTypes, and MatchingType resources.
* Add CustomInfoType#exclusion_type
  * Add ExclusionType resource.
* Update documentation.
* Add new GAPIC config, which is not yet used.

### 0.6.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.6.1 / 2018-09-10

* Update documentation.

### 0.6.0 / 2018-08-21

* Update V2 API.
* Update documentation.

### 0.5.0 / 2018-07-10

* Documentation updates
* Credentials env_vars change

### 0.4.0 / 2018-4-26

* Documentation updates
* row_limit, cscc action
* Dictionaries via GCS
* Entity id in risk stats

### 0.3.0 / 2018-4-11

* Documentation updates
* New IMAGE type

### 0.2.0 / 2018-3-16

* Refreshed alpha release for V2 API compatibility

### 0.1.0 / 2017-12-26

* Initial release
