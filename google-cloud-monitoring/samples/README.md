<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Monitoring Ruby Samples

[Google Cloud Monitoring][monitoring_docs] provides visibility into the performance, uptime, and overall health of cloud-powered applications. Monitoring collects metrics, events, and metadata from Google Cloud Platform, Amazon Web Services, hosted uptime probes, application instrumentation, and a variety of common application components including Cassandra, Nginx, Apache Web Server, Elasticsearch, and many others. Monitoring ingests that data and generates insights via dashboards, charts, and alerts. Monitoring alerting helps you collaborate by integrating with Slack, PagerDuty, HipChat, Campfire, and more. 

[monitoring_docs]: https://cloud.google.com/monitoring/docs/ 

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run Quickstart

    bundle exec ruby quickstart.rb

## Running the tests

* Authenticate by setting the `GOOGLE_APPLICATION_CREDENTIALS` environment variable as described above.
* Set the `GOOGLE_CLOUD_PROJECT` environment variable to the project ID used for testing.
* Run the acceptance tests for the samples by running `bundle exec rake test`.
