# Authentication

## Creating a Service Account

The gcloud-ruby library aims to make authentication as simple as possible. Google Cloud requires a **Project ID** and **Service Account Credentials** to connect to the APIs. To create a service account:

1. Visit the [Google Developers Console Projects page](https://console.developers.google.com/project).
1. Create a new project or click on an existing project that you wish to use.
1. In the project's **Dashboard**, under **Explore other services**, click **Enable APIs and get credentials like keys**.
1. Turn on one or more of the following APIs by clicking on each API name and then clicking **Enable API** (click **More** if you do not see an API; also, you may need to enable billing in order to use some services):
  * BigQuery API
  * Cloud Datastore API
  * Cloud DNS API
  * Cloud Pub/Sub API
  * Cloud Storage Service
  * Cloud Storage JSON API
1. In the left nav, click **Credentials**.
1. Under **New credentials**, select **Service account key**.
1. If you want to create a new service account, under **Service account**, select **New service account**. Otherwise, select an existing service account. Submit the form to download a JSON type key. Save the downloaded JSON key file to authorize your requests.

You will use the **Project ID** and **JSON file** to connect to services with gcloud-ruby.

## Project and Credential Lookup

The gcloud-ruby library aims to make authentication as simple as possible, and provides several mechanisms to configure your system without providing **Project ID** and **Service Account Credentials** directly in code.

**Project ID** is discovered in the following order:

1. Specify project ID in code
2. Discover project ID in environment variables
3. Discover GCE project ID

**Credentials** are discovered in the following order:

1. Specify credentials in code
2. Discover credentials path in environment variables
3. Discover credentials JSON in environment variables
4. Discover credentials file in the Cloud SDK's path
5. Discover GCE credentials

### Compute Engine

While running on Google Compute Engine no extra work is needed. The **Project ID** and **Credentials** and are discovered automatically. Code should be written as if already authenticated.

### Environment Variables

The **Project ID** and **Credentials JSON** can be placed in environment variables instead of declaring them directly in code. Each service has its own environment variable, allowing for different service accounts to be used for different services. The path to the **Credentials JSON** file can be stored in the environment variable, or the **Credentials JSON** itself can be stored for environments such as Docker containers where writing files is difficult or not encouraged.

Here are the environment variables that Datastore checks for project ID:

1. DATASTORE_PROJECT
2. GCLOUD_PROJECT

Here are the environment variables that Datastore checks for credentials:

1. DATASTORE_KEYFILE - Path to JSON file
2. GCLOUD_KEYFILE - Path to JSON file
3. DATASTORE_KEYFILE_JSON - JSON contents
4. GCLOUD_KEYFILE_JSON - JSON contents

### Cloud SDK

This option allows for an easy way to authenticate during development. If credentials are not provided in code or in environment variables, then Cloud SDK credentials are discovered.

To configure your system for this, simply:

1. [Download and install the Cloud SDK](https://cloud.google.com/sdk)
2. Authenticate using OAuth 2.0 `$ gcloud auth login`
3. Write code as if already authenticated.

**NOTE:** This is _not_ recommended for running in production. The Cloud SDK should only be used during development.

## Troubleshooting

If you're having trouble authenticating open a [Github Issue](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues/new?title=Authentication+question) to get help.  Also consider searching or asking [questions](http://stackoverflow.com/questions/tagged/gcloud-ruby) on [StackOverflow](http://stackoverflow.com).
