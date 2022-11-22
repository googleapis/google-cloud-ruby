# Google Secret Manager API Samples

Secret Manager provides a secure and convenient tool for storing API keys,
passwords, certificates, and other sensitive data.


## Description

These samples show how to use the [Google Secret Manager API]
(https://cloud.google.com/secret-manager/).

## Build and Run
1.  **Enable APIs** - [Enable the Secret Manager API](https://console.cloud.google.com/flows/enableapi?apiid=secretmanager.googleapis.com)
    and create a new project or select an existing project.

1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)

1.  **Clone the repo** and cd into this directory

    ```text
    $ git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
    $ cd ruby-docs-samples/secretmanager
    ```

1. **Install Dependencies** via [Bundler](https://bundler.io).

    ```text
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

    The output will show the help text:

    ```text
    Usage: bundle exec ruby snippets.rb [command] [arguments]

    Commands:
      access_secret_version <secret> <version>           Access a secret version
      add_secret_version <secret>                        Add a new secret version
      create_secret <secret>                             Create a new secret
      delete_secret <secret>                             Delete an existing secret
      destroy_secret_version <secret> <version>          Destroy a secret version
      disable_secret_version <secret> <version>          Disable a secret version
      enable_secret_version <secret> <version>           Enable a secret version
      get_secret <secret>                                Get a secret
      get_secret_version <secret> <version>              Get a secret version
      iam_grant_access <secret> <version> <member>       Grant the member access to the secret
      iam_revoke_access <secret> <version> <member>      Revoke the member access to the secret
      list_secret_versions <secret>                      List all versions for a secret
      list_secrets                                       List all secrets
      update_secret <secret>                             Update a secret

    Environment variables:
      GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    ```

## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)
