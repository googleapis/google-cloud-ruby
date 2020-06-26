<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google
Cloud Platform logo" title="Google Cloud Platform" align="right" height="96"
width="96"/>

# Google Cloud DLP API Samples

## Description

These samples show how to use the [Google Cloud DLP API](https://cloud.google.com/dlp/).

## Build and Run
1.  **Enable APIs** - [Enable the DLP API](https://console.cloud.google.com/flows/enableapi?apiid=dlp.googleapis.com)
    and create a new project or select an existing project.
1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)
1.  **Clone the repo** and cd into this directory
    ```
    $ git clone https://github.com/GoogleCloudPlatform/google-cloud-ruby
    $ cd google-cloud-ruby/google-cloud-dlp/samples
    ```

1. **Install Dependencies** via [Bundler](https://bundler.io).

    `bundle install`

1. **Create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)** - This file can be used to authenticate to Google Cloud Platform services from any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

1. **Set your Project Environment Variables**

    `export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"`

1. **Run samples**
    ```
    Usage: ruby sample.rb <command> [arguments]

    Commands:
      inspect_string <content> <max_findings> Inspect a string.
      inspect_file <filename> <max_findings> Inspect a local file.

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
      GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials
    ```

## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)
