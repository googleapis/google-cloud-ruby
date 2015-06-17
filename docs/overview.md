# Getting started

The `gcloud` library is installable through rubygems:

```sh
$ gem install gcloud
```

# Authentication

Gcloud uses Service Account credentials to connect to Google Cloud services. When running on Compute Engine the credentials will be discovered automatically. When running on other environments the Service Account credentials can be specified by providing the path to the JSON file, or the JSON itself, in environment variables. Additionally, Cloud SDK credentials can also be discovered automatically, but this is only recommended during development.

## Creating a Service Account

Gcloud aims to make authentication as simple as possible. Google Cloud requires a **Project ID** and **Service Account Credentials** to connect to the APIs. To create a service account:

1. Visit the [Google Developers Console](https://console.developers.google.com/project).
2. Create a new project or click on an existing project.
3. Navigate to **APIs & auth** > **APIs section** and turn on the following APIs (you may need to enable billing in order to use these services):
  * Google Cloud Datastore API
  * Google Cloud Storage
  * Google Cloud Storage JSON API
4. Navigate to **APIs & auth** > **Credentials** and then:
  * If you want to use a new service account, click on **Create new Client ID** and select **Service account**. After the account is created, you will be prompted to download the JSON key file that the library uses to authorize your requests.
  * If you want to generate a new key for an existing service account, click on **Generate new JSON key** and download the JSON key file.

You will use the **Project ID** and **JSON file** to connect to services with gcloud.

## Project and Credential Lookup

Gcloud aims to make authentication as simple as possible, and provides several mechanisms to configure your system without providing **Project ID** and **Service Account Credentials** directly in code.

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
2. GOOGLE_CLOUD_PROJECT

Here are the environment variables that Datastore checks for credentials:

1. DATASTORE_KEYFILE - Path to JSON file
2. GOOGLE_CLOUD_KEYFILE - Path to JSON file
3. DATASTORE_KEYFILE_JSON - JSON contents
4. GOOGLE_CLOUD_KEYFILE_JSON - JSON contents

### Cloud SDK

This option allows for an easy way to authenticate during development. If credentials are not provided in code or in environment variables, then Cloud SDK credentials are discovered.

To configure your system for this, simply:

1. [Download and install the Cloud SDK](https://cloud.google.com/sdk)
2. Authenticate using OAuth2 `$ gcloud auth login`
3. Write code as if already authenticated.

**NOTE:** This is _not_ recommended for running in production. The Cloud SDK should only be used during development.

## Troubleshooting

If you're having trouble authenticating open a [Github Issue](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues/new?title=Authentication+question) to get help.  Also consider searching or asking [questions](http://stackoverflow.com/questions/tagged/gcloud-ruby) on [StackOverflow](http://stackoverflow.com).


# Datastore

[Google Cloud Datastore](https://cloud.google.com/datastore/) ([docs](https://cloud.google.com/datastore/docs)) is a fully managed, schemaless database for storing non-relational data. Cloud Datastore automatically scales with your users and supports ACID transactions, high availability of reads and writes, strong consistency for reads and ancestor queries, and eventual consistency for all other queries.

Follow the [activation instructions](https://cloud.google.com/datastore/docs/activate) to use the Google Cloud Datastore API with your project.

See the [gcloud-ruby Datastore API documentation](http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Storage.html) to learn how to interact with the Cloud Datastore using this library.

```ruby
require 'gcloud/datastore'

dataset = Gcloud.datastore "my-todo-project-id",
                           "/path/to/keyfile.json"

# Create a new task to demo datastore
demo_task = Gcloud::Datastore::Entity.new
demo_task.key = Gcloud::Datastore::Key.new "Task", "datastore-demo"
demo_task[:description] = "Demonstrate Datastore functionality"
demo_task[:completed] = false

# Save the new task
dataset.save demo_task

# Run a query for all completed tasks
query = Gcloud::Datastore::Query.new.kind("Task").
  where("completed", "=", true)
completed_tasks = dataset.run query
```

# Storage

[Google Cloud Storage](https://cloud.google.com/storage/) ([docs](https://cloud.google.com/storage/docs/json_api/)) allows you to store data on Google infrastructure with very high reliability, performance and availability, and can be used to distribute large data objects to users via direct download.

See the [gcloud-ruby Storage API documentation](http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Storage.html) to learn how to connect to Cloud Storage using this library.

```ruby
require 'gcloud/storage'

storage = Gcloud.storage "my-todo-project-id",
                         "/path/to/keyfile.json"

bucket = storage.find_bucket "task-attachments"

file = bucket.find_file "path/to/my-file.ext"

# Download the file to the local file system
file.download "/tasks/attachments/#{file.name}"

# Copy the file to a backup bucket
backup = storage.find_bucket "task-attachment-backups"
file.copy backup, file.name
```
