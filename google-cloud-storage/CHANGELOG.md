# Release History

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Storage.new
* Bucket#signed_url added to create URLs without a File object

### 0.20.2 / 2016-09-30

* Fix issue with signed_url and file names with spaces (gsbucks)

### 0.20.1 / 2016-09-02

* Fix for timeout on uploads.

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Storage service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
