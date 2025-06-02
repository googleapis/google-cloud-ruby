# Understanding Query Performance

Query Explain methods allows you receive detailed performance statistics on backend query execution. It functions like the `EXPLAIN` \[`ANALYZE`\] operation in relational database systems. The `explain` method, available on both `Query` and `AggregateQuery` objects, is the primary way to access this information. 

## Query#explain

The `explain` method on a `Query` instance allows you to retrieve planning and execution metrics for your standard document queries.

**Method Signature:** `explain(analyze: false, read_time: nil)`

*   `analyze` (Boolean, optional):
    *   `false` (default): Returns only planning-stage metrics. The query is not executed, and no documents are returned.
    *   `true`: Executes the query and returns both planning and execution-stage metrics, along with the actual query results (document snapshots).
*   `read_time` (Time, optional): This is same as `read_time` parameter on regular `Query.get` Reads documents as they were at the given time. This may not be older than 270 seconds. 

**Returns:** `Google::Cloud::Firestore::QueryExplainResult`

The `QueryExplainResult` object is enumerable and provides access to:
*   `explain_metrics`: A `Google::Cloud::Firestore::V1::ExplainMetrics` object containing plan summaries and, if `analyze: true`, execution statistics.
*   Document snapshots: If `analyze: true`, you can iterate over the `QueryExplainResult` to get the `DocumentSnapshot` objects returned by the query.

**Example:**

```ruby
require "google/cloud/firestore"

firestore = Google::Cloud::Firestore.new
query = firestore.col(:cities).where(:population, :>, 100000)

# Get only planning metrics
plan_only_result = query.explain
puts "Plan Summary: #{plan_only_result.explain_metrics.plan_summary}"

# Get planning, execution metrics, and results
full_explain_result = query.explain analyze: true
puts "Execution Stats: #{full_explain_result.explain_metrics.execution_stats}"
full_explain_result.each do |city_doc|
  puts "City: #{city_doc.document_id}"
end
```

## AggregateQuery#explain

Similarly, the `explain` method on an `AggregateQuery` instance provides performance insights for your aggregation queries (e.g., `count`, `sum`, `avg`).

**Method Signature:** `explain(analyze: false)`

*   `analyze` (Boolean, optional):
    *   `false` (default): Returns only planning-stage metrics. The aggregation query is not executed.
    *   `true`: Executes the aggregation query and returns both planning and execution-stage metrics, along with the `AggregateQuerySnapshot`.

**Returns:** `Google::Cloud::Firestore::AggregateQueryExplainResult`

The `AggregateQueryExplainResult` object provides access to:
*   `explain_metrics`: A `Google::Cloud::Firestore::V1::ExplainMetrics` object.
*   `snapshot`: An `AggregateQuerySnapshot` containing the aggregation result (e.g., the count value), available if `analyze: true` and the query yielded a result.

**Example:**

```ruby
require "google/cloud/firestore"

firestore = Google::Cloud::Firestore.new
aggregate_query = firestore.col(:cities).where(:population, :>, 100000).aggregate_query.add_count

# Get only planning metrics
plan_only_result = aggregate_query.explain
puts "Plan Summary: #{plan_only_result.explain_metrics.plan_summary}"

# Get planning, execution metrics, and results
full_explain_result = aggregate_query.explain analyze: true
puts "Execution Stats: #{full_explain_result.explain_metrics.execution_stats}"
puts "Total cities: #{full_explain_result.snapshot.get}"
```
