# Google Document AI API Samples

Document AI is a document understanding platform that takes unstructured data from documents and transforms it into structured data, making it easier to understand, analyze, and consume.

## Description

These samples show how to use the [Google Document AI API](https://cloud.google.com/document-ai/).

## Build and Run
1.  **Enable APIs** - [Enable the Document AI API](https://console.cloud.google.com/flows/enableapi?apiid=documentai.googleapis.com)
    and create a new project or select an existing project.

1.  **Install and Initialize Cloud SDK**
    Follow instructions from the available [quickstarts](https://cloud.google.com/sdk/docs/quickstarts)

1.  **Clone the repo** and cd into this directory

    ```text
    git clone https://github.com/googleapis/google-cloud-ruby.git
    $ cd google-cloud-ruby/google-cloud-document_ai
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
    bundle exec rake test
    ```

## Contributing changes

* See [CONTRIBUTING.md](../CONTRIBUTING.md)

## Licensing

* See [LICENSE](../LICENSE)
