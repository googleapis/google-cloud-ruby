# Service Directory

Service Directory is a platform for discovering, publishing, and connecting
services. It offers customers a single place to register and discover their
services in a consistent and reliable way, regardless of their environment.

## Description

These samples show how to use the
[Service Directory API](https://cloud.google.com/service-directory/)


## Build and Run

1.  **Enable API**

    Enable the Service Directory API on your project

1.  **Install and Initialize Cloud SDK**

    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)

1.  **Clone the repo**

    ```
    $ git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
    $ cd ruby-docs-samples/servicedirectory
    ```

1.  **Install Dependencies** via [Bundler](https://bundler.io/)

    ```
    $ bundle install
    ```

1.  **Set Environment Variables**

    ```
    $ export GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"
    ```

1.  **Run Samples**

    ```
    Usage: bundle exec ruby servicedirectory.rb [command] [arguments]

    Commands:
      create_namespace    <location> <namespace>
      delete_namespace    <location> <namespace>
      create_service      <location> <namespace> <service>
      delete_service      <location> <namespace> <service>
      create_endpoint     <location> <namespace> <service> <endpoint>
      delete_endpoint     <location> <namespace> <service> <endpoint>
      resolve_service     <location> <namespace> <service>

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud Project ID
    ```

## Contributing Changes

*  See
   [CONTRIBUTING.md](https://github.com/GoogleCloudPlatform/ruby-docs-samples/blob/master/CONTRIBUTING.md)

## Licensing

*  See
   [LICENSE](https://github.com/GoogleCloudPlatform/ruby-docs-samples/blob/master/LICENSE)
