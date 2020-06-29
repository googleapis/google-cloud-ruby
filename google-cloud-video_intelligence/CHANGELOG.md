# Release History

### 3.0.0 / 2020-06-29

#### ⚠ BREAKING CHANGES

* **video_intelligence:** Convert google-cloud-video_intelligence to a wrapper

#### Features

* Convert google-cloud-video_intelligence to a wrapper
* The endpoint, scope, and quota_project can be set via configuration

#### Bug Fixes

* Eliminated a circular require warning.

#### Documentation

* Cover exception changes in the migration guide
* Updated the sample timeouts in the migration guide to reflect seconds

### 2.1.1 / 2020-04-01

#### Documentation

* Remove broken troubleshooting link from auth guide.

### 2.1.0 / 2020-03-11

#### Features

* Add logo recognition annotations
* Add separate project setting for quota/billing

#### Documentation

* Update Request URIs link

### 2.0.3 / 2020-02-04

#### Documentation

* Update formatting and grammar
* Update formatting and grammar for v1p1beta1

### 2.0.2 / 2020-01-23

#### Documentation

* Update copyright year
* Update Status documentation

### 2.0.1 / 2019-11-06

#### Bug Fixes

* Update minimum runtime dependencies

### 2.0.0 / 2019-10-29

Note: This release requires Ruby 2.4 or later.

#### ⚠ BREAKING CHANGES

* Remove the v1beta1 client, because the service endpoint has been turned down.
* The "features" argument for VideoIntelligenceServiceClient#annotate_video is now a required positional argument, to align with the API definition.

### 1.4.0 / 2019-08-13

* Add VideoAnnotationResults fields
  * Add VideoAnnotationResults#segment_presence_label_annotations
  * Add VideoAnnotationResults#shot_presence_label_annotations
* Add segment and feature
  * Add VideoAnnotationResults#segment
  * Add VideoAnnotationProgress#feature
  * Add VideoAnnotationProgress#segment
* Update documentation

### 1.3.0 / 2019-07-08

* Use canonical module capitalization for VideoIntelligence type namespace.
* Support overriding service host and port.

### 1.2.0 / 2019-06-14

* Add VideoContext#object_tracking_config (ObjectTrackingConfig)
* Add TextDetectionConfig#model
* Add LabelDetectionConfig#frame_confidence_threshold
* Add LabelDetectionConfig#video_confidence_threshold
* Update code example documentation
* Add VERSION constant

### 1.1.5 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.

### 1.1.4 / 2019-02-27

* Add TEXT_DETECTION and OBJECT_TRACKING features

### 1.1.3 / 2018-11-14

* Update documentation.
* Add support for V1P1Beta1 and V1P2Beta1 API's.

### 1.1.2 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 1.1.1 / 2018-09-10

* Update documentation.

### 1.1.0 / 2018-08-21

* Deprecate Google::Cloud::VideoIntelligence::Credentials.
  * Use Google::Cloud::VideoIntelligence::V1::Credentials instead.
* Update dependencies.
* Update documentation.

### 1.0.0 / 2017-12-19

* Remove deprecated constructor arguments.
* Update documentation.
* Update google-gax dependency to 1.0.

### 0.25.0 / 2017-11-22

* Add support for V1 API.

### 0.24.1 / 2017-11-15

* Fix Credentials environment variable names.

### 0.24.0 / 2017-11-14

* Update generated GAPIC code and documentation.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.23.0 / 2017-09-27

* Beta release

### 0.22.0 / 2017-09-07

* Add support for V1beta2 API.

### 0.21.0 / 2017-07-11

* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.

### 0.20.0 / 2017-05-18

* Initial release
