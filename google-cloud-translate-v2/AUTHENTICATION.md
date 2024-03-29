# Authentication

In general, the google-cloud-translate-v2 library uses [Service
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

## Project and Credential Lookup

The google-cloud-translate-v2 library aims to make authentication as simple as
possible, and provides several mechanisms to configure your system without
providing **Project ID** and **Service Account Credentials** directly in code.

**Project ID** is discovered in the following order:

1. Specify project ID in method arguments
2. Specify project ID in configuration
3. Discover project ID in environment variables
4. Discover GCE project ID

**Credentials** are discovered in the following order:

1. Specify credentials in method arguments
2. Specify credentials in configuration
3. Discover credentials path in environment variables
4. Discover credentials JSON in environment variables
5. Discover credentials file in the Cloud SDK's path
6. Discover GCE credentials

### Google Cloud Platform environments

While running on Google Cloud Platform environments such as Google Compute
Engine, Google App Engine and Google Kubernetes Engine, no extra work is needed.
The **Project ID** and **Credentials** and are discovered automatically. Code
should be written as if already authenticated. Just be sure when you [set up the
GCE instance][gce-how-to], you add the correct scopes for the APIs you want to
access. For example:

  * **All APIs**
    * `https://www.googleapis.com/auth/cloud-platform`
    * `https://www.googleapis.com/auth/cloud-platform.read-only`
  * **BigQuery**
    * `https://www.googleapis.com/auth/bigquery`
    * `https://www.googleapis.com/auth/bigquery.insertdata`
  * **Compute Engine**
    * `https://www.googleapis.com/auth/compute`
  * **Datastore**
    * `https://www.googleapis.com/auth/datastore`
    * `https://www.googleapis.com/auth/userinfo.email`
  * **DNS**
    * `https://www.googleapis.com/auth/ndev.clouddns.readwrite`
  * **Pub/Sub**
    * `https://www.googleapis.com/auth/pubsub`
  * **Storage**
    * `https://www.googleapis.com/auth/devstorage.full_control`
    * `https://www.googleapis.com/auth/devstorage.read_only`
    * `https://www.googleapis.com/auth/devstorage.read_write`

### Environment Variables

The **Project ID** and **Credentials JSON** can be placed in environment
variables instead of declaring them directly in code. Each service has its own
environment variable, allowing for different service accounts to be used for
different services. (See the READMEs for the individual service gems for
details.) The path to the **Credentials JSON** file can be stored in the
environment variable, or the **Credentials JSON** itself can be stored for
environments such as Docker containers where writing files is difficult or not
encouraged.

The environment variables that Translation checks for project ID are:

1. `TRANSLATE_PROJECT`
2. `GOOGLE_CLOUD_PROJECT`

The environment variables that Translation checks for credentials are configured
on {Google::Cloud::Translate::V2::Credentials}:

1. `TRANSLATE_CREDENTIALS` - Path to JSON file, or JSON contents
2. `TRANSLATE_KEYFILE` - Path to JSON file, or JSON contents
3. `GOOGLE_CLOUD_CREDENTIALS` - Path to JSON file, or JSON contents
4. `GOOGLE_CLOUD_KEYFILE` - Path to JSON file, or JSON contents
5. `GOOGLE_APPLICATION_CREDENTIALS` - Path to JSON file

```ruby
require "google/cloud/translate/v2"

ENV["TRANSLATE_PROJECT"]     = "my-project-id"
ENV["TRANSLATE_CREDENTIALS"] = "path/to/keyfile.json"

translate = Google::Cloud::Translate::V2.new
```

### Cloud SDK

This option allows for an easy way to authenticate during development. If
credentials are not provided in code or in environment variables, then Cloud SDK
credentials are discovered.

To configure your system for this, simply:

1. [Download and install the Cloud SDK](https://cloud.google.com/sdk)
2. Authenticate using OAuth 2.0 `$ gcloud auth login`
3. Write code as if already authenticated.

**NOTE:** This is _not_ recommended for running in production. The Cloud SDK
*should* only be used during development.

## Creating a Service Account

Google Cloud requires a **Project ID** and **Service Account Credentials** to
connect to the APIs. You will use the **Project ID** and **JSON key file** to
connect to most services with google-cloud-translate.

If you are not running this client on Google Compute Engine, you need a Google
Developers service account.

1. Visit the [Google Cloud Console](https://console.cloud.google.com/project).
1. Create a new project or click on an existing project.
1. Activate the menu in the upper left and select **APIs & Services**. From
   here, you will enable the APIs that your application requires.

   *Note: You may need to enable billing in order to use these services.*

1. Select **Credentials** from the side navigation.

   Find the "Create credentials" drop down near the top of the page, and select
   "Service account" to be guided through downloading a new JSON key file.

   If you want to re-use an existing service account, you can easily generate 
   a new key file. Just select the account you wish to re-use click the pencil
   tool on the right side to edit the service account, select the **Keys** tab,
   and then select **Add Key**.

   The key file you download will be used by this library to authenticate API
   requests and should be stored in a secure location.
