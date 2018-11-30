# Release History

### 0.32.0 / 2018-09-26

* Add `ImageAnnotatorClient#face_detection`
* Add `ImageAnnotatorClient#landmark_detection`
* Add `ImageAnnotatorClient#logo_detection`
* Add `ImageAnnotatorClient#label_detection`
* Add `ImageAnnotatorClient#text_detection`
* Add `ImageAnnotatorClient#document_text_detection`
* Add `ImageAnnotatorClient#safe_search_detection`
* Add `ImageAnnotatorClient#image_properties_detection`
* Add `ImageAnnotatorClient#crop_hints_detection`
* Add `ImageAnnotatorClient#product_search_detection`
* Add `ImageAnnotatorClient#object_localization_detection`
* Add `ImageAnnotatorClient#web_detection`

### 0.31.0 / 2018-09-26

* Add Object Localization.

### 0.30.4 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.
* Fix circular require warning.

### 0.30.3 / 2018-09-12

* Add missing documentation files to package.

### 0.30.2 / 2018-09-10

* Update documentation.

### 0.30.1 / 2018-08-21

* Update documentation.

### 0.30.0 / 2018-07-20

* Add async_batch_annotate_files method to Google::Cloud::Vision::Project

### 0.29.1 / 2018-07-05

* Update google-gax dependency to version 1.3.

### 0.29.0 / 2018-06-22

* Add V1 API.

### 0.28.0 / 2018-02-27

* Add Shared Configuration.

### 0.27.0 / 2017-12-19

* Update google-gax dependency to 1.0.

### 0.26.0 / 2017-11-14

* Add `Google::Cloud::Vision::Credentials` class.
* Rename constructor arguments to `project_id` and `credentials`.
  (The previous arguments `project` and `keyfile` are still supported.)
* Document `Google::Auth::Credentials` as `credentials` value.
* Update generated low level GAPIC code.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.25.0 / 2017-07-11

* Add `Image#annotate`.
* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update gem spec homepage links.

### 0.24.0 / 2017-03-31

* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.23.0 / 2017-03-03

Major release, adding V1.1 support.

* Support image URLs from the internet, not just Cloud Storage.
* Add document text detection feature, like text but for longer documents.
* Add crop hints feature.
* Add web annotation feature
* Update GRPC header value sent to the Vision API.

### 0.22.1 / 2017-03-01

* No public API changes.
* Update GRPC header value sent to the Vision API.

### 0.22.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies
* Updates to code examples in documentation

### 0.21.1 / 2016-10-27

* Fix outdated requires (Ricowere)

### 0.21.0 / 2016-10-20

* New service constructor Google::Cloud::Vision.new
* New constructor argument client_config

### 0.20.2 / 2016-09-06

* Fix for using GCS URLs. (erikaxel)

### 0.20.1 / 2016-09-02

* Fix for timeout on uploads.

### 0.20.0 / 2016-08-26

This gem contains the Google Cloud Vision service implementation for the `google-cloud` gem. The `google-cloud` gem replaces the old `gcloud` gem. Legacy code can continue to use the `gcloud` gem.

* Namespace is now `Google::Cloud`
* The `google-cloud` gem is now an umbrella package for individual gems
