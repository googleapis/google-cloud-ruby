# Release History

### 1.6.1 (2023-12-05)

#### Bug Fixes

* Allow dependency on google-cloud-env 2.x ([#23626](https://github.com/googleapis/google-cloud-ruby/issues/23626)) 

### 1.6.0 / 2021-03-10

#### Features

* Drop support for Ruby 2.4 and add support for Ruby 3.0

### 1.5.0 / 2020-01-09

* Extract error classes into a separate gem, google-cloud-errors.
* Various fixes for Core Config
    * Fix warnings on to_s!
    * Alias to_s! as inspect
    * Add send to ILLEGAL_KEYS
    * Add respond_to? as alias of field?

### 1.4.1 / 2019-10-29

#### Documentation

* Update the list of GCP environments for automatic authentication

### 1.4.0 / 2019-10-23

Now requires Ruby 2.4 or later.

### 1.3.2 / 2019-10-14

#### Bug Fixes

* Update Google::Cloud::Config#method_missing to be compatible with Ruby 2.7

### 1.3.1 / 2019-08-23

#### Documentation

* Update documentation

### 1.3.0 / 2019-01-31

* Add on_error configuration.

### 1.2.7 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 1.2.6 / 2018-09-12

* Add missing documentation files to package.

### 1.2.5 / 2018-09-11

* Fix for issue when auto-loading google-cloud-* gem.

### 1.2.4 / 2018-09-10

* Update documentation.

### 1.2.3 / 2018-08-21

* Update (deprecated) Credentials authentication URLs.
* Update documentation.

### 1.2.2 / 2018-07-05

* Disable warnings while auto-loading gems to avoid circular require warnings.

### 1.2.1 / 2018-06-28

* Warn when using Ruby version that is end-of-life.
* Fix google-cloud-* auto-load to load only the latest version.

### 1.2.0 / 2018-02-27

* Add Shared Configuration.

### 1.1.0 / 2017-11-14

* Rename constructor arguments to `project_id` and `credentials`.
* Document `Google::Auth::Credentials` as `credentials` value.
* Remove `googleauth` runtime dependency.
* Add the following helper methods to `Google::Cloud::Error`, which access the
  respective values on the underlying error objects.
  * `Error#status_code`
  * `Error#body`
  * `Error#header`
  * `Error#code`
  * `Error#details`
  * `Error#metadata`
  * `Error#status_details`
* Fixed mapping of `FailedPreconditionError` to 412 HTTP response code.

### 1.0.0 / 2017-03-31

* Release 1.0
* Add dependency on google-cloud-env

### 0.21.1 / 2016-11-22

* Support the new GAE Flex beta environment.

### 0.21.0 / 2016-10-20

* Updates to support new releases. No changes to the public API.

### 0.20.1 / 2016-08-26

* Fix autoloading of Google Cloud services

### 0.20.0 / 2016-08-26

This gem contains shared classes for the `google-cloud-ruby` gems. It is not intended for direct use. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
