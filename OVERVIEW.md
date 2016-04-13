# Getting started

The `gcloud` library is installable through rubygems:

```sh
$ gem install gcloud
```

Gcloud aims to make authentication as simple as possible. Google Cloud requires a **Project ID** and **Service Account Credentials** to connect to the APIs. You can learn more about various options for connection on the [Authentication Guide](https://googlecloudplatform.github.io/gcloud-ruby/#/docs/guides/authentication).

# BigQuery

[Google Cloud BigQuery](https://cloud.google.com/bigquery/) ([docs](https://cloud.google.com/bigquery/docs)) enables super-fast, SQL-like queries against append-only tables, using the processing power of Google's infrastructure. Simply move your data into BigQuery and let it handle the hard work. You can control access to both the project and your data based on your business needs, such as giving others the ability to view or query your data.

See the {Gcloud::Bigquery gcloud-ruby BigQuery API documentation} to learn how to connect to Cloud BigQuery using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
bigquery = gcloud.bigquery

# Create a new table to archive todos
dataset = bigquery.dataset "my-todo-archive"
table = dataset.create_table "todos",
          name: "Todos Archive",
          description: "Archive for completed TODO records"

# Load data into the table
file = File.open "/archive/todos/completed-todos.csv"
load_job = table.load file

# Run a query for the number of completed todos by owner
count_sql = "SELECT owner, COUNT(*) AS complete_count FROM todos GROUP BY owner"
data = bigquery.query count_sql
data.each do |row|
  puts row["name"]
end
```

# Datastore

[Google Cloud Datastore](https://cloud.google.com/datastore/) ([docs](https://cloud.google.com/datastore/docs)) is a fully managed, schemaless database for storing non-relational data. Cloud Datastore automatically scales with your users and supports ACID transactions, high availability of reads and writes, strong consistency for reads and ancestor queries, and eventual consistency for all other queries.

Follow the [activation instructions](https://cloud.google.com/datastore/docs/activate) to use the Google Cloud Datastore API with your project.

See the {Gcloud::Bigquery gcloud-ruby Datastore API documentation} to learn how to interact with the Cloud Datastore using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
datastore = gcloud.datastore

# Create a new task to demo datastore
task = datastore.entity "Task", "sampleTask" do |task|
  task["type"] = "Personal"
  task["done"] = false
  task["priority"] = 4
  task["description"] = "Learn Cloud Datastore"
end

# Save the new task
datastore.save task

# Run a query for all completed tasks
query = datastore.query("Task").
  where("done", "=", false)
tasks = datastore.run query
```

# DNS

[Google Cloud DNS](https://cloud.google.com/dns/) ([docs](https://cloud.google.com/dns/docs)) is a high-performance, resilient, global DNS service that provides a cost-effective way to make your applications and services available to your users. This programmable, authoritative DNS service can be used to easily publish and manage DNS records using the same infrastructure relied upon by Google. To learn more, read [What is Google Cloud DNS?](https://cloud.google.com/dns/what-is-cloud-dns).

See the {Gcloud::Dns gcloud-ruby DNS API documentation} to learn how to connect to Cloud DNS using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
dns = gcloud.dns

# Retrieve a zone
zone = dns.zone "example-com"

# Update records in the zone
change = zone.update do |tx|
  tx.add     "www", "A",  86400, "1.2.3.4"
  tx.remove  "example.com.", "TXT"
  tx.replace "example.com.", "MX", 86400, ["10 mail1.example.com.",
                                           "20 mail2.example.com."]
  tx.modify "www.example.com.", "CNAME" do |r|
    r.ttl = 86400 # only change the TTL
  end
end

```

# Logging

[Google Cloud Logging](https://cloud.google.com/logging/) collects and stores logs from applications and services on the Google Cloud Platform, giving you fine-grained, programmatic control over your projects' logs. With this API you can do the following:

* Read and filter log entries
* Export your log entries to Cloud Storage,
  BigQuery, or Cloud Pub/Sub
* Create logs-based metrics for use in Cloud
  Monitoring
* Write log entries

See the {Gcloud::Logging gcloud-ruby Logging API documentation} to learn how to connect to Cloud Loging using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
logging = gcloud.logging

# List all log entries
logging.entries.each do |e|
  puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
end

# List only entries from a single log
entries = logging.entries filter: "log:syslog"

# Write a log entry
entry = logging.entry
entry.payload = "Job started."
entry.log_name = "my_app_log"
entry.resource.type = "gae_app"
entry.resource.labels[:module_id] = "1"
entry.resource.labels[:version_id] = "20150925t173233"

logging.write_entries entry
```

# Pub/Sub

[Google Cloud Pub/Sub](https://cloud.google.com/pubsub/) ([docs](https://cloud.google.com/pubsub/reference/rest/)) is designed to provide reliable, many-to-many, asynchronous messaging between applications. Publisher applications can send messages to a “topic” and other applications can subscribe to that topic to receive the messages. By decoupling senders and receivers, Google Cloud Pub/Sub allows developers to communicate between independently written applications.

See the {Gcloud::Pubsub gcloud-ruby Pub/Sub API documentation} to learn how to connect to Cloud Pub/Sub using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
pubsub = gcloud.pubsub

# Retrieve a topic
topic = pubsub.topic "my-topic"

# Publish a new message
msg = topic.publish "new-message"

# Retrieve a subscription
sub = pubsub.subscription "my-topic-sub"

# Pull available messages
msgs = sub.pull
```

# Resource Manager

[Google Cloud Resource Manager](https://cloud.google.com/resource-manager/) ([docs](https://cloud.google.com/resource-manager/reference/rest/)) provides methods that you can use to programmatically manage your projects in the Google Cloud Platform. You may be familiar with managing projects in the [Developers Console](https://developers.google.com/console/help/new/). With this API you can do the following:

* Get a list of all projects associated with an account
* Create new projects
* Update existing projects
* Delete projects
* Undelete, or recover, projects that you don't want to delete

See the {Gcloud::ResourceManager gcloud-ruby Resource Manager API documentation} to learn how to connect to Cloud Resource Manager using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
resource_manager = gcloud.resource_manager

# List all projects
resource_manager.projects.each do |project|
  puts projects.project_id
end

# Label a project as production
project = resource_manager.project "tokyo-rain-123"
project.update do |p|
  p.labels["env"] = "production"
end

# List only projects with the "production" label
projects = resource_manager.projects filter: "labels.env:production"
```

# Search

[Google Cloud Search](https://cloud.google.com/search/) ([docs](https://cloud.google.com/search/reference/rest/index)) allows an application to quickly perform full-text and geo-spatial searches without having to spin up instances and without the hassle of managing and maintaining a search service.

See the {Gcloud::Search gcloud-ruby Search API documentation} to learn how to connect to Cloud Search using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
search = gcloud.search
index = search.index "products"

results = index.search "cotton T-shirt",
                       expressions: { total_price: "(price + tax)" },
                       fields: ["name", "total_price", "highlight"]
```

# Storage

[Google Cloud Storage](https://cloud.google.com/storage/) ([docs](https://cloud.google.com/storage/docs/json_api/)) allows you to store data on Google infrastructure with very high reliability, performance and availability, and can be used to distribute large data objects to users via direct download.

See the {Gcloud::Storage gcloud-ruby Storage API documentation} to learn how to connect to Cloud Storage using this library.

```ruby
require "gcloud"

gcloud = Gcloud.new
storage = gcloud.storage

bucket = storage.bucket "task-attachments"

file = bucket.file "path/to/my-file.ext"

# Download the file to the local file system
file.download "/tasks/attachments/#{file.name}"

# Copy the file to a backup bucket
backup = storage.bucket "task-attachment-backups"
file.copy backup, file.name
```
