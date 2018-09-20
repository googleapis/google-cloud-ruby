# Release History

### 0.23.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.23.2 / 2018-09-12

* Add missing documentation files to package.

### 0.23.1 / 2018-09-10

* Update documentation.

### 0.23.0 / 2016-12-8

* Update dependency on `google-cloud` gem to 0.23 or greater.

### 0.22.0 / 2016-11-14

* Update dependency on `google-cloud` gem to 0.22.x

### 0.21.0 / 2016-10-20

* Update dependency on `google-cloud` gem to 0.21.x

### 0.20.0 / 2016-08-26

This gem is now an alias for the newly released `google-cloud` gem. Legacy code can continue to use the `Gcloud` constant, which is now an alias to `Google::Cloud`.

* The old namespace `Gcloud` is an alias of `Google::Cloud`
* The old require paths are supported and will require the new gems

### 0.12.2 / 2016-08-09

#### Changes

* BigQuery
  * Allow `Dataset#create_table` syntax used prior to v0.12.0.

### 0.12.1 / 2016-08-01

#### Changes

* Datastore
  * Change `Datastore#next?` to use `NOT_FINISHED` (timanovsky)
* Pub/Sub
  * Fix bug in pull timeout (mpcm)
* Minor code cleanup and acceptance testing changes

### 0.12.0 / 2016-07-25

In addition to upgrading the `google-api-client` dependency to the latest version (a significant change in the HTTP stack), this release makes a number of small, breaking changes in anticipation of gcloud-ruby `1.0`.

#### Changes

* Core
  * Upgrade Google API Client dependency to `0.9`
  * Upgrade gRPC dependency to `1.0.0.pre1`
  * Add optional arguments `retries` and `timeout` to service factories
  * Remove `Gcloud::Error#inner`, use `#cause` instead
  * Remove `Gcloud::Backoff`
  * Remove `Gcloud::Upload`
* BigQuery
  * Replace `Bigquery::Error` and `Bigquery::ApiError` classes with `Gcloud::Error` classes
  * Update `Dataset#access` to return a frozen `Dataset::Access` object (was array of hashes)
  * Remove `Dataset#access=`, use `Dataset#access` with a block to make changes
  * Update `Dataset#create_table` method
    * Remove `schema` optional argument
    * Add `fields` optional argument
    * Yield `Table::Updater` instead of `Table::Schema`
  * Remove erroneous `Dataset::Access` methods
    * `Dataset::Access#add_owner_view`
    * `Dataset::Access#add_writer_view`
    * `Dataset::Access#remove_writer_view`
    * `Dataset::Access#remove_owner_view`
    * `Dataset::Access#writer_view?`
    * `Dataset::Access#owner_view?`
  * Remove erroneous `Job::List#total` accessor
  * Remove erroneous `Project#access` method
  * Move `Table::Schema` to `Schema`
  * Update `Table#schema` to return a frozen `Schema` object (was hash)
  * Remove `Table#schema=`, use `Table#schema` with a block to make changes
  * Add `Schema::Field`
  * Add `View#id` and `#query_id` methods, to match `Table`
  * Add `Dataset::Updater` class
  * Add `Table::Updater` class
  * Remove `Table#load` optional argument `chunk_size`
* Datastore
  * Replace `Datastore::Error` and `Datastore::KeyfileError` classes with `Gcloud::Error` classes
  * Add `KeyError` class
  * Remove `TransactionError#commit_error` and `#transaction_error` methods, use `#cause` instead
  * Add `Entity#serialized_size` method
  * Add `Key#serialized_size` method
  * Update documentation for emulator (pcostell)
* DNS
  * Replace `Dns::Error` and `Dns::ApiError` classes with `Gcloud::Error` classes
* Logging
  * Update `Project#entry` with convenient optional arguments
  * Add `Entry#resource=` method
  * Add `Entry` severity convenience methods
    * `Entry#default!`
    * `Entry#debug!`
    * `Entry#info!`
    * `Entry#notice!`
    * `Entry#warning!`
    * `Entry#error!`
    * `Entry#critical!`
    * `Entry#alert!`
    * `Entry#emergency!`
* Pub/Sub
  * Add `Policy` class
  * Update `Topic#policy` to yield a `Policy` object to be updated
  * Update `Topic#policy`/`#policy=` to return/receive `Policy` object (was hash)
  * Update `Subscription#policy` to yield a `Policy` object to be updated
  * Update `Subscription#policy`/`#policy=` to return/receive `Policy` object (was hash)
  * Rename `Topic::Batch` to `Topic::Publisher`
* Resource Manager
  * Upgrade to `V1` API
  * Add `Policy` class
  * Update `Project#policy` to yield a `Policy` object to be updated
  * Update `Project#policy`/`#policy=` to return/receive `Policy` object (was hash)
* Storage
  * Replace `Storage::Error` and `Storage::ApiError` classes with `Gcloud::Error` classes
  * Update `Project#create_bucket`
    * Yield `Bucket::Updater` object instead of a `Bucket::Cors` object
    * Remove `cors` optional argument
  * Remove `Bucket#create_file` optional argument `chunk_size`
  * Remove `Bucket#cors=`, use `Bucket#cors` with a block to make changes
  * Add `Bucket::Cors::Rule` class
  * Remove erroneous `Bucket::DefaultAcl` methods
    * `Bucket::DefaultAcl#writers`
    * `Bucket::DefaultAcl#add_writer`
  * Remove erroneous `File::Acl` methods
    * `File::Acl#writers`
    * `File::Acl#add_writer`
* Translate
  * Replace `Translate::Error` and `Translate::ApiError` classes with `Gcloud::Error` classes
* Vision
  * Replace `Vision::Error` and `Vision::ApiError` classes with `Gcloud::Error` classes


### 0.11.0 / 2016-06-13

#### Changes

* Add backoff to all requests (dolzenko)
* BigQuery
  * Add `#all` to `Data`
  * Add `#all`, `#next` and `#next?` to `Dataset::List`, `Job::List`,
    `QueryData`, `Table::List` and `Dataset::LookupResults`
  * `#all` methods now return lazy enumerator with `request_limit`
* Datastore
  * Add `#cursor_for`, `#each_with_cursor` and `#all_with_cursor` to
    `Dataset::QueryResults`
  * `#all` and `#all_with_cursor` methods now return lazy enumerator with
    `request_limit`
* DNS
  * Add `#all` to `Change::List` and  `Zone::List`
  * `#all` methods now return lazy enumerator with `request_limit`
* Logging
  * `#all` methods now return lazy enumerator with `request_limit`
* Pub/Sub
  * Fix bug when publishing multi-byte strings
  * Add support for IO-ish objects
  * Add `#all`, `#next` and `#next?` to `Subscription::List` and `Topic::List`
  * `#all` methods now return lazy enumerator with `request_limit`
* Resource Manager
  * `#all` methods now return lazy enumerator with `request_limit`
* Storage
  * Breaking Change: Remove `retries` option from `Bucket#delete` and
    `Project#create_bucket` (configure in `Backoff` instead)
  * Add support for customer-supplied encryption keys
  * Fix issue verifying large files (Aguasvivas22)
  * `#all` methods now return lazy enumerator with `request_limit`
* Vision
  * Add support for IO-ish objects

### 0.10.0 / 2016-05-19

#### Major Changes

* Add Vision service implementation

#### Minor Changes

* BigQuery
  * Restore chunk_size argument on Gcloud::Bigquery::Table#load (gramos74)
* Storage
  * Gcloud::Storage::Bucket#create_file now uses default chunk_size
* Datastore
  * Fixed documentation (bmclean)
* Add Gcloud::Upload.default_chunk_size
* Pegged dependency to google-protobuf version 3.0.0.alpha.5.0.5.1

### 0.9.0 / 2016-05-11

#### Major Changes

* Datastore
  * Upgrade Datastore to v1beta3 using gRPC
  * Add GQL query support
  * Breaking Changes:
    * `QueryResults#more_results` is now a symbol, was a string
    * `ApiError` is removed, top-level Gcloud errors returned now
    * `DATASTORE_HOST` environment variable removed, use
      `DATASTORE_EMULATOR_HOST` now

#### Minor Changes

* Datastore
  * Add insert and update methods to specify persistence behavior
  * Allow different updates (upsert/insert/update/delete) in a
    single commit outside of a transaction
  * Entity can now have Location property values
  * `QueryResults#more_after_cursor?` was added
  * `QueryResults#next?`, `#next`, `#all` were added
  * Allow array of objects as well as splat arguments
* Translate
  * Allow array of strings as well as splat arguments

### 0.8.2 / 2016-05-04

#### Changes

* Datastore
  * Fix issue with blob values being stored in base64 (bmclean)

### 0.8.1 / 2016-05-03

#### Changes

* Datastore
  * Add support for blob values (bmclean)
  * Add support for Date and DateTime values
  * Add support for setting read consistency
  * Add support for batch operations outside of a transaction (timanovsky)
  * Fix handling of rollback errors (timanovsky)
  * Remove setting of project/dataset_id in query partition (toots)

### 0.8.0 / 2016-04-28

#### Major changes

* Add support for Translate API
* Drop support for Search service

#### Minor changes

* Pub/Sub
  * Add support for emulator (dlorenc)
* Datastore
  * Fix bug where entities were not properly marked persisted after being saved
  * Fix bug in transaction delete accepting keys (timanovsky)
  * Update access token logic to avoid expired credentials (timanovsky)

### 0.7.2 / 2016-04-01

#### Changes

* Pub/Sub
  * Fixed issue with unnecessary acknowledge requests in autoack (maxstudener)

### 0.7.1 / 2016-04-01

#### Changes

* Pub/Sub
  * Fixed issue with unnecessary base-64 encoding of message data (ptinsley)

### 0.7.0 / 2016-03-31

#### Changes

* Add support for Logging service
* gRPC
  * Add dependency on gRPC gem
  * Pub/Sub transport layer now uses gRPC
  * New Logging transport layer uses gRPC
  * Future releases will migrate more services to gRPC

### 0.6.2 / 2016-03-02

#### Changes

* BigQuery
  * Fix error accessing a job's data before the job is complete (yhirano55)
  * Fix undefined local variable in Dataset's access rules (yhirano55)
  * Optionally specify location when creating a Dataset (gramos74)
* Datastore
  * Fix bug in calculating an Entity's `exclude_from_indexes` (bmclean)
* Pub/Sub
  * Correctly raise error when accessing a policy without permissions
  * Update policy permissions documentation

### 0.6.1 / 2015-12-29

#### Changes

* Add delimiter parameter for listing Storage files
* Add support for Ruby 2.3

### 0.6.0 / 2015-12-11

#### Changes

* Add support for Search service
* Drop support for Ruby 1.9.3
  * Replace options hash parameter with named parameters

### 0.5.0 / 2015-10-29

#### Changes

* Add support for Release Manager service
* Pub/Sub Additions
  * Fix issue getting and setting policies (jeffmendoza)
  * Modified `autocreate` default value and behavior
  * Add `skip_lookup` option on resource lookup methods
  * Add `Project#publish` method
  * Add `Project#subscribe` method
* Datastore Additions
  * Add `namespace` option on running queries (jondot)
  * Add `query`, `entity`, and `key` helpers to Dataset

### 0.4.1 / 2015-10-20

#### Changes

* Add support for Bucket attributes, including:
  * CORS
  * logging
  * versioning
  * location
  * website
  * storage class
* Add support for File attributes, including:
  * cache_control
  * content_dispostion
  * content_encoding
  * content_language
  * content_type
* Add support for File upload validation with MD5 or CRC32c
* Add File#public_url
* Improve stability and error reporting of Storage ACL helpers

### 0.4.0 / 2015-10-12

#### Major changes

* Add DNS Service

#### Minor changes

* Improved BigQuery table recognition from a string (vitaliel)
* Add missing options from BigQuery `Table#load` (gramos74)
* Add missing options from BigQuery `Table#extract`

### 0.3.1 / 2015-09-08

#### Changes

* Auto-discovery of project-id on Google Compute Engine
* Support getting project id from GCE auth compute
* New dataset access DSL for BigQuery
* New table schema DSL for BigQuery
* Add Code of Conduct

#### Minor changes

* Load data to BigQuery from Datastore backup
* Add `Job#wait_until_complete` convenience method to BigQuery
* Add String representation of tables in BigQuery
* Add `refresh!` methods to Storage and BigQuery
* Support `DATASTORE_DATASET` environment variable
* Update Storage and BigQuery documentation for possible errors during large file uploads
* Fix missing Pathname require
* Truncate object representation in interactive output

### 0.3.0 / 2015-08-21

#### Major changes

Add BigQuery service

#### Minor changes

* Improve error messaging when uploading files to Storage
* Add `GCLOUD_PROJECT` and `GCLOUD_KEYFILE` environment variables
* Specify OAuth 2.0 scopes when connecting to services

### 0.2.0 / 2015-07-22

#### Major changes

Add Pub/Sub service

#### Minor changes

* Add top-level `Gcloud` object with instance methods to initialize connections
  with individual services (e.g. `Gcloud#storage`)
* Add credential options to `Gcloud::Storage::File#signed_url`
* Add method aliases to improve usability of Storage API
* Improve documentation

### 0.1.1 / 2015-06-16

* Storage downloads files in binary mode (premist).
* Updated documentation.

### 0.1.0 / 2015-03-31

Initial release supporting Datastore and Storage services.
