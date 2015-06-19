# Getting started

The `gcloud` library is installable through rubygems:

```sh
$ gem install gcloud
```

Gcloud aims to make authentication as simple as possible. Google Cloud requires a **Project ID** and **Service Account Credentials** to connect to the APIs. You can learn more about various options for connection on the [Authentication Guide](AUTHENTICATION.md).

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

bucket = storage.bucket "task-attachments"

file = bucket.file "path/to/my-file.ext"

# Download the file to the local file system
file.download "/tasks/attachments/#{file.name}"

# Copy the file to a backup bucket
backup = storage.bucket "task-attachment-backups"
file.copy backup, file.name
```
