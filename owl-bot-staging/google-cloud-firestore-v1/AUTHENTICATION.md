# Authentication

The recommended way to authenticate to the google-cloud-firestore-v1 library is to use
[Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials).
To review all of your authentication options, see [Credentials lookup](#credential-lookup).

## Quickstart

The following example shows how to set up authentication for a local development
environment with your user credentials. 

**NOTE:** This method is _not_ recommended for running in production. User credentials
should be used only during development.

1. [Download and install the Google Cloud CLI](https://cloud.google.com/sdk).
2. Set up a local ADC file with your user credentials:

```sh
gcloud auth application-default login
```

3. Write code as if already authenticated.

For more information about setting up authentication for a local development environment, see
[Set up Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-dev).

## Credential Lookup

The google-cloud-firestore-v1 library provides several mechanisms to configure your system.
Generally, using Application Default Credentials to facilitate automatic 
credentials discovery is the easist method. But if you need to explicitly specify
credentials, there are several methods available to you.

Credentials are accepted in the following ways, in the following order or precedence:

1. Credentials specified in method arguments
2. Credentials specified in configuration
3. Credentials pointed to or included in environment variables
4. Credentials found in local ADC file
5. Credentials returned by the metadata server for the attached service account (GCP)

### Configuration

You can configure a path to a JSON credentials file, either for an individual client object or
globally, for all client objects. The JSON file can contain credentials created for
[workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation),
[workforce identity federation](https://cloud.google.com/iam/docs/workforce-identity-federation), or a
[service account key](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-key).

Note: Service account keys are a security risk if not managed correctly. You should
[choose a more secure alternative to service account keys](https://cloud.google.com/docs/authentication#auth-decision-tree)
whenever possible.

To configure a credentials file for an individual client initialization:

```ruby
require "google/cloud/firestore/v1"

client = ::Google::Cloud::Firestore::V1::Firestore::Client.new do |config|
  config.credentials = "path/to/credentialfile.json"
end
```

To configure a credentials file globally for all clients:

```ruby
require "google/cloud/firestore/v1"

::Google::Cloud::Firestore::V1::Firestore::Client.configure do |config|
  config.credentials = "path/to/credentialfile.json"
end

client = ::Google::Cloud::Firestore::V1::Firestore::Client.new
```

### Environment Variables

You can also use an environment variable to provide a JSON credentials file.
The environment variable can contain a path to the credentials file or, for
environments such as Docker containers where writing files is not encouraged,
you can include the credentials file itself.

The JSON file can contain credentials created for
[workload identity federation](https://cloud.google.com/iam/docs/workload-identity-federation),
[workforce identity federation](https://cloud.google.com/iam/docs/workforce-identity-federation), or a
[service account key](https://cloud.google.com/docs/authentication/provide-credentials-adc#local-key).

Note: Service account keys are a security risk if not managed correctly. You should
[choose a more secure alternative to service account keys](https://cloud.google.com/docs/authentication#auth-decision-tree)
whenever possible.

The environment variables that google-cloud-firestore-v1
checks for credentials are:

* `GOOGLE_CLOUD_CREDENTIALS` - Path to JSON file, or JSON contents
* `GOOGLE_APPLICATION_CREDENTIALS` - Path to JSON file

```ruby
require "google/cloud/firestore/v1"

ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "path/to/credentialfile.json"

client = ::Google::Cloud::Firestore::V1::Firestore::Client.new
```

### Local ADC file

You can set up a local ADC file with your user credentials for authentication during
development. If credentials are not provided in code or in environment variables,
then the local ADC credentials are discovered.

Follow the steps in [Quickstart](#quickstart) to set up a local ADC file.

### Google Cloud Platform environments

When running on Google Cloud Platform (GCP), including Google Compute Engine
(GCE), Google Kubernetes Engine (GKE), Google App Engine (GAE), Google Cloud
Functions (GCF) and Cloud Run, credentials are retrieved from the attached
service account automatically. Code should be written as if already authenticated.

For more information, see
[Set up ADC for Google Cloud services](https://cloud.google.com/docs/authentication/provide-credentials-adc#attached-sa).
