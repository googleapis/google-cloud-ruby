# Release History

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
