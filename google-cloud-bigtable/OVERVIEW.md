# Cloud Bigtable

Cloud Bigtable is a petabyte-scale, fully managed NoSQL database service for
large analytical and operational workloads. Ideal for ad tech, fintech, and IoT,
Cloud Bigtable offers consistent sub-10ms latency. Replication provides higher
availability, higher durability, and resilience in the face of zonal failures.
Cloud Bigtable is designed with a storage engine for machine learning
applications and provides easy integration with open source big data tools.

For more information about Cloud Bigtable, read the [Cloud Bigtable
Documentation](https://cloud.google.com/bigtable/docs/).

The goal of google-cloud is to provide an API that is comfortable to Rubyists.
Your authentication credentials are detected automatically in Google Cloud
Platform (GCP), including Google Compute Engine (GCE), Google Kubernetes Engine
(GKE), Google App Engine (GAE), Google Cloud Functions (GCF) and Cloud Run. In
other environments you can configure authentication easily, either directly in
your code or via environment variables. Read more about the options for
connecting in the [Authentication Guide](AUTHENTICATION.md).

## Creating instances and clusters

When you first use Cloud Bigtable, you must create an instance, which is an
allocation of resources that are used by Cloud Bigtable. When you create an
instance, you must specify at least one cluster. Clusters describe where your
data is stored and how many nodes are used for your data.

Use {Google::Cloud::Bigtable::Project#create_instance Project#create_instance}
to create an instance. The following example creates a production instance with
one cluster and three nodes:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

job = bigtable.create_instance(
  "my-instance",
  display_name: "Instance for user data",
  labels: { "env" => "dev"}
) do |clusters|
  clusters.add("test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD)
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

You can also create a low-cost development instance for development and testing,
with performance limited to the equivalent of a one-node cluster. There are no
monitoring or throughput guarantees; replication is not available; and the SLA
does not apply. When creating a development instance, you do not specify `nodes`
for your clusters:

 ```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

job = bigtable.create_instance(
  "my-instance",
  display_name: "Instance for user data",
  type: :DEVELOPMENT,
  labels: { "env" => "dev"}
) do |clusters|
  clusters.add("test-cluster", "us-east1-b") # nodes not allowed
end

job.done? #=> false

# Reload job until completion.
job.wait_until_done!
job.done? #=> true

if job.error?
  status = job.error
else
  instance = job.instance
end
 ```

You can upgrade a development instance to a production instance at any time.

## Creating tables

Cloud Bigtable stores data in massively scalable tables, each of which is a
sorted key/value map. The table is composed of rows, each of which typically
describes a single entity, and columns, which contain individual values for each
row. Each row is indexed by a single row key, and columns that are related to
one another are typically grouped together into a column family. Each column is
identified by a combination of the column family and a column qualifier, which
is a unique name within the column family.

Each row/column intersection can contain multiple cells, or versions, at
different timestamps, providing a record of how the stored data has been altered
over time. Cloud Bigtable tables are sparse; if a cell does not contain any
data, it does not take up any space.

Use {Google::Cloud::Bigtable::Project#create_table Project#create_table} or
{Google::Cloud::Bigtable::Instance#create_table Instance#create_table} to
create a table:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.create_table("my-instance", "my-table")
puts table.name
```

When you create a table, you may specify the column families to use in the
table, as well as a list of row keys that will be used to initially split the
table into several tablets (tablets are similar to HBase regions):

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

initial_splits = ["user-00001", "user-100000", "others"]
table = bigtable.create_table("my-instance", "my-table", initial_splits: initial_splits) do |cfm|
  cfm.add('cf1', gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5))
  cfm.add('cf2', gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600))

  gc_rule = Google::Cloud::Bigtable::GcRule.union(
    Google::Cloud::Bigtable::GcRule.max_age(1800),
    Google::Cloud::Bigtable::GcRule.max_versions(3)
  )
  cfm.add('cf3', gc_rule: gc_rule)
end

puts table
```

You may also add, update, and delete column families later by passing a block to
{Google::Cloud::Bigtable::Table#column_families Table#column_families}:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.table("my-instance", "my-table", perform_lookup: true)

table.column_families do |cfm|
  cfm.add "cf4", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600)
  cfm.add "cf5", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5)

  rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
  rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
  rule_union = Google::Cloud::Bigtable::GcRule.union(rule_1, rule_2)
  cfm.update "cf2", gc_rule: rule_union

  cfm.delete "cf3"
end

puts table.column_families["cf3"] #=> nil
```

## Writing data

The {Google::Cloud::Bigtable::Table Table} class allows you to perform the
following types of writes:

* Simple writes
* Increments and appends
* Conditional writes
* Batch writes

See [Cloud Bigtable writes](https://cloud.google.com/bigtable/docs/writes) for
detailed information about writing data.

### Simple writes

Use {Google::Cloud::Bigtable::Table#mutate_row Table#mutate_row} to make
one or more mutations to a single row:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.table("my-instance", "my-table")

entry = table.new_mutation_entry("user-1")
entry.set_cell(
  "cf1",
  "field1",
  "XYZ",
  timestamp: (Time.now.to_f * 1000000).round(-3) # microseconds
).delete_cells("cf2", "field02")

table.mutate_row(entry)
```

### Increments and appends

If you want to append data to an existing value or increment an existing numeric
value, use
{Google::Cloud::Bigtable::Table#read_modify_write_row Table#read_modify_write_row}:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new
table = bigtable.table("my-instance", "my-table")

rule_1 = table.new_read_modify_write_rule("cf", "field01")
rule_1.append("append-xyz")

rule_2 = table.new_read_modify_write_rule("cf", "field01")
rule_2.increment(1)

row = table.read_modify_write_row("user01", [rule_1, rule_2])

puts row.cells
```

Do not use `read_modify_write_row` if you are using an app profile that has
multi-cluster routing. (See
{Google::Cloud::Bigtable::AppProfile#routing_policy AppProfile#routing_policy}.)

### Conditional writes

To check a row for a condition and then, depending on the result, write data to
that row, use
{Google::Cloud::Bigtable::Table#check_and_mutate_row Table#check_and_mutate_row}:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new
table = bigtable.table("my-instance", "my-table")

predicate_filter = Google::Cloud::Bigtable::RowFilter.key("user-10")
on_match_mutations = Google::Cloud::Bigtable::MutationEntry.new
on_match_mutations.set_cell(
  "cf1",
  "field1",
  "XYZ",
  timestamp: (Time.now.to_f * 1000000).round(-3) # microseconds
).delete_cells("cf2", "field02")

otherwise_mutations = Google::Cloud::Bigtable::MutationEntry.new
otherwise_mutations.delete_from_family("cf3")

predicate_matched = table.check_and_mutate_row(
  "user01",
  predicate_filter,
  on_match: on_match_mutations,
  otherwise: otherwise_mutations
)

if predicate_matched
  puts "All predicates matched"
end
```

Do not use `check_and_mutate_row` if you are using an app profile that has
multi-cluster routing. (See
{Google::Cloud::Bigtable::AppProfile#routing_policy AppProfile#routing_policy}.)

### Batch writes

You can write more than one row in a single RPC using
{Google::Cloud::Bigtable::Table#mutate_rows Table#mutate_rows}:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.table("my-instance", "my-table")

entries = []
entries << table.new_mutation_entry("row-1").set_cell("cf1", "field1", "XYZ")
entries << table.new_mutation_entry("row-2").set_cell("cf1", "field1", "ABC")
responses = table.mutate_rows(entries)

responses.each do |response|
  puts response.status.description
end
```

Each entry in the request is atomic, but the request as a whole is not. As shown
above, Cloud Bigtable returns a list of responses corresponding to the entries.

## Reading data

The {Google::Cloud::Bigtable::Table Table} class also enables you to read data.

Use {Google::Cloud::Bigtable::Table#read_row Table#read_row} to read a single
row by key:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new
table = bigtable.table("my-instance", "my-table")

row = table.read_row("user-1")
```

If desired, you can apply a filter:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new
table = bigtable.table("my-instance", "my-table")

filter = Google::Cloud::Bigtable::RowFilter.cells_per_row(3)

row = table.read_row("user-1", filter: filter)
```

For multiple rows, the
{Google::Cloud::Bigtable::Table#read_rows Table#read_rows} method streams back
the contents of all requested rows in key order:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new
table = bigtable.table("my-instance", "my-table")

table.read_rows(keys: ["user-1", "user-2"]).each do |row|
  puts row
end
```

Instead of specifying individual keys (or a range), you can often just use a
filter:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new
table = bigtable.table("my-instance", "my-table")

filter = table.filter.key("user-*")
# OR
# filter = Google::Cloud::Bigtable::RowFilter.key("user-*")

table.read_rows(filter: filter).each do |row|
  puts row
end
```

## Deleting rows, tables, and instances

Use {Google::Cloud::Bigtable::Table#drop_row_range Table#drop_row_range} to
delete some or all of the rows in a table:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

table = bigtable.table("my-instance", "my-table")

# Delete rows using row key prefix.
table.drop_row_range(row_key_prefix: "user-100")

# Delete all data With timeout
table.drop_row_range(delete_all_data: true, timeout: 120) # 120 seconds.
```

Delete tables and instances using
{Google::Cloud::Bigtable::Table#delete Table#delete} and
{Google::Cloud::Bigtable::Instance#delete Instance#delete}, respectively:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new

instance = bigtable.instance("my-instance")
table = instance.table("my-table")

table.delete

instance.delete
```

## Additional information

Google Bigtable can be configured to use an emulator or to enable gRPC's
logging. To learn more, see the [Emulator guide](EMULATOR.md) and
[Logging guide](LOGGING.md).
