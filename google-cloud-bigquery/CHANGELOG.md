# Release History

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
