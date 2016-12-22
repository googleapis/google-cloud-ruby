# Release History

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
