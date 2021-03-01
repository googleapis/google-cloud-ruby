# Release History

### 0.34.0 / 2021-01-13

#### Features

* Replace google-api-client with google-apis-dns_v1

### 0.33.0 / 2020-09-16

#### Features

* quota_project can be set via library configuration ([#7628](https://www.github.com/googleapis/google-cloud-ruby/issues/7628))

### 0.32.1 / 2020-05-28

#### Documentation

* Fix a few broken links

### 0.32.0 / 2019-10-29

This release requires Ruby 2.4 or later.

#### Documentation

* Clarify which Google Cloud Platform products support automatic authentication

### 0.31.0 / 2019-10-01

#### Features

* Support overriding of service endpoint

### 0.30.2 / 2019-08-23

#### Documentation

* Update documentation

### 0.30.1 / 2019-07-15

* Ensure use of a sufficiently recent REST client with the correct endpoint.

### 0.30.0 / 2019-02-01

* Make use of Credentials#project_id
  * Use Credentials#project_id
    If a project_id is not provided, use the value on the Credentials object.
    This value was added in googleauth 0.7.0.
  * Loosen googleauth dependency
    Allow for new releases up to 0.10.
    The googleauth devs have committed to maintaining the current API
    and will not make backwards compatible changes before 0.10.:

### 0.29.4 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 0.29.3 / 2018-09-12

* Add missing documentation files to package.

### 0.29.2 / 2018-09-10

* Update documentation.

### 0.29.1 / 2018-08-21

* Reduce memory usage.
* Update documentation.

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
