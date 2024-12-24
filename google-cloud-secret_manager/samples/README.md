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

    ```text
    $ export GOOGLE_CLOUD_LOCATION="YOUR_LOCATION_ID"
    ```

1. **Run global samples**

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
1. **Run regional samples**

    ```text
    $ bundle exec ruby regional_snippets.rb
    ```

    The output will show the help text:

    ```text
    Usage: bundle exec ruby regional_snippets.rb [command] [arguments]

    Commands:
      access_regional_secret_version <secret> <version>                       Access a regional secret version
      add_regional_secret_version <secret>                                    Add a new regional secret version
      create_regional_secret <secret>                                         Create a new regional secret
      delete_regional_secret_with_etag <secret> <etag>                        Delete an existing regional secret with associated etag
      delete_regional_secret <secret>                                         Delete an existing regional secret
      destroy_regional_secret_version_with_etag <secret> <version> <etag>     Destroy a regional secret version with associated etag
      destroy_regional_secret_version <secret> <version> <etag>               Destroy a regional secret version
      disable_regional_secret_version_with_etag <secret> <version> <etag>     Disable a regional secret version with associated etag
      disable_regional_secret_version <secret> <version>                      Disable a regional secret version
      enable_regional_secret_version_with_etag <secret> <version> <etag>      Enable a regional secret version with associated etag
      enable_regional_secret_version <secret> <version>                       Enable a regional secret version
      get_regional_secret <secret>                                            Get a regional secret
      get_regional_secret_version <secret> <version>                          Get a regional secret version
      iam_grant_access_regional <secret> <version> <member>                   Grant the member access to the regional secret
      iam_revoke_access_regional <secret> <version> <member>                  Revoke the member access to the regional secret
      list_regional_secret_versions_with_filter <secret> <filter>             List all versions for a regional secret which passes filter
      list_regional_secret_versions <secret>                                  List all versions for a regional secret
      list_regional_secrets_with_filter <filter>                              List all  regional secrets which passes filter
      list_regional_secrets                                                   List all  regional secrets
      update_regional_secret_with_alias <secret>                              Update a regional secret with alias
      update_regional_secret_with_etag <secret> <etag>                        Update a regional secret with associated etag
      update_regional_secret <secret>                                         Update a regional secret

    Environment variables:
      GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run the regional snippets
      GOOGLE_CLOUD_LOCATION   ID of the Google Cloud location to run the regional snippets
    ```


## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)
