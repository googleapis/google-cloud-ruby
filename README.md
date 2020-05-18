# Google Cloud Ruby Client

Idiomatic Ruby client for [Google Cloud Platform](https://cloud.google.com/)
services.

[![Coverage Status](https://codecov.io/gh/googleapis/google-cloud-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/googleapis/google-cloud-ruby)
[![Gem Version](https://badge.fury.io/rb/google-cloud.svg)](http://badge.fury.io/rb/google-cloud)

* [Homepage](https://googleapis.github.io/google-cloud-ruby/)
* [API documentation](https://googleapis.github.io/google-cloud-ruby/docs)
* [google-cloud on RubyGems](https://rubygems.org/gems/google-cloud)

This client supports the following Google Cloud Platform services:

* [Cloud Asset](#cloud-asset)
* [Cloud AutoML API](#cloud-automl-api)
* [BigQuery](#bigquery)
* [BigQuery Data Transfer](#bigquery-data-transfer-api)
* [Cloud Bigtable](#cloud-bigtable)
* [Cloud Billing API](#cloud-billing-api)
* [Container Analysis](#container-analysis)
* [Container Engine](#container-engine)
* [Cloud Dataproc](#cloud-dataproc)
* [Cloud Datastore](#cloud-datastore)
* [Stackdriver Debugger](#stackdriver-debugger)
* [Dialogflow API](#dialogflow-api)
* [Data Loss Prevention](#data-loss-prevention)
* [Cloud DNS](#cloud-dns)
* [Stackdriver Error Reporting](#stackdriver-error-reporting)
* [Cloud Firestore](#cloud-firestore)
* [Cloud Key Management Service](#cloud-key-management-service)
* [Cloud Natural Language API](#cloud-natural-language-api)
* [Stackdriver Logging](#stackdriver-logging)
* [Stackdriver Monitoring API](#stackdriver-monitoring-api)
* [Cloud OS Login](#cloud-os-login)
* [Phishing Protection](#phishing-protection)
* [Cloud Pub/Sub](#cloud-pubsub)
* [Recaptcha Enterprise](#recaptcha-enterprise)
* [Cloud Recommender API](#cloud-recommender-api)
* [Cloud Redis](#cloud-redis-api)
* [Cloud Resource Manager](#cloud-resource-manager)
* [Cloud Scheduler](#cloud-scheduler)
* [Secret Manager API](#secret-manager-api)
* [Cloud Security Center](#cloud-security-center)
* [Cloud Spanner API](#cloud-spanner-api)
* [Cloud Speech API](#cloud-speech-api)
* [Cloud Storage](#cloud-storage)
* [Cloud Talent Solutions API](#cloud-talent-solutions-api)
* [Cloud Tasks API](#cloud-tasks-api)
* [Cloud Text-To-Speech API](#cloud-text-to-speech-api)
* [Stackdriver Trace](#stackdriver-trace)
* [Cloud Translation API](#cloud-translation-api)
* [Cloud Video Intelligence API](#cloud-video-intelligence-api)
* [Cloud Vision API](#cloud-vision-api)
* [Web Risk API](#web-risk-api)

The support for each service is distributed as a separate gem. However, for your
convenience, the `google-cloud` gem lets you install the entire collection.

If you need support for other Google APIs, check out the [Google API Ruby Client
library](https://github.com/google/google-api-ruby-client).

## Quick Start

```sh
$ gem install google-cloud
```

The `google-cloud` gem shown above provides all of the individual service gems
in the google-cloud-ruby project, making it easy to explore Google Cloud
Platform. To avoid unnecessary dependencies, you can also install the service
gems independently.

### Authentication

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

The preview examples below demonstrate how to provide the **Project ID** and
**Credentials JSON file path** directly in code.

### Cloud Asset API

- [google-cloud-asset README](google-cloud-asset/README.md)
- [google-cloud-asset API documentation](https://googleapis.dev/ruby/google-cloud-asset/latest)
- [google-cloud-asset on RubyGems](https://rubygems.org/gems/google-cloud-asset/)

#### Quick Start

```sh
$ gem install google-cloud-asset
```

### Cloud AutoML API

- [google-cloud-automl README](google-cloud-automl/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-automl/latest)
- [google-cloud-automl on RubyGems](https://rubygems.org/gems/google-cloud-automl/)

#### Quick Start

```sh
$ gem install google-cloud-automl
```

### BigQuery

- [google-cloud-bigquery README](google-cloud-bigquery/README.md)
- [google-cloud-bigquery API documentation](https://googleapis.dev/ruby/google-cloud-bigquery/latest)
- [google-cloud-bigquery on RubyGems](https://rubygems.org/gems/google-cloud-bigquery)
- [Google BigQuery documentation](https://cloud.google.com/bigquery/docs)

#### Quick Start

```sh
$ gem install google-cloud-bigquery
```

#### Preview

```ruby
require "google/cloud/bigquery"

bigquery = Google::Cloud::Bigquery.new
dataset = bigquery.create_dataset "my_dataset"

table = dataset.create_table "my_table" do |t|
  t.name = "My Table"
  t.description = "A description of my table."
  t.schema do |s|
    s.string "first_name", mode: :required
    s.string "last_name", mode: :required
    s.integer "age", mode: :required
  end
end

# Load data into the table from Google Cloud Storage
table.load "gs://my-bucket/file-name.csv"

# Run a query
data = dataset.query "SELECT first_name FROM my_table"

data.each do |row|
  puts row[:first_name]
end
```

### BigQuery Data Transfer API

- [google-bigquery-data_transfer README](google-cloud-bigquery-data_transfer/README.md)
- [google-bigquery-data_transfer API documentation](https://googleapis.dev/ruby/google-cloud-bigquery-data_transfer/latest)
- [google-bigquery-data_transfer on RubyGems](https://rubygems.org/gems/google-cloud-bigquery-data_transfer/)
- [Google BigQuery Data Transfer documentation](https://cloud.google.com/bigquery/transfer/)

#### Quick Start

```sh
$ gem install google-cloud-bigquery-data_transfer
```

#### Preview

```rb
require "google/cloud/bigquery/data_transfer"

client = Google::Cloud::Bigquery::DataTransfer.data_transfer_service
parent = client.project_path project: project_id

# Iterate over all results.
client.list_data_sources(parent: parent).each do |element|
  # Process element.
end

# Or iterate over results one page at a time.
client.list_data_sources(parent: parent).each_page do |page|
  # Process each page at a time.
  page.each do |element|
    # Process element.
  end
end
```

### Cloud Bigtable

- [google-cloud-bigtable README](google-cloud-bigtable/README.md)
- [google-cloud-bigtable API documentation](https://googleapis.dev/ruby/google-cloud-bigtable/latest)
- [google-cloud-bigtable on RubyGems](https://rubygems.org/gems/google-cloud-bigtable)
- [Cloud Bigtable documentation](https://cloud.google.com/bigtable/docs)

#### Quick Start

```sh
$ gem install google-cloud-bigtable
```

#### Preview

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.table("my-instance", "my-table")

entry = table.new_mutation_entry("user-1")
entry.set_cell(
  "cf-1",
  "field-1",
  "XYZ",
  timestamp: Time.now.to_i * 1000 # Time stamp in milli seconds.
).delete_cells("cf2", "field02")

table.mutate_row(entry)
```

### Cloud Billing API

- [google-cloud-billing README](google-cloud-billing/README.md)
- [google-cloud-billing API documentation](https://googleapis.dev/ruby/google-cloud-billing/latest)
- [google-cloud-billing on RubyGems](https://rubygems.org/gems/google-cloud-billing/)

#### Quick Start

```sh
$ gem install google-cloud-billing
```

### Cloud Datastore

- [google-cloud-datastore README](google-cloud-datastore/README.md)
- [google-cloud-datastore API documentation](https://googleapis.dev/ruby/google-cloud-datastore/latest)
- [google-cloud-datastore on RubyGems](https://rubygems.org/gems/google-cloud-datastore)
- [Google Cloud Datastore documentation](https://cloud.google.com/datastore/docs)

*Follow the [activation instructions](https://cloud.google.com/datastore/docs/activate) to use the Google Cloud Datastore API with your project.*

#### Quick Start

```sh
$ gem install google-cloud-datastore
```

#### Preview

```ruby
require "google/cloud/datastore"

datastore = Google::Cloud::Datastore.new(
  project_id: "my-todo-project",
  credentials: "/path/to/keyfile.json"
)

# Create a new task to demo datastore
task = datastore.entity "Task", "sampleTask" do |t|
  t["type"] = "Personal"
  t["done"] = false
  t["priority"] = 4
  t["description"] = "Learn Cloud Datastore"
end

# Save the new task
datastore.save task

# Run a query for all completed tasks
query = datastore.query("Task").
  where("done", "=", false)
tasks = datastore.run query
```

### Stackdriver Debugger

- [google-cloud-debugger README](google-cloud-debugger/README.md)
- [google-cloud-debugger instrumentation documentation](./google-cloud-debugger/INSTRUMENTATION.md)
- [google-cloud-debugger on RubyGems](https://rubygems.org/gems/google-cloud-debugger)
- [Stackdriver Debugger documentation](https://cloud.google.com/debugger/docs)

#### Quick Start

```
$ gem install google-cloud-debugger
```

#### Preview

```ruby
require "google/cloud/debugger"

debugger = Google::Cloud::Debugger.new
debugger.start
```

### Cloud DNS

- [google-cloud-dns README](google-cloud-dns/README.md)
- [google-cloud-dns API documentation](https://googleapis.dev/ruby/google-cloud-dns/latest)
- [google-cloud-dns on RubyGems](https://rubygems.org/gems/google-cloud-dns)
- [Google Cloud DNS documentation](https://cloud.google.com/dns/docs)

#### Quick Start

```sh
$ gem install google-cloud-dns
```

#### Preview

```ruby
require "google/cloud/dns"

dns = Google::Cloud::Dns.new

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

### Container Analysis

- [google-cloud-container_analysis README](google-cloud-container_analysis/README.md)
- [google-cloud-container_analysis API documentation](https://googleapis.dev/ruby/google-cloud-container_analysis/latest)
- [google-cloud-container_analysis on RubyGems](https://rubygems.org/gems/google-cloud-container_analysis)
- [Container Analysis documentation](https://cloud.google.com/container-registry/docs/container-analysis/)

#### Quick Start

```sh
$ gem install google-cloud-container_analysis
```

#### Preview

```ruby
require "google/cloud/container_analysis"

container_analysis_client = Google::Cloud::ContainerAnalysis.new
grafeas_client = container_analysis_client.grafeas_client
parent = Grafeas::V1::GrafeasClient.project_path "my-project"
results = grafeas_client.list_occurrences(parent).each do |occurrence|
  # do something with occurrence
end
```

### Container Engine

- [google-cloud-container README](google-cloud-container/README.md)
- [google-cloud-container API documentation](https://googleapis.dev/ruby/google-cloud-container/latest)
- [google-cloud-container on RubyGems](https://rubygems.org/gems/google-cloud-container)
- [Container Engine documentation](https://cloud.google.com/kubernetes-engine/docs/)

#### Quick Start

```sh
$ gem install google-cloud-container
```

#### Preview

```ruby
require "google/cloud/container"

cluster_manager_client = Google::Cloud::Container.new
project_id_2 = project_id
zone = "us-central1-a"
response = cluster_manager_client.list_clusters(project_id_2, zone)
```

### Cloud Dataproc

- [google-cloud-dataproc README](google-cloud-dataproc/README.md)
- [google-cloud-dataproc API documentation](https://googleapis.dev/ruby/google-cloud-dataproc/latest)
- [google-cloud-dataproc on RubyGems](https://rubygems.org/gems/google-cloud-dataproc)
- [Google Cloud Dataproc documentation](https://cloud.google.com/dataproc/docs)

#### Quick Start

```sh
$ gem install google-cloud-dataproc
```

#### Preview

```ruby
require "google/cloud/dataproc"

cluster_controller_client = Google::Cloud::Dataproc::ClusterController.new
project_id_2 = project_id
region = "global"

# Iterate over all results.
cluster_controller_client.list_clusters(project_id_2, region).each do |element|
  # Process element.
end

# Or iterate over results one page at a time.
cluster_controller_client.list_clusters(project_id_2, region).each_page do |page|
  # Process each page at a time.
  page.each do |element|
    # Process element.
  end
end
```

### Data Loss Prevention

- [google-cloud-dlp README](google-cloud-dlp/README.md)
- [google-cloud-dlp API documentation](https://googleapis.dev/ruby/google-cloud-dlp/latest)
- [google-cloud-dlp on RubyGems](https://rubygems.org/gems/google-cloud-dlp)
- [Data Loss Prevention documentation](https://cloud.google.com/dlp/docs)

#### Quick Start

```sh
$ gem install google-cloud-dlp
```

#### Preview

```ruby
require "google/cloud/dlp"

dlp_service_client = Google::Cloud::Dlp.new
min_likelihood = :POSSIBLE
inspect_config = { min_likelihood: min_likelihood }
type = "text/plain"
value = "my phone number is 215-512-1212"
items_element = { type: type, value: value }
items = [items_element]
response = dlp_service_client.inspect_content(inspect_config, items)
```

### Dialogflow API

- [google-cloud-dialogflow README](google-cloud-dialogflow/README.md)
- [google-cloud-dialogflow API documentation](https://googleapis.dev/ruby/google-cloud-dialogflow/latest)
- [google-cloud-dialogflow on RubyGems](https://rubygems.org/gems/google-cloud-dialogflow)
- [Dialogflow API documentation](https://cloud.google.com/dialogflow-enterprise/docs/)

#### Quick Start

```sh
$ gem install google-cloud-dialogflow
```

### Stackdriver Error Reporting

- [google-cloud-error_reporting README](google-cloud-error_reporting/README.md)
- [google-cloud-error_reporting instrumentation documentation](./google-cloud-error_reporting/INSTRUMENTATION.md)
- [google-cloud-error_reporting on RubyGems](https://rubygems.org/gems/google-cloud-error_reporting)
- [Stackdriver Error Reporting documentation](https://cloud.google.com/error-reporting/docs)

#### Quick Start

```sh
$ gem install google-cloud-error_reporting
```

#### Preview

```ruby
require "google/cloud/error_reporting"

# Report an exception
begin
  fail "Boom!"
rescue => exception
  Google::Cloud::ErrorReporting.report exception
end
```

### Cloud Firestore

- [google-cloud-firestore README](google-cloud-firestore/README.md)
- [google-cloud-firestore API documentation](https://googleapis.dev/ruby/google-cloud-firestore/latest)
- [google-cloud-firestore on RubyGems](https://rubygems.org/gems/google-cloud-firestore)
- [Google Cloud Firestore documentation](https://cloud.google.com/firestore/docs)

#### Quick Start

```sh
$ gem install google-cloud-firestore
```

#### Preview

```ruby
require "google/cloud/firestore"

firestore = Google::Cloud::Firestore.new(
  project_id: "my-project",
  credentials: "/path/to/keyfile.json"
)

city = firestore.col("cities").doc("SF")
city.set({ name: "San Francisco",
           state: "CA",
           country: "USA",
           capital: false,
           population: 860000 })

firestore.transaction do |tx|
  new_population = tx.get(city).data[:population] + 1
  tx.update(city, { population: new_population })
end
```

### Cloud Key Management Service

- [google-cloud-kms README](google-cloud-kms/README.md)
- [google-cloud-kms API documentation](https://googleapis.dev/ruby/google-cloud-kms/latest)
- [google-cloud-kms on RubyGems](https://rubygems.org/gems/google-cloud-kms)
- [Google Cloud KMS documentation](https://cloud.google.com/kms/docs/)

#### Quick Start

```sh
$ gem install google-cloud-kms
```

#### Preview

```ruby
require "google/cloud/kms"

# Create a client for a project and given credentials
kms = Google::Cloud::Kms.new credentials: "/path/to/keyfile.json"

# Where to create key rings
key_ring_parent = kms.class.location_path "my-project", "us-central1"

# Create a new key ring
key_ring = kms.create_key_ring key_ring_parent, "my-ring", {}
puts "Created at #{Time.new key_ring.create_time.seconds}"

# Iterate over created key rings
kms.list_key_rings(key_ring_parent).each do |key_ring|
  puts "Found ring called #{key_ring.name}"
end
```

### Stackdriver Logging

- [google-cloud-logging README](google-cloud-logging/README.md)
- [google-cloud-logging API documentation](https://googleapis.dev/ruby/google-cloud-logging/latest)
- [google-cloud-logging on RubyGems](https://rubygems.org/gems/google-cloud-logging)
- [Stackdriver Logging documentation](https://cloud.google.com/logging/docs/)

#### Quick Start

```sh
$ gem install google-cloud-logging
```

#### Preview

```ruby
require "google/cloud/logging"

logging = Google::Cloud::Logging.new

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

### Cloud Natural Language API

- [google-cloud-language README](google-cloud-language/README.md)
- [google-cloud-language API documentation](https://googleapis.dev/ruby/google-cloud-language/latest)
- [google-cloud-language on RubyGems](https://rubygems.org/gems/google-cloud-language)
- [Google Cloud Natural Language API documentation](https://cloud.google.com/natural-language/docs)

#### Quick Start

```sh
$ gem install google-cloud-language
```

#### Preview

```ruby
require "google/cloud/language"

language = Google::Cloud::Language.new(
  project_id: "my-todo-project",
  credentials: "/path/to/keyfile.json"
)

content = "Star Wars is a great movie. The Death Star is fearsome."
document = language.document content
annotation = document.annotate

annotation.entities.count #=> 3
annotation.sentiment.score #=> 0.10000000149011612
annotation.sentiment.magnitude #=> 1.100000023841858
annotation.sentences.count #=> 2
annotation.tokens.count #=> 13
```

### Cloud OS Login

- [google-cloud-os_login README](google-cloud-os_login/README.md)
- [google-cloud-os_login API documentation](https://googleapis.dev/ruby/google-cloud-os_login/latest)
- [google-cloud-os_login on RubyGems](https://rubygems.org/gems/google-cloud-os_login)
- [Google Cloud DNS documentation](https://cloud.google.com/compute/docs/oslogin/rest/)

#### Quick Start

```sh
$ gem install google-cloud-os_login
```

### Phishing Protection

- [google-cloud-phishing_protection README](google-cloud-phishing_protection/README.md)
- [google-cloud-phishing_protection API documentation](https://googleapis.dev/ruby/google-cloud-phishing_protection/latest)
- [google-cloud-phishing_protection on RubyGems](https://rubygems.org/gems/google-cloud-phishing_protection)
- [Phishing Protection documentation](https://cloud.google.com/phishing-protection/docs/)

#### Quick Start

```sh
$ gem install google-cloud-phishing_protection
```

### Cloud Pub/Sub

- [google-cloud-pubsub README](google-cloud-pubsub/README.md)
- [google-cloud-pubsub API documentation](https://googleapis.dev/ruby/google-cloud-pubsub/latest)
- [google-cloud-pubsub on RubyGems](https://rubygems.org/gems/google-cloud-pubsub)
- [Google Cloud Pub/Sub documentation](https://cloud.google.com/pubsub/docs)

#### Quick Start

```sh
$ gem install google-cloud-pubsub
```

#### Preview

```ruby
require "google/cloud/pubsub"

pubsub = Google::Cloud::Pubsub.new(
  project_id: "my-todo-project",
  credentials: "/path/to/keyfile.json"
)

# Retrieve a topic
topic = pubsub.topic "my-topic"

# Publish a new message
msg = topic.publish "new-message"

# Retrieve a subscription
sub = pubsub.subscription "my-topic-sub"

# Create a subscriber to listen for available messages
subscriber = sub.listen do |received_message|
  # process message
  received_message.acknowledge!
end

# Start background threads that will call the block passed to listen.
subscriber.start

# Shut down the subscriber when ready to stop receiving messages.
subscriber.stop.wait!
```

### Recaptcha Enterprise

- [google-cloud-recaptcha_enterprise README](google-cloud-recaptcha_enterprise/README.md)
- [google-cloud-recaptcha_enterprise API documentation](https://googleapis.dev/ruby/google-cloud-recaptcha_enterprise/latest)
- [google-cloud-recaptcha_enterprise on RubyGems](https://rubygems.org/gems/google-cloud-recaptcha_enterprise)
- [Recaptcha Enterprise documentation](https://cloud.google.com/recaptcha-enterprise/docs/)

#### Quick Start

```sh
$ gem install google-cloud-recaptcha_enterprise
```

### Cloud Recommender API

- [google-cloud-recommender README](google-cloud-recommender/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-recommender/latest)
- [google-cloud-recommender on RubyGems](https://rubygems.org/gems/google-cloud-recommender/)

#### Quick Start

```sh
$ gem install google-cloud-recommender
```

### Cloud Redis API

- [google-cloud-redis README](google-cloud-redis/README.md)
- [google-cloud-redis API documentation](https://googleapis.dev/ruby/google-cloud-redis/latest)
- [google-cloud-redis on RubyGems](https://rubygems.org/gems/google-cloud-redis)
- [Cloud Redis API documentation](https://cloud.google.com/memorystore/docs/redis/)

#### Quick Start

```sh
$ gem install google-cloud-redis
```


### Cloud Resource Manager

- [google-cloud-resource_manager README](google-cloud-resource_manager/README.md)
- [google-cloud-resource_manager API documentation](https://googleapis.dev/ruby/google-cloud-resource_manager/latest)
- [google-cloud-resource_manager on RubyGems](https://rubygems.org/gems/google-cloud-resource_manager)
- [Google Cloud Resource Manager documentation](https://cloud.google.com/resource-manager/)

#### Quick Start

```sh
$ gem install google-cloud-resource_manager
```

#### Preview

```ruby
require "google/cloud/resource_manager"

resource_manager = Google::Cloud::ResourceManager.new

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

### Stackdriver Trace

- [google-cloud-trace README](google-cloud-trace/README.md)
- [google-cloud-trace instrumentation documentation](./google-cloud-trace/INSTRUMENTATION.md)
- [google-cloud-trace on RubyGems](https://rubygems.org/gems/google-cloud-trace)
- [Stackdriver Trace documentation](https://cloud.google.com/trace/docs/)

#### Quick Start

```sh
$ gem install google-cloud-trace
```

#### Preview

```ruby
require "google/cloud/trace"

trace = Google::Cloud::Trace.new

result_set = trace.list_traces Time.now - 3600, Time.now
result_set.each do |trace_record|
  puts "Retrieved trace ID: #{trace_record.trace_id}"
end
```

### Cloud Spanner API

- [google-cloud-spanner README](google-cloud-spanner/README.md)
- [google-cloud-spanner API documentation](https://googleapis.dev/ruby/google-cloud-spanner/latest)
- [google-cloud-spanner on RubyGems](https://rubygems.org/gems/google-cloud-spanner)
- [Google Cloud Spanner API documentation](https://cloud.google.com/spanner/docs)

#### Quick Start

```sh
$ gem install google-cloud-spanner
```

#### Preview

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

db.transaction do |tx|
  results = tx.execute "SELECT * FROM users"

  results.rows.each do |row|
    puts "User #{row[:id]} is #{row[:name]}"
  end
end
```

### Cloud Speech API

- [google-cloud-speech README](google-cloud-speech/README.md)
- [google-cloud-speech API documentation](https://googleapis.dev/ruby/google-cloud-speech/latest)
- [google-cloud-speech on RubyGems](https://rubygems.org/gems/google-cloud-speech)
- [Google Cloud Speech API documentation](https://cloud.google.com/speech/docs)

#### Quick Start

```sh
$ gem install google-cloud-speech
```

#### Preview

```ruby
require "google/cloud/speech"

speech = Google::Cloud::Speech.new

audio = speech.audio "path/to/audio.raw",
                     encoding: :raw, sample_rate: 16000
results = audio.recognize

result = results.first
result.transcript #=> "how old is the Brooklyn Bridge"
result.confidence #=> 0.9826789498329163
```

### Cloud Scheduler

- [Client Library Documentation][]
- [Product Documentation][]

## Quick Start
In order to use this library, you first need to go through the following
steps:

1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
2. [Enable billing for your project.](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
3. [Enable the Cloud Scheduler API.](https://console.cloud.google.com/apis/library/cloudscheduler.googleapis.com)
4. [Setup Authentication.](./google-cloud-scheduler/AUTHENTICATION.md)

### Installation
```
$ gem install google-cloud-scheduler
```

### Next Steps
- Read the [Client Library Documentation][] for Cloud Scheduler API
  to see other available methods on the client.
- Read the [Cloud Scheduler API Product documentation][Product Documentation]
  to learn more about the product and see How-to Guides.
- View this [repository's main README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md)
  to see the full list of Cloud APIs that we cover.

[Client Library Documentation]: https://googleapis.dev/ruby/google-cloud-scheduler/latest
[Product Documentation]: https://cloud.google.com/scheduler

## Enabling Logging

To enable logging for this library, set the logger for the underlying [gRPC](https://github.com/grpc/grpc/tree/master/src/ruby) library.
The logger that you set may be a Ruby stdlib [`Logger`](https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html) as shown below,
or a [`Google::Cloud::Logging::Logger`](https://googleapis.dev/ruby/google-cloud-logging/latest)
that will write logs to [Stackdriver Logging](https://cloud.google.com/logging/). See [grpc/logconfig.rb](https://github.com/grpc/grpc/blob/master/src/ruby/lib/grpc/logconfig.rb)
and the gRPC [spec_helper.rb](https://github.com/grpc/grpc/blob/master/src/ruby/spec/spec_helper.rb) for additional information.

Configuring a Ruby stdlib logger:

```ruby
require "logger"

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::WARN
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end
```

### Secret Manager API

- [google-cloud-secret_manager README](google-cloud-secret_manager/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-secret_manager/latest)
- [google-cloud-secret_manager on RubyGems](https://rubygems.org/gems/google-cloud-secret_manager/)

#### Quick Start

```sh
$ gem install google-cloud-secret_manager
```

### Cloud Security Center API

- [google-cloud-security_center README](google-cloud-security_center/README.md)
- [google-cloud-security_center API documentation](https://googleapis.dev/ruby/google-cloud-security_center/latest)
- [google-cloud-security_center on RubyGems](https://rubygems.org/gems/google-cloud-security_center)
- [Google Cloud Security Center API documentation](https://cloud.google.com/security-command-center/docs)

#### Quick Start

```sh
$ gem install google-cloud-security_center
```

### Cloud Storage

- [google-cloud-storage README](google-cloud-storage/README.md)
- [google-cloud-storage API documentation](https://googleapis.dev/ruby/google-cloud-storage/latest)
- [google-cloud-storage on RubyGems](https://rubygems.org/gems/google-cloud-storage)
- [Google Cloud Storage documentation](https://cloud.google.com/storage/docs)

#### Quick Start

```sh
$ gem install google-cloud-storage
```

#### Preview

```ruby
require "google/cloud/storage"

storage = Google::Cloud::Storage.new(
  project_id: "my-todo-project",
  credentials: "/path/to/keyfile.json"
)

bucket = storage.bucket "task-attachments"

file = bucket.file "path/to/my-file.ext"

# Download the file to the local file system
file.download "/tasks/attachments/#{file.name}"

# Copy the file to a backup bucket
backup = storage.bucket "task-attachment-backups"
file.copy backup, file.name
```

### Cloud Talent Solutions API

- [google-cloud-talent README](google-cloud-talent/README.md)
- [google-cloud-talent API documentation](https://googleapis.dev/ruby/google-cloud-talent/latest)
- [google-cloud-talent on RubyGems](https://rubygems.org/gems/google-cloud-talent/)
- [Google Cloud Talent Solutions documentation](https://cloud.google.com/talent-solution/docs)

#### Quick Start

```sh
$ gem install google-cloud-talent
```

#### Preview

```rb
 require "google/cloud/talent"

 require "google/cloud/talent"
 job_service_client = Google::Cloud::Talent::JobService.new(version: :v4beta1)
 formatted_parent = job_service_client.project_path("[PROJECT]")

 # TODO: Initialize `filter`:
 filter = ''
 # Iterate over all results.
 job_service_client.list_jobs(formatted_parent, filter).each do |element|
   # Process element.
 end

 # Or iterate over results one page at a time.
 job_service_client.list_jobs(formatted_parent, filter).each_page do |page|
   # Process each page at a time.
   page.each do |element|
     # Process element.
   end
 end
```

### Cloud Tasks API

- [google-cloud-tasks README](google-cloud-tasks/README.md)
- [google-cloud-tasks API documentation](https://googleapis.dev/ruby/google-cloud-tasks/latest)
- [google-cloud-tasks on RubyGems](https://rubygems.org/gems/google-cloud-tasks/)

#### Quick Start

```sh
$ gem install google-cloud-tasks
```

#### Preview

```rb
 require "google/cloud/tasks/v2beta2"

 cloud_tasks_client = Google::Cloud::Tasks::V2beta2.new
 formatted_parent = Google::Cloud::Tasks::V2beta2::CloudTasksClient.location_path("[PROJECT]", "[LOCATION]")

 # Iterate over all results.
 cloud_tasks_client.list_queues(formatted_parent).each do |element|
   # Process element.
 end

 # Or iterate over results one page at a time.
 cloud_tasks_client.list_queues(formatted_parent).each_page do |page|
   # Process each page at a time.
   page.each do |element|
     # Process element.
   end
 end
```

### Cloud Text To Speech API

#### Quick Start

```sh
$ gem install google-cloud-text_to_speech
```

#### Preview

```rb
require "google/cloud/text_to_speech"

text_to_speech_client = Google::Cloud::TextToSpeech.new
text = "test"
input = { text: text }
language_code = "en-US"
voice = { language_code: language_code }
audio_encoding = :MP3
audio_config = { audio_encoding: audio_encoding }
response = text_to_speech_client.synthesize_speech(input, voice, audio_config)
File.write("example.mp3", response.audio_content, mode: "wb")
```

### Cloud Translation API

- [google-cloud-translate README](google-cloud-translate/README.md)
- [google-cloud-translate API documentation](https://googleapis.dev/ruby/google-cloud-translate/latest)
- [google-cloud-translate on RubyGems](https://rubygems.org/gems/google-cloud-translate)
- [Google Cloud Translation API documentation](https://cloud.google.com/translation/docs)

#### Quick Start

```sh
$ gem install google-cloud-translate
```

#### Preview

```ruby
require "google/cloud/translate"

translate = Google::Cloud::Translate.new

translation = translate.translate "Hello world!", to: "la"

puts translation #=> Salve mundi!

translation.from #=> "en"
translation.origin #=> "Hello world!"
translation.to #=> "la"
translation.text #=> "Salve mundi!"
```

### Cloud Vision API

- [google-cloud-vision README](google-cloud-vision/README.md)
- [google-cloud-vision API documentation](https://googleapis.dev/ruby/google-cloud-vision/latest)
- [google-cloud-vision on RubyGems](https://rubygems.org/gems/google-cloud-vision)
- [Google Cloud Vision API documentation](https://cloud.google.com/vision/docs)

#### Quick Start

```sh
$ gem install google-cloud-vision
```

#### Preview

```ruby
require "google/cloud/vision"

image_annotator_client = Google::Cloud::Vision::ImageAnnotator.new
gcs_image_uri = "gs://gapic-toolkit/President_Barack_Obama.jpg"
source = { gcs_image_uri: gcs_image_uri }
image = { source: source }
type = :FACE_DETECTION
features_element = { type: type }
features = [features_element]
requests_element = { image: image, features: features }
requests = [requests_element]
response = image_annotator_client.batch_annotate_images(requests)
```

### Stackdriver Monitoring API

- [google-cloud-monitoring README](google-cloud-monitoring/README.md)
- [google-cloud-monitoring API documentation](https://googleapis.dev/ruby/google-cloud-monitoring/latest)
- [google-cloud-monitoring on RubyGems](https://rubygems.org/gems/google-cloud-monitoring)
- [Google Cloud Monitoring API documentation](https://cloud.google.com/monitoring/docs)

#### Quick Start

```sh
$ gem install google-cloud-monitoring
```

#### Preview
```rb
 require "google/cloud/monitoring/v3"

 MetricServiceClient = Google::Cloud::Monitoring::V3::MetricServiceClient

 metric_service_client = MetricServiceClient.new
 formatted_name = MetricServiceClient.project_path(project_id)

 # Iterate over all results.
 metric_service_client.list_monitored_resource_descriptors(formatted_name).each do |element|
   # Process element.
 end

 # Or iterate over results one page at a time.
 metric_service_client.list_monitored_resource_descriptors(formatted_name).each_page do |page|
   # Process each page at a time.
   page.each do |element|
     # Process element.
   end
 end
```

### Cloud Video Intelligence API

- [google-cloud-video_intelligence README](google-cloud-video_intelligence/README.md)
- [google-cloud-video_intelligence API documentation](https://googleapis.dev/ruby/google-cloud-video_intelligence/latest)
- [google-cloud-video_intelligence on RubyGems](https://rubygems.org/gems/google-cloud-video_intelligence)
- [Google Cloud Video Intelligence API documentation](https://cloud.google.com/video-intelligence/docs)

#### Quick Start

```sh
$ gem install google-cloud-video_intelligence
```

#### Preview

```rb
 require "google/cloud/video_intelligence/v1beta2"

 video_intelligence_service_client = Google::Cloud::VideoIntelligence.new
 input_uri = "gs://cloud-ml-sandbox/video/chicago.mp4"
 features_element = :LABEL_DETECTION
 features = [features_element]

 # Register a callback during the method call.
 operation = video_intelligence_service_client.annotate_video(input_uri: input_uri, features: features) do |op|
   raise op.results.message if op.error?
   op_results = op.results
   # Process the results.

   metadata = op.metadata
   # Process the metadata.
 end

 # Or use the return value to register a callback.
 operation.on_done do |op|
   raise op.results.message if op.error?
   op_results = op.results
   # Process the results.

   metadata = op.metadata
   # Process the metadata.
 end

 # Manually reload the operation.
 operation.reload!

 # Or block until the operation completes, triggering callbacks on
 # completion.
 operation.wait_until_done!
```

### Web Risk API

- [google-cloud-webrisk README](google-cloud-webrisk/README.md)
- [google-cloud-automl API documentation](https://googleapis.dev/ruby/google-cloud-webrisk/latest)
- [google-cloud-webrisk on RubyGems](https://rubygems.org/gems/google-cloud-webrisk/)

#### Quick Start

```sh
$ gem install google-cloud-webrisk
```


## Supported Ruby Versions

These libraries are currently supported on Ruby 2.4+.

Google provides official support for Ruby versions that are actively supported
by Ruby Core—that is, Ruby versions that are either in normal maintenance or
in security maintenance, and not end of life. Currently, this means Ruby 2.4
and later. Older versions of Ruby _may_ still work, but are unsupported and not
recommended. See https://www.ruby-lang.org/en/downloads/branches/ for details
about the Ruby support schedule.

## Library Versioning

The libraries in this repository follow [Semantic Versioning](http://semver.org/).

Note that different libraries may be released at different support quality
levels:

**GA**: Libraries defined at the GA (general availability) quality level, indicated by a version number greater than or equal to 1.0, are stable. The code surface will not change in backwards-incompatible ways unless absolutely necessary (e.g. because of critical security issues), or unless accompanying a semver-major version update (such as version 1.x to 2.x.) Issues and requests against GA libraries are addressed with the highest priority.

**Beta**: Libraries defined at a Beta quality level, indicated by a version number less than 1.0, are expected to be mostly stable and we're working towards their release candidate. However, these libraries may get backwards-incompatible updates from time to time. We will still address issues and requests with a high priority.

## Contributing

Contributions to this library are always welcome and highly encouraged.

See [CONTRIBUTING](.github/CONTRIBUTING.md) for more information on how to get started.

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more information.

## License

This library is licensed under Apache 2.0. Full license text is
available in [LICENSE](LICENSE).

## Support

Please [report bugs at the project on Github](https://github.com/googleapis/google-cloud-ruby/issues).
Don't hesitate to [ask questions](http://stackoverflow.com/questions/tagged/google-cloud-platform+ruby) about the client or APIs on [StackOverflow](http://stackoverflow.com).
