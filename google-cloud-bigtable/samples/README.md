<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Cloud Bigtable Ruby Samples

This directory contains samples for google-cloud-bigtable.

[Cloud Bigtable](https://cloud.google.com/bigtable/docs/) is Google&#x27;s NoSQL Big Data database service. It&#x27;s the same database that powers many core Google services, including Search, Analytics, Maps, and Gmail.

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Set Project ID

Next, set the *GOOGLE_CLOUD_PROJECT* environment variable to the project name
set in the
[Google Cloud Platform Developer Console](https://console.cloud.google.com):

    `export GOOGLE_CLOUD_PROJECT="YOUR-PROJECT-ID"`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run tests

Run the tests for these samples by running `bundle exec rake test`.

## Run samples

### Quickstart
The [Quick start](quickstart.rb) sample shows a basic usage of the Cloud Bigtable client library: reading rows from a table.

Follow the [cbt tutorial](https://cloud.google.com/bigtable/docs/quickstart-cbt) to install the cbt command line tool.
Here are the cbt commands to create a table, column family and add some data:
```
   cbt createtable my-table
   cbt createfamily my-table cf
   cbt set my-table "row-1" cf:field1=test-value
```

Run the quick start to read the row you just wrote using `cbt`:
```
   bundle exec ruby quickstart.rb
```
Expected output similar to:
```
  #<Google::Cloud::Bigtable::Row:0x007fc2fbc8ba70
   @cells=
    {"cf"=>
      [#<Google::Cloud::Bigtable::Row::Cell:0x007fc2fbc2f1f8
        @family="cf",
        @labels=[],
        @qualifier="field1",
        @timestamp=1527522606344000,
        @value="test-value">
      ]}
   @key="row-1">
```

### Hello World

View the [Hello World][hello_world.rb] sample to see a basic usage of
the Cloud Bigtable client library.

### Instance Admin

View the [source code][instanceadmin.rb].

[![Open in Cloud Shell][shell_img]](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/googleapis/google-cloud-ruby&page=editor&open_in_editor=google-cloud-bigtable/samples/instanceadmin.rb)

__Usage:__ `bundle exec ruby instanceadmin.rb --help`

```
bundle exec ruby instanceadmin.rb <command> <instance_id> <cluster_id>

COMMANDS:

  run          <instance_id> <cluster_id>   Creates an Instance(type: PRODUCTION) and run basic instance-operations
  add-cluster  <instance_id> <cluster_id>   Add Cluster
  del-cluster  <instance_id> <cluster_id>   Delete the Cluster
  del-instance <instance_id>                Delete the Instance
  dev-instance <instance_id>                Create Development Instance

Examples:
  bundle exec ruby instanceadmin.rb run <instance_id> <cluster_id>            Run instance operations
  bundle exec ruby instanceadmin.rb dev-instance <instance_id> <cluster_id>   Create Development Instance
  bundle exec ruby instanceadmin.rb del-instance <instance_id> <cluster_id>   Delete the Instance.
  bundle exec ruby instanceadmin.rb add-cluster <instance_id> <cluster_id>    Add Cluster
  bundle exec ruby instanceadmin.rb del-cluster <instance_id> <cluster_id>    Delete the Cluster

For more information, see https://cloud.google.com/bigtable/docs
```

### Table and column family management

View the [source code](tableadmin.rb).
This sample showcases the basic table / column family operations:
1. Create a table (if does not exist)
2. List tables in the current project
3. Retrieve table metadata
4. Create column families with supported garbage collection(GC) rules
5. List table column families and GC rules
6. Update a column family GC rule
7. Delete a column family
8. Delete a table

__Usage:__ `bundle exec ruby tableadmin.rb --help`

```
Commands:
  run    <instance_id> <table_id>   Create a table (if does not exist) and run basic table operations
  delete <instance_id> <table_id>   Delete table

Examples:
  bundle exec ruby tableadmin.rb run <instance_id> <table_id>     Create a table (if does not exist) and run basic table operations.
  bundle exec ruby tableadmin.rb delete <instance_id> <table_id>  Delete a table.

For more information, see https://cloud.google.com/bigtable/docs
```
