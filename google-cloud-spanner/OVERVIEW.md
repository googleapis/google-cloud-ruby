# Cloud Spanner

Cloud Spanner is a fully managed, mission-critical, relational database service
that offers transactional consistency at global scale, schemas, SQL (ANSI 2011
with extensions), and automatic, synchronous replication for high availability.

For more information about Cloud Spanner, read the [Cloud Spanner
Documentation](https://cloud.google.com/spanner/docs/).

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine
(GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run. In
other environments you can configure authentication easily, either directly in
your code or via environment variables. Read more about the options for
connecting in the [Authentication Guide](AUTHENTICATION.md).

## Creating instances

When you first use Cloud Spanner, you must create an instance, which is an
allocation of resources that are used by Cloud Spanner databases. When you
create an instance, you choose where your data is stored and how many nodes are
used for your data. (For more information, see [Configuration
Guide](https://googleapis.dev/ruby/stackdriver/latest/file.INSTRUMENTATION_CONFIGURATION.html).

Use {Google::Cloud::Spanner::Admin::Instance#instance_admin
Client#create_instance} to create an instance:

```ruby
require "google/cloud/spanner"

instance_admin_client = \
  Google::Cloud::Spanner::Admin::Instance.instance_admin project_id: "my-project"

project_path = \
  instance_admin_client.project_path project: "my-project"
config_path = \
  instance_admin_client.instance_config_path project: "my-project",
  instance_config: "regional-us-central1"
instance_path = \
  instance_admin_client.instance_path project: "my-project",
  instance: "my-instance"

job = instance_admin_client.create_instance parent: project_path,
  instance_id: "my-instance",
  instance: Google::Cloud::Spanner::Admin::Instance::V1::Instance.new({
    name: instance_path
    display_name: "My Instance",
    config: config_path,
    node_count: 5,
    labels: { "production": :env }
  })

job.wait_until_done!
instance = job.results
```

## Creating databases

Now that you have created an instance, you can create a database. Cloud
Spanner databases hold the tables and indexes that allow you to read and
write data. You may create multiple databases in an instance.

Use {Google::Cloud::Spanner::Admin::Database#database_admin
Client#create_database} to create a database:

```ruby
require "google/cloud/spanner"

db_admin_client = \
  Google::Cloud::Spanner::Admin::Database.database_admin project_id: "my-project"

instance_path = \
  db_admin_client.instance_path project: "my-project", instance: "my-instance"

job = db_admin_client.create_database parent: instance_path,
  create_statement: "CREATE DATABASE my-database",

job.wait_until_done!
database = job.results
```

## Updating database schemas

Cloud Spanner supports schema updates to a database while the database
continues to serve traffic. Schema updates do not require taking the
database offline and they do not lock entire tables or columns; you can
continue writing data to the database during the schema update.

Use {Google::Cloud::Spanner::Admin::Database#database_admin
Client#update_database_ddl} to execute one or more statements in Cloud Spanner's
Data Definition Language (DDL):

```ruby
require "google/cloud/spanner"

db_admin_client = \
  Google::Cloud::Spanner::Admin::Database.database_admin project_id: "my-project"

db_path = db_admin_client.database_path project: "my-project",
                                        instance: "my-instance",
                                        database: "my-database"
add_users_table_sql = %q(
  CREATE TABLE users (
    id INT64 NOT NULL,
    username STRING(25) NOT NULL,
    name STRING(45) NOT NULL,
    email STRING(128),
  ) PRIMARY KEY(id)
)

job = db_admin_client.update_database_ddl database: db_path,
                                          statements: [add_users_table_sql]

job.wait_until_done!
database = job.results
```

## Creating clients

In order to read and/or write data, you must create a data client. You can think
of a client as a database connection: All of your interactions with Cloud
Spanner data must go through a client. Typically you create a client when your
application starts up, then you re-use that client to read, write, and execute
transactions.

Use {Google::Cloud::Spanner::Project#client Project#client} to create a client:

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

results = db.execute "SELECT 1"

results.rows.each do |row|
  puts row
end
```

## Writing data

You write data using your client object. The client object supports various
mutation operations, as well as combinations of inserts, updates, deletes, etc.,
that can be applied atomically to different rows and/or tables in a database.

Use {Google::Cloud::Spanner::Client#commit Client#commit} to execute various
mutations atomically at a single logical point in time. All changes are
accumulated in memory until the block completes. Unlike
{Google::Cloud::Spanner::Client#transaction Client#transaction}, which can also
perform reads, this operation accepts only mutations and makes a single API
request.

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

db.commit do |c|
  c.update "users", [{ id: 1, username: "charlie94", name: "Charlie" }]
  c.insert "users", [{ id: 2, username: "harvey00", name: "Harvey" }]
end
```

## Querying data using SQL

Cloud Spanner supports a native SQL interface for reading data that is available
through {Google::Cloud::Spanner::Client#execute Client#execute}:

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

results = db.execute "SELECT * FROM users"

results.rows.each do |row|
  puts "User #{row[:id]} is #{row[:name]}"
end
```

## Reading data using the read method

In addition to Cloud Spanner's SQL interface, Cloud Spanner also supports a read
interface. Use the {Google::Cloud::Spanner::Client#read Client#read} method to
read rows from the database, and use its `keys` option to pass unique
identifiers as both lists and ranges:

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

results = db.read "users", [:id, :name], keys: 1..5

results.rows.each do |row|
  puts "User #{row[:id]} is #{row[:name]}"
end
```

## Using read-write transactions

When an operation might write data depending on values it reads, you should use
a read-write transaction to perform the reads and writes atomically.

Suppose that sales of `Albums(1, 1)` are lower than expected and you want to
move $200,000 from the marketing budget of `Albums(2, 2)` to it, but only if the
budget of `Albums(2, 2)` is at least $300,000.

Use {Google::Cloud::Spanner::Client#transaction Client#transaction} to execute
both reads and writes atomically at a single logical point in time. All changes
are accumulated in memory until the block completes. Transactions will be
automatically retried when possible. This operation makes separate API requests
to begin and commit the transaction.

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

db.transaction do |tx|
  # Read the second album budget.
  second_album_result = tx.read "Albums", ["marketing_budget"],
                                keys: [[2, 2]], limit: 1
  second_album_row = second_album_result.rows.first
  second_album_budget = second_album_row.values.first

  transfer_amount = 200000

  if second_album_budget < 300000
    # Raising an exception will automatically roll back the transaction.
    raise "The second album doesn't have enough funds to transfer"
  end

  # Read the first album's budget.
  first_album_result = tx.read "Albums", ["marketing_budget"],
                                keys: [[1, 1]], limit: 1
  first_album_row = first_album_result.rows.first
  first_album_budget = first_album_row.values.first

  # Update the budgets.
  second_album_budget -= transfer_amount
  first_album_budget += transfer_amount
  puts "Setting first album's budget to #{first_album_budget} and the " \
       "second album's budget to #{second_album_budget}."

  # Update the rows.
  rows = [
    {singer_id: 1, album_id: 1, marketing_budget: first_album_budget},
    {singer_id: 2, album_id: 2, marketing_budget: second_album_budget}
  ]
  tx.update "Albums", rows
end
```

## Using read-only transactions

Suppose you want to execute more than one read at the same timestamp. Read-only
transactions observe a consistent prefix of the transaction commit history, so
your application always gets consistent data. Because read-only transactions are
much faster than locking read-write transactions, we strongly recommend that you
do all of your transaction reads in read-only transactions if possible.

Use a {Google::Cloud::Spanner::Snapshot Snapshot} object to execute statements
in a read-only transaction. The snapshot object is available via a block
provided to {Google::Cloud::Spanner::Client#snapshot Client#snapshot}:

```ruby
require "google/cloud/spanner"

spanner = Google::Cloud::Spanner.new

db = spanner.client "my-instance", "my-database"

db.snapshot do |snp|
  results_1 = snp.execute "SELECT * FROM users"
  results_1.rows.each do |row|
    puts "User #{row[:id]} is #{row[:name]}"
  end

  # Perform another read using the `read` method. Even if the data
  # is updated in-between the reads, the snapshot ensures that both
  # return the same data.
  results_2 = db.read "users", [:id, :name]
  results_2.rows.each do |row|
    puts "User #{row[:id]} is #{row[:name]}"
  end
end
```

## Deleting databases

Use {Google::Cloud::Spanner::Admin::Database#database_admin
Client#drop_database} to delete a database:

```ruby
require "google/cloud/spanner"

db_admin_client = \
  Google::Cloud::Spanner::Admin::Database.database_admin project_id: "my-project"

db_path = db_admin_client.database_path project: "my-project",
                                        instance: "my-instance",
                                        database: "my-database"
db_admin_client.drop_database database: db_path
```

## Deleting instances

When you delete an instance, all databases within it are automatically deleted.
(If you only delete databases and not your instance, you will still incur
charges for the instance.)

Use {Google::Cloud::Spanner::Admin::Instance#instance_admin
Client#delete_instance} to delete an instance:

```ruby
require "google/cloud/spanner"

instance_admin_client = \
  Google::Cloud::Spanner::Admin::Instance.instance_admin project_id: "my-project"

instance_path = \
  instance_admin_client.instance_path project: "my-project",
                                      instance: "my-instance"

instance_admin_client.delete_instance name: instance_path
```

## Additional information

Cloud Spanner can be configured to use gRPC's logging. To learn more, see the
[Logging guide](LOGGING.md).
