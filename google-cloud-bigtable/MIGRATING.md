# Migrating to V3

V3 of `google-cloud-bigtable` will introduce a new API for admin operations. Current admin APIs are now deprecated as of version <2.x.x> and will be removed in version 3.0.0.  This document will explain how to migrate your application to V3.

You can access the new APIs in 2 ways:

1. Existing gem
    * All the new APIs are available in the existing `google-cloud-bigtable` gem, and are available through convenience modules.
    * If you’re an existing user of this gem, you can continue using it to directly access the new APIs. No importing changes are required.
2. New gem
    * The V3 APIs are also available in a separate gem, `google-cloud-bigtable-admin-v2`, that is dedicated for admin operations.
    * If you’re a new user that only wants to perform admin operations for Bigtable, you can consider using the new gem.


## What are admin & data operations?

### Admin operations
Any APIs that you use in Cloud Bigtable to administer tables and instances are admin operations. For these, you should start using the New APIs. See https://cloud.google.com/bigtable/docs/reference/admin/rpc for a list of Admin APIs. Some examples include:
* create or delete new instances & tables
* change schema of existing tables
* manage app profiles & IAM policies
* manage backups of tables & instances

### Data operations
The Data API is for reading and writing the contents of Bigtable tables associated with a cloud project.  These APIs are not changing and you should continue to use the existing APIs. See https://cloud.google.com/bigtable/docs/reference/data/rpc for a list of Data APIs. Some examples include:
* read & write data from tables
* import data into tables

## Overview of the new admin APIs
The below is a high level overview of the new admin APIs. The rest of the guide goes into the detail and helps you understand how to migrate your application to use new APIs.

* **Library Structure** - The existing client contains both data & admin APIs in the same namespace, while the new admin APIs are accessed through different namespaces. See the section Library Structure for more info.
* **Creating clients** - When creating a client object, you can customize its configuration in a block. See Creating Clients for more info.
* **Creation & Configuration** - The library uses a new configuration mechanism giving you closer control over endpoint address, network timeouts, and retry logic. See Client Configuration for more info.
* **Passing arguments** -  Previously, positional arguments were used to indicate required arguments. Now, all method arguments are keyword arguments, with documentation that specifies whether they are required or optional. Additionally, you can pass a proto request object instead of separate arguments. See the section Passing Arguments for more info.
* **Resource paths** - The new admin APIs include helper methods for generating the resource path strings passed to many calls. See Resource Path Helpers for more info.
* **API differences** - The APIs have breaking changes between the two clients. See Example RPCs for more info.
* **Errors** - All the RPCs errors in the client `google-cloud-bigtable-admin-v2` are of type `Google::Cloud::Error` and its subclasses. See the section Handling Errors for more info.

## Library Structure

### Older Admin APIs
In the older admin APIs, the RPCs are accessed through the namespace `Google::Cloud::Bigtable`.

### New Admin APIs
In the new admin APIs, the RPCs are available in the namespace `Google::Cloud::Bigtable::Admin::V2`, and are available in 2 modules:

* **Instance module** - All the operations related to instances are available in the module `Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin`.
* **Table module** - All the operations related to tables are available in the module `Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin`.

## Creating Clients

In the older admin APIs, to create a client object, you would use the `Google::Cloud::Bigtable.new` class method.

**Old**:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new
```

**New**:

There are several ways to create the admin client:

**1. Existing gem** - If you’re already using the `google-cloud-bigtable` gem, the recommended way is to use the convenience helper methods on the `Google::Cloud::Bigtable` module.

```rb
require "google/cloud/bigtable"

# To create an instance for Instance Admin client
instance_client = Google::Cloud::Bigtable.insance_admin

# To create an instance for Table Admin client
table_client = Google::Cloud::Bigtable.table_admin
```

**2. New gem** - If you prefer to instead use the `google-cloud-bigtable-admin-v2` gem, you can instantiate the clients through the below methods:

* For operations on instances, use the class method `Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client.new`
* For operations on tables, use the class method `Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new` 

For example, to create the client for instance operations:

```rb
require "google/cloud/bigtable/admin/v2"

# Create a client object. The client can be reused for multiple calls.
client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client.new
```

And to create the client for table operations:

```rb
require "google/cloud/bigtable/admin/v2"

# Create a client object. The client can be reused for multiple calls.
client = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new
```

See the section Client Configuration on how to configure clients.

## Client Configuration
You can customize the performance parameters or low-level behavior of the client (such as credentials, timeouts or instrumentation) through client configuration.

The configuration is optional, and is passed as a block during initialisation. If you do not provide it, or you do not set some configuration parameters, then the default configuration is used.

**Existing gem**:

If you’re using the existing gem, you can continue to configure the client in the usual way:
```rb
require "google/cloud/bigtable"

Google::Cloud::Bigtable.configure do |config|
  config.credentials = "path/to/keyfile.json"
  config.timeout = 10.0
end

instance_client = Google::Cloud::Bigtable.insance_admin
```

**New gem**:

If you’re using the new admin gem directly, to configure the client for new admin APIs:

```rb
client = ::Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client.new do |config|
  config.credentials = "path/to/keyfile.json"
 config.timeout = 10.0
end
```

Or globally for all clients:

```rb
::Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client.configure do |config|
  config.credentials = "path/to/keyfile.json"
 config.timeout = 10.0
end

client = ::Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client.new
```

Individual RPCs can also be configured independently. For example, to set the timeout for list_instances call:

```rb
Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.configure do |config|
  config.rpcs.list_instances.timeout = 10.0
end
```

Defaults for certain configurations can be set for all Bigtable versions globally:

```rb
Google::Cloud::Bigtable.configure do |config|
  config.credentials = "path/to/keyfile.json"
  config.timeout = 10.0
end
```

## Passing Arguments

In the existing client, required arguments would be passed as positional method arguments, while most optional arguments would be passed as keyword arguments.

Using the new API, all RPC arguments are passed as keyword arguments, regardless of whether they are required or optional.

For example:

**Old**:

```rb
client = Google::Cloud::Bigtable.new

instance = client.instance "my-instance"
```

**New**:

```rb
client = Google::Cloud::Bigtable.instance_admin

name = client.instance_path "my-instance"

result = client.get_instance name: name
```

In the new API, it is also possible to pass a request object, either as a hash or as a protocol buffer, as shown below:

```rb
client = Google::Cloud::Bigtable.instance_admin

name = client.instance_path "my-instance"

request = Google::Cloud::Bigtable::Admin::V2::GetInstanceRequest.new(
  name: name
)

result = client.get_instance request
```

## Resource Path Helpers

The new client includes helper methods for generating the resource path strings passed to many calls.

For example, you can access the location_path as shown below:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

# Call the helper on the client instance, and use keyword arguments
parent = client.location_path project: "my-project", location: "-"

result = client.list_instances parent: parent
```

Alternatively, you can use the paths module as a convenience module, as shown below:

```rb
# Bring the path helper methods into the current class
include Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Paths

def list_instances
  client = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client.new

  # Call the included helper method
  parent = location_path project: "my-project", location: "-"

  response = client.list_instances parent: parent
end
```

## Handling Errors
In the existing client, the RPC errors are of type `Google::Cloud:Error` (and its subclasses), and `Google::Cloud::Bigtable` (and its subclasses).

In the new API, all the RPCs errors are exclusively of type `Google::Cloud::Error` and its subclasses.

## Example RPCs in new admin APIs


### BigTable Instance Admin

#### Create Instance

**Old**
```rb
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

job = bigtable.create_instance(
  "my-instance",
  display_name: "Instance for user data",
  labels: { "env" => "dev" }
) do |clusters|
  clusters.add "test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD
end

job.done? #=> false

# To block until the operation completes.
job.wait_until_done!
job.done? #=> true

if job.error?
  status = job.error
else
  instance = job.instance
end
```

**New**

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

# Call the create_instance method.
result = client.create_instance (
  parent: client.project_path,
  instance_id: 'my-instance',
  instance: {
    display_name: 'Instance for user data',
    labels: {'env' => 'dev'}
  },
  clusters: {
    name: 'test-cluster',
    location: 'us-east1-b',
    serve_nodes: 3,
    default_storage_type: :SSD
  }
)

# The returned object is of type Gapic::Operation. You can use it to
# check the status of an operation, cancel it, or wait for results.
# Here is how to wait for a response.
result.wait_until_done! timeout: 60

if result.error?
  puts result.error
else
  response = result.response
  puts response.instance
end
```

#### List Instances

Old:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

client.instances.all do |instance|
  puts "Instance: #{instance.instance_id}"
end
```

New:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

result = client.list_instances parent: client.project_path

# The returned object is of type Google::Cloud::Bigtable::Admin::V2::ListInstancesResponse.
p result
```

#### Get Instance

Old:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
instance = client.instance instance_id
puts "Get Instance id: #{instance.instance_id}"
```

New:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

result = client.get_instance parent: client.instance_path

# The returned object is of type ::Google::Cloud::Bigtable::Admin::V2::Instance.
p result
```

#### Partially update Instance

Old:

```
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

instance = client.instance "my-instance"
instance.display_name = "My app dev instance"
instance.labels = { env: "dev", data: "users" }
job = instance.save

job.done? #=> false

# Reload job until completion.
job.wait_until_done!
job.done? #=> true

if job.error?
  puts job.error
else
  instance = job.instance
  puts instance.name
  puts instance.labels
end
```

New:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

result = client.partial_update_instance (
  instance: {
    display_name: 'My app dev instance',
    lables: { env: "dev", data: "users" }
  }
)

# The returned object is of type Gapic::Operation. You can use it to
# check the status of an operation, cancel it, or wait for results.
# Here is how to wait for a response.
result.wait_until_done! timeout: 60

if result.error?
  puts result.error
else
  response = result.response
  puts result.instance.name
  puts result.instance.labels
end
```

#### Delete Instance

Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
instance = client.instance instance_id

instance.delete
```

New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

# instance_id = "my-instance"
name = client.instance_path instance_id

result = client.delete_instance name: name

# The returned object is of type Google::Protobuf::Empty.
p result
```

#### Create Cluster

Old:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
instance = client.instance instance_id

# cluster_id       = "my-cluster"
# cluster_location = "us-east1-b"
job = instance.create_cluster(
  cluster_id,
  cluster_location,
  nodes: 3,
  storage_type: :SSD
)

job.wait_until_done!
cluster = job.cluster
```

New:

```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

# Call the create_cluster method.
result = client.create_cluster(
  parent: client.instance_path "my-instance",
  cluster_id: 'my-cluster',
  cluster: {
    location: 'us-east1-b',
    serve_nodes: 3,
    default_storage_type: :SSD
  }
)

# The returned object is of type Gapic::Operation. You can use it to
# check the status of an operation, cancel it, or wait for results.
# Here is how to wait for a response.
result.wait_until_done! timeout: 60

if result.error?
  puts result.error
else
  response = result.response
  puts response.cluster
end
```

#### List clusters

Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
bigtable.instance(instance_id).clusters.all do |cluster|
  puts "Cluster: #{cluster.cluster_id}"
end
```

New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

parent = client.instance_path "my-instance"

result = client.list_clusters parent: parent

# The returned object is of type Google::Cloud::Bigtable::Admin::V2::ListClustersResponse.
p result
```

#### Get cluster
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
instance = client.instance instance_id

# cluster_id = "my-cluster"
cluster = instance.cluster cluster_id

p cluster
```

New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

name = client.cluster_path "my-instance", "my-cluster"

result = client.get_cluster name: name

# The returned object is of type Google::Cloud::Bigtable::Admin::V2::Cluster.
p result
```


#### Update cluster
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

instance = client.instance "my-instance"
cluster = instance.cluster "my-cluster"
cluster.nodes = 3
job = cluster.save

job.done? #=> false

# To block until the operation completes.
job.wait_until_done!
job.done? #=> true

if job.error?
  status = job.error
else
  cluster = job.cluster
end
```

New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

# Create a request. To set request fields, pass in keyword arguments.
request = Google::Cloud::Bigtable::Admin::V2::Cluster.new

# Call the update_cluster method.
result = client.update_cluster request

# The returned object is of type Gapic::Operation. You can use it to
# check the status of an operation, cancel it, or wait for results.
# Here is how to wait for a response.
result.wait_until_done! timeout: 60

if result.error?
  puts result.error
else
  response = result.response
  puts response.cluster
end
```


#### Delete cluster
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
instance = client.instance instance_id

# cluster_id = "my-cluster"
cluster = instance.cluster cluster_id

cluster.delete
```

New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.instance_admin

name = client.cluster_path "my-instance", "my-cluster"

result = client.delete_cluster name: name

# The returned object is of type Google::Protobuf::Empty.
p result
```



### Bigtable Table Admin

#### Create table
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

if client.table(instance_id, table_id).exists?
  puts "#{table_id} is already exists."
else
  table = client.create_table instance_id, table_id do |column_families|
    column_families.add(
      column_family,
      Google::Cloud::Bigtable::GcRule.max_versions(1)
    )
  end
end
```

New:
```rb
require "google/cloud/bigtable/admin/v2"

client = Google::Cloud::Bigtable.table_admin

result = client.create_table (
  parent: client.instance_path "my-instance",
  table_id: "my-table",
  table: {
    name: "table-name"
  }
)

# The returned object is of type Google::Cloud::Bigtable::Admin::V2::Table.
p result
```


#### List tables
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# instance_id = "my-instance"
client.tables(instance_id).all.each do |t|
  puts "Table: #{t.name}"
end
```

New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.table_admin

parent = client.instance_path "my-instance"

result = client.list_tables parent: parent

# The returned object is of type Gapic::PagedEnumerable. You can iterate
# over elements, and API calls will be issued to fetch pages as needed.
result.each do |item|
  # Each element is of type ::Google::Cloud::Bigtable::Admin::V2::Table.
  p item
end
```


#### Get table
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# table_id = "my-table"
table = client.table table_id
```
New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.table_admin

name = client.table_path "my-instance", "my-table"

result = client.get_table name: name

# The returned object is of type Google::Cloud::Bigtable::Admin::V2::Table.
p result
```


#### Delete table
Old:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.new

# table_id = "my-table"
table = client.table table_id

table.delete
```
New:
```rb
require "google/cloud/bigtable"

client = Google::Cloud::Bigtable.table_admin

name = client.table_path "my-instance", "my-table"

result = client.delete_table name: name

# The returned object is of type Google::Protobuf::Empty.
p result
```
