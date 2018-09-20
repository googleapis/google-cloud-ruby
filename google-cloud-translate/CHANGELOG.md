# Release History

### 1.2.4 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 1.2.3 / 2018-09-12

* Add missing documentation files to package.

### 1.2.2 / 2018-09-10

* Update documentation.

### 1.2.1 / 2018-08-21

* Update documentation.

### 1.2.0 / 2018-02-27

* Support Shared Configuration.

### 1.1.0 / 2017-11-14

* Add `Google::Cloud::Translate::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Updated `faraday`, `googleauth` dependencies.

### 1.0.1 / 2017-07-11

* Remove mention of discontinued Premium Edition billing from documentation.

### 1.0.0 / 2017-06-28

* Release 1.0

### 0.23.1 / 2017-05-23

* Fix error handling (adrian-gomez)

### 0.23.0 / 2017-03-31

* No changes

### 0.22.2 / 2016-12-22

* Change product name to Google Cloud Translation API in docs.

### 0.22.1 / 2016-11-16

* Add missing googleauth dependency (frankyn)

### 0.22.0 / 2016-11-14

* Support authentication with service accounts
* Add `model` parameter to translate method
* Add `model` attribute to Translation objects

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Translate.new

### 0.20.1 / 2016-09-02

* Fix for timeout on uploads.

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Translate service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
