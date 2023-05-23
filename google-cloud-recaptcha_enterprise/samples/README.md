<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Recaptcha Enterprise Ruby Samples

This directory contains samples for google-cloud-recaptcha_enterprise. [Google Cloud Recaptcha Enterprise](https://cloud.google.com/recaptcha-enterprise)

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow), 
which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

        gcloud auth application-default login

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts). 
This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

        export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json

### Set Project ID

Next, set the `GOOGLE_CLOUD_PROJECT` environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

        bundle install

## Run tests

Run the tests for these samples by running `bundle exec rake test`.

## Run samples

**Usage:** `ruby sample.rb [arguments]`

##### List of executable samples files and their arguments

| File | Args | Description |
| --- | --- | --- |
| recaptcha_enterprise_create_assessment.rb | `site_key` `token` `project_id` `recaptcha_action` | Create an assessment to analyze the risk of a UI action. |
| recaptcha_enterprise_create_site_key.rb | `project_id` `domain` | Create a site key by registering a domain/app to use recaptcha services. |
| recaptcha_enterprise_delete_site_key.rb | `project_id` `site_key` | Delete site key registered to use recaptcha services. |
| recaptcha_enterprise_get_metrics_site_key.rb | `project_id` `site_key` | Get metrics specific to a recaptcha site key. |
| recaptcha_enterprise_get_site_key.rb | `project_id` `site_key` | Get details of site key registered to use recaptcha services. |
| recaptcha_enterprise_list_site_keys.rb | `project_id` | List all site keys registered to use recaptcha services. |
| recaptcha_enterprise_migrate_site_key.rb | `project_id` `site_key` | Migrate a key from reCAPTCHA (non-Enterprise) to reCAPTCHA Enterprise. |
| recaptcha_enterprise_update_site_key.rb | `project_id` `site_key` `domain` | Update a site key registered for a domain/app to use recaptcha services. |