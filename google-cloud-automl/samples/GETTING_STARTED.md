# AutoML Samples Getting Started

## GCP Project Configuration

To run these samples you need a GCP project that has enabled the AutoML APIs and created a Dataset and Model for each API using the Getting Started guide.
The APIs and their Getting Started guides can be found here: https://cloud.google.com/automl/docs/

A GCS bucket is also needed, and should be created in the `us-central1` region.
All required files will be added to the GCS bucket when the sample tests are run.

## Local Configuration

The AutoML Samples require the following environment variables to be set in order to run:

* `AUTOML_PROJECT_ID`
* `AUTOML_BUCKET_NAME`
* `AUTOML_EXTRACTION_DATASET_ID`
* `AUTOML_EXTRACTION_MODEL_ID`
* `AUTOML_SENTIMENT_DATASET_ID`
* `AUTOML_SENTIMENT_MODEL_ID`
* `AUTOML_CLASSIFICATION_DATASET_ID`
* `AUTOML_CLASSIFICATION_MODEL_ID`
* `AUTOML_TRANSLATE_DATASET_ID`
* `AUTOML_TRANSLATE_MODEL_ID`
* `AUTOML_VISION_CLASS_DATASET_ID`
* `AUTOML_VISION_CLASS_MODEL_ID`
* `AUTOML_VISION_OBJECT_DATASET_ID`
* `AUTOML_VISION_OBJECT_MODEL_ID`

An easy way to configure all of these is to create a `.env` file using the following template:

```
AUTOML_PROJECT_ID=PROJECT_ID
AUTOML_BUCKET_NAME=PROJECT_ID-vcm
AUTOML_EXTRACTION_DATASET_ID=TEN0000000000000000000
AUTOML_EXTRACTION_MODEL_ID=TEN0000000000000000000
AUTOML_SENTIMENT_DATASET_ID=TST0000000000000000000
AUTOML_SENTIMENT_MODEL_ID=TST0000000000000000000
AUTOML_CLASSIFICATION_DATASET_ID=TCN0000000000000000000
AUTOML_CLASSIFICATION_MODEL_ID=TCN0000000000000000000
AUTOML_TRANSLATE_DATASET_ID=TRL0000000000000000000
AUTOML_TRANSLATE_MODEL_ID=TRL0000000000000000000
AUTOML_VISION_CLASS_DATASET_ID=XXX0000000000000000000
AUTOML_VISION_CLASS_MODEL_ID=XXX0000000000000000000
AUTOML_VISION_OBJECT_DATASET_ID=IOD0000000000000000000
AUTOML_VISION_OBJECT_MODEL_ID=IOD0000000000000000000
```

The Rspec tests are configured to load this file if it exists.

## Running tests

Before running the samples, make sure your local environment has Ruby and the Bundler gem installed.
All other Ruby dependencies can be managed by Bundler:

```
$ gem install bundler
$ bundle install
```

The samples can be run with the following:

```
$ bundle exec rspec
```

There are several slow samples that are skipped by default.
The slow samples can be run with the following:

```
$ bundle exec rspec --tag slow
```
