# Release History

### 1.44.2 (2023-09-12)

#### Bug Fixes

* Avoid dataset reload when accessing location ([#22905](https://github.com/googleapis/google-cloud-ruby/issues/22905)) 

### 1.44.1 (2023-09-08)

#### Bug Fixes

* remove unnecessary warning ([#22904](https://github.com/googleapis/google-cloud-ruby/issues/22904)) 

### 1.44.0 (2023-09-04)

#### Features

* support BIGQUERY_EMULATOR_HOST env variable for endpoint 

### 1.43.1 (2023-05-19)

#### Bug Fixes

* ensure schema for data parsing ([#21616](https://github.com/googleapis/google-cloud-ruby/issues/21616)) 

### 1.43.0 (2023-05-10)

#### Features

* Added support for default value expression ([#21540](https://github.com/googleapis/google-cloud-ruby/issues/21540)) 

### 1.42.0 (2023-01-15)

#### Features

* Added support for authorized dataset ([#19442](https://github.com/googleapis/google-cloud-ruby/issues/19442)) 
* Added support for tags in dataset ([#19350](https://github.com/googleapis/google-cloud-ruby/issues/19350)) 

### 1.41.0 (2023-01-05)

#### Features

* Add support for partial projection of table metadata 
#### Bug Fixes

* Fix querying of array of structs in named parameters ([#19466](https://github.com/googleapis/google-cloud-ruby/issues/19466)) 

### 1.40.0 (2022-12-14)

#### Features

* support table snapshot and clone ([#19354](https://github.com/googleapis/google-cloud-ruby/issues/19354)) 

### 1.39.0 (2022-07-27)

#### Features

* Update minimum Ruby version to 2.6 ([#18871](https://github.com/googleapis/google-cloud-ruby/issues/18871)) 

### 1.38.1 / 2022-01-13

#### Bug Fixes

* Update Bigquery::Data#ddl? to support ALTER TABLE
* Update Bigquery::QueryJob#ddl? to support ALTER TABLE
* Remove newline character ('\n') from #ddl? statement types

#### Documentation

* Update Contributing docs

### 1.38.0 / 2021-11-16

#### Features

* Add session support
  * Add create_session and session_id params to Project#query_job
  * Add create_session and session_id params to Dataset#query_job
  * Add session_id param to Project#query
  * Add session_id param to Dataset#query
  * Add Job#session_id
  * Add QueryJob::Updater#create_session=
  * Add QueryJob::Updater#session_id=

### 1.37.0 / 2021-10-21

#### Features

* Add support for Avro options to external data sources
  * Add External::AvroSource

### 1.36.0 / 2021-09-22

#### Features

* Add Job#delete

#### Bug Fixes

* Add precision and scale to Field#add_field

### 1.35.1 / 2021-09-14

#### Documentation

* Wrap character class regex in backticks

### 1.35.0 / 2021-08-12

#### Features

* Add GEOGRAPHY schema helpers
  * Add LoadJob#geography
  * Add Schema::Field#geography
  * Add Table::Updater#geography
* Add support for GEOGRAPHY type
  * Add Schema#geography
* Add support for multistatement transaction statistics in jobs
  * Add Job#transaction_id

### 1.34.0 / 2021-07-20

#### Features

* Add DmlStatistics
  * Add QueryJob#deleted_row_count
  * Add QueryJob#inserted_row_count
  * Add QueryJob#updated_row_count
  * Add Data#deleted_row_count
  * Add Data#inserted_row_count
  * Add Data#updated_row_count

### 1.33.0 / 2021-07-14

#### Features

* Add policy tag support (Column ACLs)
  * Add policy_tags to LoadJob field helper methods
  * Add policy_tags to Schema field helper methods
  * Add policy_tags to Schema::Field field helper methods
  * Add policy_tags to Table field helper methods
  * Add Schema::Field#policy_tags
  * Add Schema::Field#policy_tags=
* Add support for parameterized types
  * Add max_length to LoadJob::Updater#bytes
  * Add max_length to LoadJob::Updater#string
  * Add max_length to Schema#bytes
  * Add max_length to Schema#string
  * Add max_length to Schema::Field#bytes
  * Add max_length to Schema::Field#string
  * Add max_length to Table::Updater#bytes
  * Add max_length to Table::Updater#string
  * Add precision and scale to LoadJob::Updater#bignumeric
  * Add precision and scale to LoadJob::Updater#numeric
  * Add precision and scale to Schema#bignumeric
  * Add precision and scale to Schema#numeric
  * Add precision and scale to Schema::Field#bignumeric
  * Add precision and scale to Schema::Field#numeric
  * Add precision and scale to Table::Updater#bignumeric
  * Add precision and scale to Table::Updater#numeric
  * Add Schema::Field#max_length
  * Add Schema::Field#precision
  * Add Schema::Field#scale

### 1.32.1 / 2021-07-08

#### Documentation

* Update AUTHENTICATION.md in handwritten packages

### 1.32.0 / 2021-06-21

#### Features

* Add support for Parquet options
  * feat(bigquery): Add Bigquery::External::ParquetSource
  * Add Parquet options to LoadJob
    * Add LoadJob#parquet_options?
    * Add LoadJob#parquet_enable_list_inference?
    * Add LoadJob#parquet_enum_as_string?
    * Add LoadJob::Updater#parquet_enable_list_inference=
    * Add LoadJob::Updater#parquet_enum_as_string=

#### Bug Fixes

* Expand googleauth dependency to support future 1.x versions

### 1.31.0 / 2021-04-28

#### Features

* Add support for mutable clustering configuration
  * Add Table#clustering_fields=

### 1.30.0 / 2021-04-20

#### Features

* Add support for BIGNUMERIC data type
  * Add support for BIGNUMERIC data insert.
  * Add support for BIGNUMERIC query params.
  * Add #bignumeric to Schema, Table, LoadJob::Updater and Field.
  * Update types tables in docs.

#### Bug Fixes

* Fix Table#time_partitioning_expiration=
  * Accept nil argument.

### 1.29.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.28.0 / 2021-03-09

#### Features

* Add Materialized View support
  * Add Dataset#create_materialized_view
  * Add Table#materialized_view?
  * Add Table#enable_refresh?
  * Add Table#enable_refresh=
  * Add Table#last_refresh_time
  * Add Table#refresh_interval_ms
  * Add Table#refresh_interval_ms=

### 1.27.0 / 2021-02-10

#### Features

* Add Job#reservation_usage
* Add Routine#determinism_level
  * Add Routine#determinism_level
  * Add Routine#determinism_level=
  * Add Routine#determinism_level_deterministic?
  * Add Routine#determinism_level_not_deterministic?
  * Add Routine::Updater#determinism_level=

### 1.26.0 / 2021-01-13

#### Features

* Add support for Hive Partitioning
  * Add hive partitioning options to External::DataSource
  * Add hive partitioning options to LoadJob and LoadJob::Updater
* Replace google-api-client with google-apis-bigquery_v2

### 1.25.0 / 2020-11-16

#### Features

* Add routine (UDF) to Dataset::Access
* Add support for Table ACLS (IAM Policy)
  * feat(bigquery): Add support for Table ACLS
  * Add Bigquery::Policy
  * Add Table#policy
  * Add Table#test_iam_permissions
  * Add Table#update_policy

### 1.24.0 / 2020-10-29

#### Features

* Add iamMember to Dataset::Access

#### Bug Fixes

* Ensure dense encoding of JSON responses
  * Set query param prettyPrint=false for all requests.
  * Upgrade google-api-client to ~> 0.47

#### Documentation

* Update supported types for time partition type

### 1.23.0 / 2020-09-17

#### Features

* quota_project can be set via library configuration ([#7627](https://www.github.com/googleapis/google-cloud-ruby/issues/7627))

### 1.22.0 / 2020-09-10

#### Features

* Add support for ML model export
  * Add model support to Project#extract and #extract_job
  * Add ExtractJob#model?
  * Add ExtractJob#ml_tf_saved_model?
  * Add ExtractJob#ml_xgboost_booster?
  * Add Model#extract and #extract_job

### 1.21.2 / 2020-07-21

#### Documentation

* Update Data#each samples

### 1.21.1 / 2020-05-28

#### Documentation

* Fix a few broken links

### 1.21.0 / 2020-03-31

#### Features

* Add Job#parent_job_id and Job#script_statistics
  * Add parent_job to Project#jobs
  * Add Job#num_child_jobs
  * Add Job#parent_job_id
  * Add Job#script_statistics

### 1.20.0 / 2020-03-11

#### Features

* Add Range Partitioning
  * Add range partitioning methods to Table and Table::Updater
  * Add range partitioning methods to LoadJob
  * Add range partitioning methods to QueryJob

### 1.19.0 / 2020-02-11

#### Features

* Add Routine
  * Add Dataset#create_routine
  * Add Argument
  * Update StandardSql classes to expose public initializer
  * Add Data#ddl_target_routine and QueryJob#ddl_target_routine
* Allow row inserts to skip insert_id generation
  * Streaming inserts using an insert_id are not able to be inserted as fast as inserts without an insert_id
  * Add the ability for users to skip insert_id generation in order to speed up the inserts
  * The default behavior continues to generate insert_id values for each row inserted
  * Add yield documentation for Dataset#insert

### 1.18.1 / 2019-12-18

#### Bug Fixes

* Fix MonitorMixin usage on Ruby 2.7
  * Ruby 2.7 will error if new_cond is called before super().
  * Make the call to super() be the first call in initialize

### 1.18.0 / 2019-11-06

#### Features

* Add optional query parameter types
  * Allow query parameters to be nil/NULL when providing an optional
  * Add types argument to the following methods:
    * Project#query
    * Project#query_job
    * Dataset#query
    * Dataset#query_job
* Add param types helper methods
  * Return the BigQuery field type code, using the same format as the
  * Add Schema::Field#param_type
  * Add Schema#param_types
  * Add Data#param_types
  * Add Table#param_types
  * Add External::CvsSource#param_types
  * Add External::JsonSource#param_types
* Add support for all_users special role in Dataset access

### 1.17.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform environments support automatic authentication

### 1.16.0 / 2019-10-03

#### Features

* Add Dataset default_encryption
  * Add Dataset#default_encryption
  * Add Dataset#default_encryption=

### 1.15.0 / 2019-09-30

#### Features

* Add Model encryption
  * Add Model#encryption
  * Add Model#encryption=
* Add range support for Google Sheets
  * Add External::SheetsSource#range
  * Add External::SheetsSource#range=
* Support use_avro_logical_types on extract jobs
  * Add ExtractJob#use_avro_logical_types?
  * Add ExtractJob::Updater#use_avro_logical_types=

### 1.14.1 / 2019-09-04

#### Documentation

* Add note about streaming insert issues
  * Acknowledge tradeoffs when inserting rows soon after
    table metadata has been changed.
  * Add link to BigQuery Troubleshooting guide.

### 1.14.0 / 2019-08-23

#### Features

* Support overriding of service endpoint

#### Performance Improvements

* Use MiniMime to detect content types

#### Documentation

* Update documentation

### 1.13.0 / 2019-07-31

* Add Table#require_partition_filter
* List jobs using min and max created_at
* Reduce thread usage at startup
  * Allocate threads in pool as needed, not all up front
* Update documentation links

### 1.12.0 / 2019-07-10

* Add BigQuery Model API
  * Add Model
  * Add StandardSql Field, DataType, StructType
  * Add Dataset#model and Dataset#models
* Correct Float value conversion
  * Ensure that NaN, Infinity, and -Infinity are converted correctly.

### 1.11.2 / 2019-06-11

* Update "Loading data" link

### 1.11.1 / 2019-05-21

* Declare explicit dependency on mime-types

### 1.11.0 / 2019-02-01

* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.

### 1.10.0 / 2018-12-06

* Add dryrun param to Project#query_job and Dataset#query_job
* Add copy and extract methods to Project
  * Add Project#extract and Project#extract_job
  * Add Project#copy and Project#copy_job
  * Deprecate dryrun param in Table#copy_job, Table#extract_job and
    Table#load_job
* Fix memoization in Dataset#exists? and Table#exists?
  * Add force param to Dataset#exists? and Table#exists?

### 1.9.0 / 2018-10-25

* Add clustering fields to LoadJob, QueryJob and Table
* Add DDL/DML support
  * Update QueryJob#data to not return table rows for DDL/DML
  * Add DDL/DML statistics attrs to QueryJob and Data
* Add #numeric to Table::Updater and LoadJob::Updater (@leklund)

### 1.8.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 1.8.1 / 2018-09-12

* Add missing documentation files to package.

### 1.8.0 / 2018-09-10

* Add support for OCR format.
* Update documentation.

### 1.7.1 / 2018-08-21

* Update documentation.

### 1.7.0 / 2018-06-29

* Add #schema_update_options to LoadJob and #schema_update_options= to LoadJob::Updater.
* Add time partitioning for the target table to LoadJob and QueryJob.
* Add #statement_type, #ddl_operation_performed, #ddl_target_table to QueryJob.

### 1.6.0 / 2018-06-22

* Documentation updates.
* Updated dependencies.

### 1.5.0 / 2018-05-21

* Add Schema.load and Schema.dump to read/write a table schema from/to a JSON file or other IO source. The JSON file schema is the same as for the bq CLI.
* Add support for the NUMERIC data type.
* Add documentation for enabling logging.

### 1.4.0 / 2018-05-07

* Add Parquet support to #load and #load_job.

### 1.3.0 / 2018-04-05

* Add insert_ids option to #insert in Dataset, Table, and AsyncInserter.
* Add BigQuery Project#service_account_email.
* Add support for setting Job location to nil in blocks for Job properties.

### 1.2.0 / 2018-03-31

* Add geo-regionalization (location) support to Jobs.
* Add Project#encryption support to Jobs.
* Rename Encryption to EncryptionConfiguration.
* Add blocks for setting Job properties to all Job creation methods.
* Add support for lists of URLs to #load and #load_job. (jeremywadsack)
* Fix Schema::Field type helpers.
* Fix Table#load example in README.

### 1.1.0 / 2018-02-27

* Support table partitioning by field.
* Support Shared Configuration.
* Improve AsyncInserter performance.

### 1.0.0 / 2018-01-10

* Release 1.0.0
* Update authentication documentation
  * Update Data documentation and code examples
  * Remove reference to sync and async queries
* Allow use of URI objects for Dataset#load, Table#load, and Table#load_job

### 0.30.0 / 2017-11-14

* Add `Google::Cloud::Bigquery::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Support creating `Dataset` and `Table` objects without making API calls using
  `skip_lookup` argument.
  * Add `Dataset#reference?` and `Dataset#resource?` helper method.
  * Add `Table#reference?` and `Table#resource?` and `Table#resource_partial?`
    and `Table#resource_full?` helper methods.
* `Dataset#insert_async` and `Dataset#insert_async` now yields a
  `Table::AsyncInserter::Result` object.
* `View` is removed, now uses `Table` class.
  * Needed to support `skip_lookup` argument.
  * Calling `Table#data` on a view now raises (breaking change).
* Performance improvements for queries.
* Updated `google-api-client`, `googleauth` dependencies.

### 0.29.0 / 2017-10-09

This is a major release with many new features and several breaking changes.

#### Major Changes

* All queries now use a new implementation, using a job and polling for results.
* The copy, load, extract methods now all have high-level and low-level versions, similar to `query` and `query_job`.
* Added asynchronous row insertion, allowing data to be collected and inserted in batches.
* Support external data sources for both queries and table views.
* Added create-on-insert support for tables.
* Allow for customizing job IDs to aid in organizing jobs.

#### Change Details

* Update high-level queries as follows:
  * Update `QueryJob#wait_until_done!` to use `getQueryResults`.
  * Update `Project#query` and `Dataset#query` with breaking changes:
    * Remove `timeout` and `dryrun` parameters.
    * Change return type from `QueryData` to `Data`.
  * Add `QueryJob#data`
  * Alias `QueryJob#query_results` to `QueryJob#data` with breaking changes:
    * Remove the `timeout` parameter.
    * Change the return type from `QueryData` to `Data`.
  * Update `View#data` with breaking changes:
    * Remove the `timeout` and `dryrun` parameters.
    * Change the return type from `QueryData` to `Data`.
  * Remove `QueryData`.
  * Update `Project#query` and `Dataset#query` with improved errors, replacing the previous simple error with one that contains all available information for why the job failed.
* Rename `Dataset#load` to `Dataset#load_job`; add high-level, synchronous version as `Dataset#load`.
* Rename `Table#copy` to `Table#copy_job`; add high-level, synchronous version as `Table#copy`.
* Rename `Table#extract` to `Table#extract_job`; add high-level, synchronous version as `Table#extract`.
* Rename `Table#load` to `Table#load_job`; add high-level, synchronous version as `Table#load`.
* Add support for querying external data sources with `External`.
* Add `Table::AsyncInserter`, `Dataset#insert_async` and `Table#insert_async` to collect and insert rows in batches.
* Add `Dataset#insert` to support creating a table while inserting rows if the table does not exist.
* Update retry logic to conform to the [BigQuery SLA](https://cloud.google.com/bigquery/sla).
  * Use a minimum back-off interval of 1 second; for each consecutive error, increase the back-off interval exponentially up to 32 seconds.
  * Retry if all error reasons are retriable, not if any of the error reasons are retriable.
* Add support for labels to `Dataset`, `Table`, `View` and `Job`.
  * Add `filter` option to `Project#datasets` and `Project#jobs`.
* Add support for user-defined functions to `Project#query_job`, `Dataset#query_job`, `QueryJob` and `View`.
* In `Dataset`, `Table`, and `View` updates, add the use of ETags for optimistic concurrency control.
* Update `Dataset#load` and `Table#load`:
  * Add `null_marker` option and `LoadJob#null_marker`.
  * Add `autodetect` option and `LoadJob#autodetect?`.
* Fix the default value for `LoadJob#quoted_newlines?`.
* Add `job_id` and `prefix` options for controlling client-side job ID generation to `Project#query_job`, `Dataset#load`, `Dataset#query_job`, `Table#copy`, `Table#extract`, and `Table#load`.
* Add `Job#user_email`.
* Set the maximum delay of `Job#wait_until_done!` polling to 60 seconds.
* Automatically retry `Job#cancel`.
* Allow users to specify if a `View` query is using Standard vs. Legacy SQL.
* Add `project` option to `Project#query_job`.
* Add `QueryJob#query_plan`, `QueryJob::Stage` and `QueryJob::Step` to expose query plan information.
* Add `Table#buffer_bytes`, `Table#buffer_rows` and `Table#buffer_oldest_at` to expose streaming buffer information.
* Update `Dataset#insert` and `Table#insert` to raise an error if `rows` is empty.
* Update `Error` with a mapping from code 412 to `FailedPreconditionError`.
* Update `Data#schema` to freeze the returned `Schema` object (as in `View` and `LoadJob`.)

### 0.28.0 / 2017-09-28

* Update Google API Client dependency to 0.14.x.

### 0.27.1 / 2017-07-11

* Add `InsertResponse::InsertError#index` (zedalaye)

### 0.27.0 / 2017-06-28

* Add `maximum_billing_tier` and `maximum_bytes_billed` to `QueryJob`, `Project#query_job` and `Dataset#query_job`.
* Add `Dataset#load` to support creating, configuring and loading a table in one API call.
* Add `Project#schema`.
* Upgrade dependency on Google API Client.
* Update gem spec homepage links.
* Update examples of field access to use symbols instead of strings in the documentation.

### 0.26.0 / 2017-04-05

* Upgrade dependency on Google API Client

### 0.25.0 / 2017-03-31

* Add `#cancel` to `Job`
* Updated documentation

### 0.24.0 / 2017-03-03

Major release, several new features, some breaking changes.

* Standard SQL is now the default syntax.
* Legacy SQL syntax can be enabled by providing `legacy_sql: true`.
* Several fixes to how data values are formatted when returned from BigQuery.
* Returned data rows are now hashes with Symbol keys instead of String keys.
* Several fixes to how data values are formatted when importing to BigQuery.
* Several improvements to manipulating table schema fields.
* Removal of `Schema#fields=` and `Data#raw` methods.
* Removal of `fields` argument from `Dataset#create_table` method.
* Dependency on Google API Client has been updated to 0.10.x.

### 0.23.0 / 2016-12-8

* Support Query Parameters using `params` method arguments to `query` and `query_job`
* Add `standard_sql`/`legacy_sql` method arguments to to `query` and `query_job`
* Add `standard_sql?`/`legacy_sql?` attributes to `QueryJob`
* Many documentation improvements

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Bigquery.new

### 0.20.2 / 2016-09-30

* Add list of projects that the current credentials can access. (remi)

### 0.20.1 / 2016-09-02

* Fix for timeout on uploads.

### 0.20.0 / 2016-08-26

This gem contains the Google BigQuery service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
