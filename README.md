# gcloud

[![Travis Build Status](https://travis-ci.org/GoogleCloudPlatform/gcloud-ruby.svg)](https://travis-ci.org/GoogleCloudPlatform/gcloud-ruby/)
[![Coverage Status](https://img.shields.io/coveralls/GoogleCloudPlatform/gcloud-ruby.svg)](https://coveralls.io/r/GoogleCloudPlatform/gcloud-ruby?branch=master)

## Ruby API Client library for Google Cloud

This client supports the following Google Cloud Platform services:

* [Google Cloud Datastore](https://cloud.google.com/datastore/)
* [Google Cloud Storage](https://cloud.google.com/storage/)

If you need support for other Google APIs, check out the [Google API Ruby Client library](https://github.com/google/google-api-ruby-client).

## Quick Start

```sh
$ gem install gcloud
```

### Authorization

You need a Google Developers service account to use the Google Cloud services. To create a service account:

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

### Datastore

[Google Cloud Datastore](https://cloud.google.com/datastore/) ([docs](https://cloud.google.com/datastore/docs)) is a fully managed, schemaless database for storing non-relational data. Cloud Datastore automatically scales with your users and supports ACID transactions, high availability of reads and writes, strong consistency for reads and ancestor queries, and eventual consistency for all other queries.

Follow the [activation instructions](https://cloud.google.com/datastore/docs/activate) to use the Google Cloud Datastore API with your project.

See the [gcloud-ruby Datastore API documentation](http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Storage.html) to learn how to interact with the Cloud Datastore using this library.

```ruby
dataset = Gcloud::Datastore.dataset "my-todo-project-id",
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

### Storage

[Google Cloud Storage](https://cloud.google.com/storage/) ([docs](https://cloud.google.com/datastore/docs)) allows you to store data on Google infrastructure with very high reliability, performance and availability, and can be used to distribute large data objects to users via direct download.

See the [gcloud-ruby Storage API documentation](http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Storage.html) to learn how to connect to Cloud Storage using this library.

```ruby
storage = Gcloud::Storage.project "my-todo-project-id",
                                  "/path/to/keyfile.json"

bucket = storage.find_bucket "task-attachments"

file = bucket.find_file "path/to/my-file.ext"

# Download the file to the local file system
file.download "/tasks/attachments/#{file.name}"

# Copy the file to a backup bucket
backup = storage.find_bucket "task-attachment-backups"
file.copy backup, file.name
```

# Supported Ruby Versions

gcloud is supported on Ruby 1.9.3+.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See [CONTRIBUTING](CONTRIBUTING.md) for more information on how to get started.

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
