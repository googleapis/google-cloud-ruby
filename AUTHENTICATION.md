# Authentication

In general, the google-cloud-ruby library uses [Service
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

General instructions, environment variables, and configuration options are
covered in the general [Authentication
guide](./google-cloud/AUTHENTICATION.md)
for the `google-cloud` umbrella package. Specific instructions and environment
variables for each individual service are linked from the README documents
listed below for each service.

## Creating a Service Account

Google Cloud requires a **Project ID** and **Service Account Credentials** to
connect to most services.

If you are not running this client within [Google Cloud Platform
environments](#google-cloud-platform-environments), you need a Google
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

## Project and Credential Lookup

The google-cloud-ruby library aims to make authentication as simple as possible,
and provides several mechanisms to configure your system without providing
**Project ID** and **Service Account Credentials** directly in code.

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

### Google Cloud Platform environments

When running on Google Cloud Platform (GCP), including Google Compute Engine (GCE),
Google Kubernetes Engine (GKE), Google App Engine (GAE), Google Cloud Functions
(GCF) and Cloud Run, the **Project ID** and **Credentials** and are discovered
automatically. Code should be written as if already authenticated.

### Environment Variables

The **Project ID** and **Credentials JSON** can be placed in environment
variables instead of declaring them directly in code. Each service has its own
environment variable, allowing for different service accounts to be used for
different services. (See the READMEs for the individual service gems for
details.) The path to the **Credentials JSON** file can be stored in the
environment variable, or the **Credentials JSON** itself can be stored for
environments such as Docker containers where writing files is difficult or not
encouraged.

Here are the environment variables that Datastore checks for project ID:

1. `DATASTORE_PROJECT`
2. `GOOGLE_CLOUD_PROJECT`

Here are the environment variables that Datastore checks for credentials:

1. `DATASTORE_KEYFILE` - Path to JSON file
2. `GOOGLE_CLOUD_KEYFILE` - Path to JSON file
3. `DATASTORE_KEYFILE_JSON` - JSON contents
4. `GOOGLE_CLOUD_KEYFILE_JSON` - JSON contents

### Cloud SDK

This option allows for an easy way to authenticate during development. If
credentials are not provided in code or in environment variables, then Cloud SDK
credentials are discovered.

To configure your system for this, simply:

1. [Download and install the Cloud SDK](https://cloud.google.com/sdk)
2. Authenticate using OAuth 2.0 `$ gcloud auth login`
3. Write code as if already authenticated.

**NOTE:** This is _not_ recommended for running in production. The Cloud SDK
*should only be used during development.

## Troubleshooting

If you're having trouble authenticating open a [Github
Issue](https://github.com/googleapis/google-cloud-ruby/issues/new?title=Authentication+question)
to get help.  Also consider searching or asking
[questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby)
on [StackOverflow](http://stackoverflow.com).
