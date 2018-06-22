# Release History

### 0.29.0 / 2018-06-22

* Updated dependencies.

### 0.28.0 / 2018-02-27

* Add Shared Configuration.
* Update Google API Client dependency.

### 0.27.0 / 2017-11-14

* Add `Google::Cloud::Dns::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Updated `google-api-client`, `googleauth` dependencies.

### 0.26.0 / 2017-09-28

* Update Google API Client dependency to 0.14.x.

### 0.25.0 / 2017-06-27

* Upgrade dependency on Google API Client.
* Update gem spec homepage links.
* Update tests.

### 0.24.0 / 2017-04-05

* Upgrade dependency on Google API Client

### 0.23.0 / 2017-03-31

* Updated documentation

### 0.22.0 / 2017-03-03

* Updated documentation and code examples.
* Dependency on Google API Client has been updated to 0.10.x.

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Dns.new

### 0.20.1 / 2016-09-02

* Fix for timeout on uploads.

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud DNS service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
