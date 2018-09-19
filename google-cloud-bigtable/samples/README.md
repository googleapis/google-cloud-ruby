<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Cloud Bigtable: RubySamples

[![Open in Cloud Shell][shell_img]][shell_link]

[Cloud Bigtable](https://cloud.google.com/bigtable/docs/) is Google&#x27;s NoSQL Big Data database service. It&#x27;s the same database that powers many core Google services, including Search, Analytics, Maps, and Gmail.

## Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Before you begin](#before-you-begin)
- [Samples](#samples)
  - [Hello World](#hello-world)
  - [Instances](#instances)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Before you begin

Before running the samples, make sure you've followed the steps in the
[Before you begin section](../README.md#before-you-begin) of the client
library's README.

## Samples

### Quickstart
The [Quick start](quickstart.rb) sample shows a basic usage of the Bigtable client library: reading rows from a table.

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

View the [Hello World][hello_world_directory] sample to see a basic usage of
the Bigtable client library.

### Instances

View the [source code][instances_0_code].

[![Open in Cloud Shell][shell_img]](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/googleapis/google-cloud-ruby&page=editor&open_in_editor=google-cloud-bigtable/samples/instances.rb,samples/README.md)

__Usage:__ `bundle exec ruby instances.rb --help`

```
bundle exec ruby instances.rb <command> <instance_id> <cluster_id>

COMMANDS:

  run          <instance_id> <cluster_id>   Creates an Instance(type: PRODUCTION) and run basic instance-operations
  add-cluster  <instance_id> <cluster_id>   Add Cluster
  del-cluster  <instance_id> <cluster_id>   Delete the Cluster
  del-instance <instance_id>                Delete the Instance
  dev-instance <instance_id>                Create Development Instance
  help                                      Display global or [command] help documentation


Examples:
  bundle exec ruby instances.rb run <instance_id> <cluster_id>            Run instance operations
  bundle exec ruby instances.rb dev-instance <instance_id> <cluster_id>   Create Development Instance
  bundle exec ruby instances.rb del-instance <instance_id> <cluster_id>   Delete the Instance.
  bundle exec ruby instances.rb add-cluster <instance_id> <cluster_id>    Add Cluster
  bundle exec ruby instances.rb del-cluster <instance_id> <cluster_id>    Delete the Cluster

For more information, see https://cloud.google.com/bigtable/docs
```

### Table / Column family management

View the [source code](tableadmin.rb).
This sample showcases the basic table / column family operations:
1. Create a table (if does not exist)
1. List tables in the current project
1. Retrieve table metadata
1. Create column families with supported garbage collection(GC) rules
1. List table column families and GC rules
1. Update a column family GC rule
1. Delete a column family
1. Delete a table

[![Open in Cloud Shell][shell_img]](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/googleapis/google-cloud-ruby&page=editor&page=editor&open_in_editor=google-cloud-bigtable/samples/tableadmin.rb,samples/README.md)

__Usage:__ `bundle exec ruby tableadmin.rb --help`

```
Commands:
  run    <instance_id> <table_id>   Create a table (if does not exist) and run basic table operations
  delete <instance_id> <table_id>   Delete table
  help   Display global or [command] help documentation

Examples:
  bundle exec ruby tableadmin.rb run <instance_id> <table_id>     Create a table (if does not exist) and run basic table operations.
  bundle exec ruby tableadmin.rb delete <instance_id> <table_id>  Delete a table. 

For more information, see https://cloud.google.com/bigtable/docs
```
[instances_0_docs]: https://cloud.google.com/bigtable/docs/
[instances_0_code]: instances.rb

[hello_world_directory]: hello-world

[shell_img]: //gstatic.com/cloudssh/images/open-btn.png
[shell_link]: https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/googleapis/google-cloud-ruby&page=editor&open_in_editor=google-cloud-bigtable/samples/README.md
