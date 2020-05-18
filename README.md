# Google Cloud Ruby Client

Idiomatic Ruby client for [Google Cloud Platform](https://cloud.google.com/)
services.

[![Coverage Status](https://codecov.io/gh/googleapis/google-cloud-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/googleapis/google-cloud-ruby)
[![Gem Version](https://badge.fury.io/rb/google-cloud.svg)](http://badge.fury.io/rb/google-cloud)

* [Homepage](https://googleapis.github.io/google-cloud-ruby/)
* [API documentation](https://googleapis.github.io/google-cloud-ruby/docs)
* [google-cloud on RubyGems](https://rubygems.org/gems/google-cloud)

This client supports the following Google Cloud Platform services:

* [Cloud Asset](#cloud-asset)
* [Cloud AutoML API](#cloud-automl-api)
* [BigQuery](#bigquery)
* [BigQuery Data Transfer](#bigquery-data-transfer-api)
* [Cloud Bigtable](#cloud-bigtable)
* [Cloud Billing API](#cloud-billing-api)
* [Container Analysis](#container-analysis)
* [Container Engine](#container-engine)
* [Cloud Dataproc](#cloud-dataproc)
* [Cloud Datastore](#cloud-datastore)
* [Stackdriver Debugger](#stackdriver-debugger)
* [Dialogflow API](#dialogflow-api)
* [Data Loss Prevention](#data-loss-prevention)
* [Cloud DNS](#cloud-dns)
* [Stackdriver Error Reporting](#stackdriver-error-reporting)
* [Cloud Firestore](#cloud-firestore)
* [Cloud Key Management Service](#cloud-key-management-service)
* [Cloud Natural Language API](#cloud-natural-language-api)
* [Stackdriver Logging](#stackdriver-logging)
* [Stackdriver Monitoring API](#stackdriver-monitoring-api)
* [Cloud OS Login](#cloud-os-login)
* [Phishing Protection](#phishing-protection)
* [Cloud Pub/Sub](#cloud-pubsub)
* [Recaptcha Enterprise](#recaptcha-enterprise)
* [Cloud Recommender API](#cloud-recommender-api)
* [Cloud Redis](#cloud-redis-api)
* [Cloud Resource Manager](#cloud-resource-manager)
* [Cloud Scheduler](#cloud-scheduler)
* [Secret Manager API](#secret-manager-api)
* [Cloud Security Center](#cloud-security-center)
* [Cloud Spanner API](#cloud-spanner-api)
* [Cloud Speech API](#cloud-speech-api)
* [Cloud Storage](#cloud-storage)
* [Cloud Talent Solutions API](#cloud-talent-solutions-api)
* [Cloud Tasks API](#cloud-tasks-api)
* [Cloud Text-To-Speech API](#cloud-text-to-speech-api)
* [Stackdriver Trace](#stackdriver-trace)
* [Cloud Translation API](#cloud-translation-api)
* [Cloud Video Intelligence API](#cloud-video-intelligence-api)
* [Cloud Vision API](#cloud-vision-api)
* [Web Risk API](#web-risk-api)

The support for each service is distributed as a separate gem. However, for your
convenience, the `google-cloud` gem lets you install the entire collection.

If you need support for other Google APIs, check out the [Google API Ruby Client
library](https://github.com/google/google-api-ruby-client).

## Quick Start

```sh
$ gem install google-cloud
```

The `google-cloud` gem shown above provides all of the individual service gems
in the google-cloud-ruby project, making it easy to explore Google Cloud
Platform. To avoid unnecessary dependencies, you can also install the service
gems independently.

### Authentication

In general, the google-cloud-ruby library uses [Service
Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
credentials to connect to Google Cloud services. When running on Google Cloud
Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine
(GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run,
the credentials will be discovered automatically. When running on other
environments, the Service Account credentials can be specified by providing the
path to the [JSON
keyfile](https://cloud.google.com/iam/docs/managing-service-account-keys) for
the account (or the JSON itself) in environment variables. Additionally, Cloud
SDK credentials can also be discovered automatically, but this is only
recommended during development.

General instructions, environment variables, and configuration options are
covered in the general [Authentication
guide](./google-cloud/AUTHENTICATION.md)
for the `google-cloud` umbrella package. Specific instructions and environment
variables for each individual service are linked from the README documents
listed below for each service.

The preview examples below demonstrate how to provide the **Project ID** and
**Credentials JSON file path** directly in code.

### Cloud Asset API

- [google-cloud-asset README](google-cloud-asset/README.md)
- [google-cloud-asset API documentation](https://googleapis.dev/ruby/google-cloud-asset/latest)
- [google-cloud-asset on RubyGems](https://rubygems.org/gems/google-cloud-asset/)

#### Quick Start

```sh
$ gem install google-cloud-asset
```

### Cloud AutoML API

- [google-cloud-automl README](google-cloud-automl/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-automl/latest)
- [google-cloud-automl on RubyGems](https://rubygems.org/gems/google-cloud-automl/)

#### Quick Start

```sh
$ gem install google-cloud-automl
```

### BigQuery

- [google-cloud-bigquery README](google-cloud-bigquery/README.md)
- [google-cloud-bigquery API documentation](https://googleapis.dev/ruby/google-cloud-bigquery/latest)
- [google-cloud-bigquery on RubyGems](https://rubygems.org/gems/google-cloud-bigquery)
- [Google BigQuery documentation](https://cloud.google.com/bigquery/docs)

#### Quick Start

```sh
$ gem install google-cloud-bigquery
```

### BigQuery Data Transfer API

- [google-bigquery-data_transfer README](google-cloud-bigquery-data_transfer/README.md)
- [google-bigquery-data_transfer API documentation](https://googleapis.dev/ruby/google-cloud-bigquery-data_transfer/latest)
- [google-bigquery-data_transfer on RubyGems](https://rubygems.org/gems/google-cloud-bigquery-data_transfer/)
- [Google BigQuery Data Transfer documentation](https://cloud.google.com/bigquery/transfer/)

#### Quick Start

```sh
$ gem install google-cloud-bigquery-data_transfer
```

### Cloud Bigtable

- [google-cloud-bigtable README](google-cloud-bigtable/README.md)
- [google-cloud-bigtable API documentation](https://googleapis.dev/ruby/google-cloud-bigtable/latest)
- [google-cloud-bigtable on RubyGems](https://rubygems.org/gems/google-cloud-bigtable)
- [Cloud Bigtable documentation](https://cloud.google.com/bigtable/docs)

#### Quick Start

```sh
$ gem install google-cloud-bigtable
```

### Cloud Billing API

- [google-cloud-billing README](google-cloud-billing/README.md)
- [google-cloud-billing API documentation](https://googleapis.dev/ruby/google-cloud-billing/latest)
- [google-cloud-billing on RubyGems](https://rubygems.org/gems/google-cloud-billing/)

#### Quick Start

```sh
$ gem install google-cloud-billing
```

### Cloud Datastore

- [google-cloud-datastore README](google-cloud-datastore/README.md)
- [google-cloud-datastore API documentation](https://googleapis.dev/ruby/google-cloud-datastore/latest)
- [google-cloud-datastore on RubyGems](https://rubygems.org/gems/google-cloud-datastore)
- [Google Cloud Datastore documentation](https://cloud.google.com/datastore/docs)

*Follow the [activation instructions](https://cloud.google.com/datastore/docs/activate) to use the Google Cloud Datastore API with your project.*

#### Quick Start

```sh
$ gem install google-cloud-datastore
```

### Stackdriver Debugger

- [google-cloud-debugger README](google-cloud-debugger/README.md)
- [google-cloud-debugger instrumentation documentation](./google-cloud-debugger/INSTRUMENTATION.md)
- [google-cloud-debugger on RubyGems](https://rubygems.org/gems/google-cloud-debugger)
- [Stackdriver Debugger documentation](https://cloud.google.com/debugger/docs)

#### Quick Start

```
$ gem install google-cloud-debugger
```

### Cloud DNS

- [google-cloud-dns README](google-cloud-dns/README.md)
- [google-cloud-dns API documentation](https://googleapis.dev/ruby/google-cloud-dns/latest)
- [google-cloud-dns on RubyGems](https://rubygems.org/gems/google-cloud-dns)
- [Google Cloud DNS documentation](https://cloud.google.com/dns/docs)

#### Quick Start

```sh
$ gem install google-cloud-dns
```

### Container Analysis

- [google-cloud-container_analysis README](google-cloud-container_analysis/README.md)
- [google-cloud-container_analysis API documentation](https://googleapis.dev/ruby/google-cloud-container_analysis/latest)
- [google-cloud-container_analysis on RubyGems](https://rubygems.org/gems/google-cloud-container_analysis)
- [Container Analysis documentation](https://cloud.google.com/container-registry/docs/container-analysis/)

#### Quick Start

```sh
$ gem install google-cloud-container_analysis
```

### Container Engine

- [google-cloud-container README](google-cloud-container/README.md)
- [google-cloud-container API documentation](https://googleapis.dev/ruby/google-cloud-container/latest)
- [google-cloud-container on RubyGems](https://rubygems.org/gems/google-cloud-container)
- [Container Engine documentation](https://cloud.google.com/kubernetes-engine/docs/)

#### Quick Start

```sh
$ gem install google-cloud-container
```

### Cloud Dataproc

- [google-cloud-dataproc README](google-cloud-dataproc/README.md)
- [google-cloud-dataproc API documentation](https://googleapis.dev/ruby/google-cloud-dataproc/latest)
- [google-cloud-dataproc on RubyGems](https://rubygems.org/gems/google-cloud-dataproc)
- [Google Cloud Dataproc documentation](https://cloud.google.com/dataproc/docs)

#### Quick Start

```sh
$ gem install google-cloud-dataproc
```

### Data Loss Prevention

- [google-cloud-dlp README](google-cloud-dlp/README.md)
- [google-cloud-dlp API documentation](https://googleapis.dev/ruby/google-cloud-dlp/latest)
- [google-cloud-dlp on RubyGems](https://rubygems.org/gems/google-cloud-dlp)
- [Data Loss Prevention documentation](https://cloud.google.com/dlp/docs)

#### Quick Start

```sh
$ gem install google-cloud-dlp
```

### Dialogflow API

- [google-cloud-dialogflow README](google-cloud-dialogflow/README.md)
- [google-cloud-dialogflow API documentation](https://googleapis.dev/ruby/google-cloud-dialogflow/latest)
- [google-cloud-dialogflow on RubyGems](https://rubygems.org/gems/google-cloud-dialogflow)
- [Dialogflow API documentation](https://cloud.google.com/dialogflow-enterprise/docs/)

#### Quick Start

```sh
$ gem install google-cloud-dialogflow
```

### Stackdriver Error Reporting

- [google-cloud-error_reporting README](google-cloud-error_reporting/README.md)
- [google-cloud-error_reporting instrumentation documentation](./google-cloud-error_reporting/INSTRUMENTATION.md)
- [google-cloud-error_reporting on RubyGems](https://rubygems.org/gems/google-cloud-error_reporting)
- [Stackdriver Error Reporting documentation](https://cloud.google.com/error-reporting/docs)

#### Quick Start

```sh
$ gem install google-cloud-error_reporting
```

### Cloud Firestore

- [google-cloud-firestore README](google-cloud-firestore/README.md)
- [google-cloud-firestore API documentation](https://googleapis.dev/ruby/google-cloud-firestore/latest)
- [google-cloud-firestore on RubyGems](https://rubygems.org/gems/google-cloud-firestore)
- [Google Cloud Firestore documentation](https://cloud.google.com/firestore/docs)

#### Quick Start

```sh
$ gem install google-cloud-firestore
```

### Cloud Key Management Service

- [google-cloud-kms README](google-cloud-kms/README.md)
- [google-cloud-kms API documentation](https://googleapis.dev/ruby/google-cloud-kms/latest)
- [google-cloud-kms on RubyGems](https://rubygems.org/gems/google-cloud-kms)
- [Google Cloud KMS documentation](https://cloud.google.com/kms/docs/)

#### Quick Start

```sh
$ gem install google-cloud-kms
```

### Stackdriver Logging

- [google-cloud-logging README](google-cloud-logging/README.md)
- [google-cloud-logging API documentation](https://googleapis.dev/ruby/google-cloud-logging/latest)
- [google-cloud-logging on RubyGems](https://rubygems.org/gems/google-cloud-logging)
- [Stackdriver Logging documentation](https://cloud.google.com/logging/docs/)

#### Quick Start

```sh
$ gem install google-cloud-logging
```

### Cloud Natural Language API

- [google-cloud-language README](google-cloud-language/README.md)
- [google-cloud-language API documentation](https://googleapis.dev/ruby/google-cloud-language/latest)
- [google-cloud-language on RubyGems](https://rubygems.org/gems/google-cloud-language)
- [Google Cloud Natural Language API documentation](https://cloud.google.com/natural-language/docs)

#### Quick Start

```sh
$ gem install google-cloud-language
```

### Cloud OS Login

- [google-cloud-os_login README](google-cloud-os_login/README.md)
- [google-cloud-os_login API documentation](https://googleapis.dev/ruby/google-cloud-os_login/latest)
- [google-cloud-os_login on RubyGems](https://rubygems.org/gems/google-cloud-os_login)
- [Google Cloud DNS documentation](https://cloud.google.com/compute/docs/oslogin/rest/)

#### Quick Start

```sh
$ gem install google-cloud-os_login
```

### Phishing Protection

- [google-cloud-phishing_protection README](google-cloud-phishing_protection/README.md)
- [google-cloud-phishing_protection API documentation](https://googleapis.dev/ruby/google-cloud-phishing_protection/latest)
- [google-cloud-phishing_protection on RubyGems](https://rubygems.org/gems/google-cloud-phishing_protection)
- [Phishing Protection documentation](https://cloud.google.com/phishing-protection/docs/)

#### Quick Start

```sh
$ gem install google-cloud-phishing_protection
```

### Cloud Pub/Sub

- [google-cloud-pubsub README](google-cloud-pubsub/README.md)
- [google-cloud-pubsub API documentation](https://googleapis.dev/ruby/google-cloud-pubsub/latest)
- [google-cloud-pubsub on RubyGems](https://rubygems.org/gems/google-cloud-pubsub)
- [Google Cloud Pub/Sub documentation](https://cloud.google.com/pubsub/docs)

#### Quick Start

```sh
$ gem install google-cloud-pubsub
```

### Recaptcha Enterprise

- [google-cloud-recaptcha_enterprise README](google-cloud-recaptcha_enterprise/README.md)
- [google-cloud-recaptcha_enterprise API documentation](https://googleapis.dev/ruby/google-cloud-recaptcha_enterprise/latest)
- [google-cloud-recaptcha_enterprise on RubyGems](https://rubygems.org/gems/google-cloud-recaptcha_enterprise)
- [Recaptcha Enterprise documentation](https://cloud.google.com/recaptcha-enterprise/docs/)

#### Quick Start

```sh
$ gem install google-cloud-recaptcha_enterprise
```

### Cloud Recommender API

- [google-cloud-recommender README](google-cloud-recommender/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-recommender/latest)
- [google-cloud-recommender on RubyGems](https://rubygems.org/gems/google-cloud-recommender/)

#### Quick Start

```sh
$ gem install google-cloud-recommender
```

### Cloud Redis API

- [google-cloud-redis README](google-cloud-redis/README.md)
- [google-cloud-redis API documentation](https://googleapis.dev/ruby/google-cloud-redis/latest)
- [google-cloud-redis on RubyGems](https://rubygems.org/gems/google-cloud-redis)
- [Cloud Redis API documentation](https://cloud.google.com/memorystore/docs/redis/)

#### Quick Start

```sh
$ gem install google-cloud-redis
```


### Cloud Resource Manager

- [google-cloud-resource_manager README](google-cloud-resource_manager/README.md)
- [google-cloud-resource_manager API documentation](https://googleapis.dev/ruby/google-cloud-resource_manager/latest)
- [google-cloud-resource_manager on RubyGems](https://rubygems.org/gems/google-cloud-resource_manager)
- [Google Cloud Resource Manager documentation](https://cloud.google.com/resource-manager/)

#### Quick Start

```sh
$ gem install google-cloud-resource_manager
```

### Stackdriver Trace

- [google-cloud-trace README](google-cloud-trace/README.md)
- [google-cloud-trace instrumentation documentation](./google-cloud-trace/INSTRUMENTATION.md)
- [google-cloud-trace on RubyGems](https://rubygems.org/gems/google-cloud-trace)
- [Stackdriver Trace documentation](https://cloud.google.com/trace/docs/)

#### Quick Start

```sh
$ gem install google-cloud-trace
```

### Cloud Spanner API

- [google-cloud-spanner README](google-cloud-spanner/README.md)
- [google-cloud-spanner API documentation](https://googleapis.dev/ruby/google-cloud-spanner/latest)
- [google-cloud-spanner on RubyGems](https://rubygems.org/gems/google-cloud-spanner)
- [Google Cloud Spanner API documentation](https://cloud.google.com/spanner/docs)

#### Quick Start

```sh
$ gem install google-cloud-spanner
```

### Cloud Speech API

- [google-cloud-speech README](google-cloud-speech/README.md)
- [google-cloud-speech API documentation](https://googleapis.dev/ruby/google-cloud-speech/latest)
- [google-cloud-speech on RubyGems](https://rubygems.org/gems/google-cloud-speech)
- [Google Cloud Speech API documentation](https://cloud.google.com/speech/docs)

#### Quick Start

```sh
$ gem install google-cloud-speech
```

### Cloud Scheduler

- [google-cloud-scheduler README](google-cloud-scheduler/README.md)
- [google-cloud-scheduler API documentation](https://googleapis.dev/ruby/google-cloud-scheduler/latest)
- [google-cloud-scheduler on RubyGems](https://rubygems.org/gems/google-cloud-scheduler)
- [Google Cloud Scheduler API documentation](https://cloud.google.com/scheduler/docs)

#### Quick Start

```sh
$ gem install google-cloud-scheduler
```

### Secret Manager API

- [google-cloud-secret_manager README](google-cloud-secret_manager/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-secret_manager/latest)
- [google-cloud-secret_manager on RubyGems](https://rubygems.org/gems/google-cloud-secret_manager/)

#### Quick Start

```sh
$ gem install google-cloud-secret_manager
```

### Cloud Security Center API

- [google-cloud-security_center README](google-cloud-security_center/README.md)
- [google-cloud-security_center API documentation](https://googleapis.dev/ruby/google-cloud-security_center/latest)
- [google-cloud-security_center on RubyGems](https://rubygems.org/gems/google-cloud-security_center)
- [Google Cloud Security Center API documentation](https://cloud.google.com/security-command-center/docs)

#### Quick Start

```sh
$ gem install google-cloud-security_center
```

### Cloud Storage

- [google-cloud-storage README](google-cloud-storage/README.md)
- [google-cloud-storage API documentation](https://googleapis.dev/ruby/google-cloud-storage/latest)
- [google-cloud-storage on RubyGems](https://rubygems.org/gems/google-cloud-storage)
- [Google Cloud Storage documentation](https://cloud.google.com/storage/docs)

#### Quick Start

```sh
$ gem install google-cloud-storage
```

### Cloud Talent Solutions API

- [google-cloud-talent README](google-cloud-talent/README.md)
- [google-cloud-talent API documentation](https://googleapis.dev/ruby/google-cloud-talent/latest)
- [google-cloud-talent on RubyGems](https://rubygems.org/gems/google-cloud-talent/)
- [Google Cloud Talent Solutions documentation](https://cloud.google.com/talent-solution/docs)

#### Quick Start

```sh
$ gem install google-cloud-talent
```

### Cloud Tasks API

- [google-cloud-tasks README](google-cloud-tasks/README.md)
- [google-cloud-tasks API documentation](https://googleapis.dev/ruby/google-cloud-tasks/latest)
- [google-cloud-tasks on RubyGems](https://rubygems.org/gems/google-cloud-tasks/)

#### Quick Start

```sh
$ gem install google-cloud-tasks
```

### Cloud Text To Speech API

#### Quick Start

```sh
$ gem install google-cloud-text_to_speech
```

### Cloud Translation API

- [google-cloud-translate README](google-cloud-translate/README.md)
- [google-cloud-translate API documentation](https://googleapis.dev/ruby/google-cloud-translate/latest)
- [google-cloud-translate on RubyGems](https://rubygems.org/gems/google-cloud-translate)
- [Google Cloud Translation API documentation](https://cloud.google.com/translation/docs)

#### Quick Start

```sh
$ gem install google-cloud-translate
```

### Cloud Vision API

- [google-cloud-vision README](google-cloud-vision/README.md)
- [google-cloud-vision API documentation](https://googleapis.dev/ruby/google-cloud-vision/latest)
- [google-cloud-vision on RubyGems](https://rubygems.org/gems/google-cloud-vision)
- [Google Cloud Vision API documentation](https://cloud.google.com/vision/docs)

#### Quick Start

```sh
$ gem install google-cloud-vision
```

### Stackdriver Monitoring API

- [google-cloud-monitoring README](google-cloud-monitoring/README.md)
- [google-cloud-monitoring API documentation](https://googleapis.dev/ruby/google-cloud-monitoring/latest)
- [google-cloud-monitoring on RubyGems](https://rubygems.org/gems/google-cloud-monitoring)
- [Google Cloud Monitoring API documentation](https://cloud.google.com/monitoring/docs)

#### Quick Start

```sh
$ gem install google-cloud-monitoring
```

### Cloud Video Intelligence API

- [google-cloud-video_intelligence README](google-cloud-video_intelligence/README.md)
- [google-cloud-video_intelligence API documentation](https://googleapis.dev/ruby/google-cloud-video_intelligence/latest)
- [google-cloud-video_intelligence on RubyGems](https://rubygems.org/gems/google-cloud-video_intelligence)
- [Google Cloud Video Intelligence API documentation](https://cloud.google.com/video-intelligence/docs)

#### Quick Start

```sh
$ gem install google-cloud-video_intelligence
```

### Web Risk API

- [google-cloud-webrisk README](google-cloud-webrisk/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-webrisk/latest)
- [google-cloud-webrisk on RubyGems](https://rubygems.org/gems/google-cloud-webrisk/)

#### Quick Start

```sh
$ gem install google-cloud-webrisk
```


## Supported Ruby Versions

These libraries are currently supported on Ruby 2.4+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.4
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Library Versioning

The libraries in this repository follow [Semantic Versioning](http://semver.org/).

Note that different libraries may be released at different support quality
levels:

**GA**: Libraries defined at the GA (general availability) quality level, indicated by a version number greater than or equal to 1.0, are stable. The code surface will not change in backwards-incompatible ways unless absolutely necessary (e.g. because of critical security issues), or unless accompanying a semver-major version update (such as version 1.x to 2.x.) Issues and requests against GA libraries are addressed with the highest priority.

**Beta**: Libraries defined at a Beta quality level, indicated by a version number less than 1.0, are expected to be mostly stable and we're working towards their release candidate. However, these libraries may get backwards-incompatible updates from time to time. We will still address issues and requests with a high priority.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See [CONTRIBUTING](.github/CONTRIBUTING.md) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is
available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/googleapis/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
