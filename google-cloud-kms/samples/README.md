# Google Cloud KMS API Samples

Cloud KMS is a cryptographic key management service that encrypts, decrypts,
signs, and verifies data under a unified API. It can manage keys secured in
software, hardware security modules (HSMs), and external key management system
outside of Google Cloud. These keys can be used with algorithms like AES, RSA,
and elliptic curve (EC).

## Description

These samples show how to use the [Google Cloud KMS API]
(https://cloud.google.com/kms/).

## Build and Run

1.  **Enable APIs** - [Enable the KMS API](https://console.cloud.google.com/flows/enableapi?apiid=cloudkms.googleapis.com)
    and create a new project or select an existing project.

1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)

1.  **Clone the repo** and cd into this directory.

    ```text
    $ git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
    $ cd ruby-docs-samples/kms
    ```

1. **Install Dependencies** via [Bundler](https://bundler.io).

    ```
    $ bundle install
    ```

1. **Set Environment Variables**

    ```text
    $ export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
    ```

1. **Run samples**

    ```text
    $ bundle exec ruby snippets.rb
    ```

    The output will show the help text.

## Running the tests

List fixtures that were previously created for the tests by running `bundle exec rake fixtures:list`.

Create missing fixtures for the tests by running `bundle exec rake fixtures:create`.

Run the acceptance tests for the samples by running `bundle exec rake test`.
