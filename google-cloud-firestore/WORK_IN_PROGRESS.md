We are implementing the Query Explanation feature for Google Cloud Firestore

Explanation of requirements:
- Query explanation is a new parameter `explain_options` in RunQueryRequest.
- This parameter is a message that has only one field: a boolean `analyze`.
- The `RunQuery` is a streaming method, which will always return a stream of `RunQueryResponse`.
- However if `explain_options` are set (not nil), the last `RunQueryResponse` will have a non-nil `explain_metrics` field.
- This `explain_metrics` field needs to be surfaced to the end-user in a user-friendly way.
- The `RunQueryResponse` messages do not have to contain the query results data (firestore entities). 
- In fact, if `analyze` is not set to `true`, the stream will not have any entities -- just a `RunQueryResponse` with planning-stage `explain_metrics`.
- If `analyze` is set to `true`, the actual query results will be returned in the stream, *including* the `explain_metrics` in the last response in the stream.
- If `analyze` is set to `true`, that last response in the stream will have both planning-stage and execution-stage metrics.
- As with all changes, backward compatibility is of the paramount importance! Breaking changes are NOT allowed no matter what!

What have we done to implement the requirements:
- We have added the `explain_options` parameter to the `run_query` method of the `Service` class (`lib/google/cloud/firestore/service.rb`).
- We have added the `explain_options` field to the `Query` class (`lib/google/cloud/firestore/query.rb`)
- We have added the logic to set the `explain_options` field when building the `Query` via the `start_new_query` and `self.start` methods (`lib/google/cloud/firestore/query.rb`)
- We have added the `explain` method that sets the `explain_options` to the Query class. (`lib/google/cloud/firestore/query.rb`)
  - The requirements for `explain` is that (1) it can only be called once and (2) that it accepts an `analyze` parameter that is (3) strictly boolean and defaults to `false`
- We have modified the Query JSON serialization/deserialization methods `to_json` and `from_json` to serialize and deserialize `explain_options` (`lib/google/cloud/firestore/query.rb`)
- We have created a new type: `QueryRunResult` that inherits from `Enumerator` for backward compatibility reasons (`lib/google/cloud/firestore/query_run_result.rb`)
  - That is necessary since the `run` method of `Query` returns an `Enum` of `DocumentSnapshot`.
  - `QueryRunResult` takes a lambda (block) that returns an Enumerable of results, avoiding tight coupling with Query parameters
  - This allows Query to maintain control of its parameters and execution logic
  - There is an important implementation details around enum wrappers. Repeated calls to re-enumerate results (e.g. multiple calls to `first` or `to_a`) must result to repeated calls to the backend. Passing the lamba instead of results ensures that happens.
- We have made Query `get` (aka `run`) calls to return this new type (`lib/google/cloud/firestore/query.rb`)
- This new `QueryRunResult` type contains an `explain_metrics` public readable field, that will be filled with the ExplainMetrics from the last results in the enumeration. (`lib/google/cloud/firestore/query_run_result.rb`)
  - Since the stream cannot be read until the user reads it, that field starts as `nil` and is only filled when the end-user enumerates the whole result set.
- For backward compatibility reason, if `limit_type` is set to `:last` the results are reversed in the client. `QueryRunResult` implements this behavior. (`lib/google/cloud/firestore/query_run_result.rb`)

What have we done for testing:
- Added tests to make sure that new `QueryRunResult` acts as a default enum and does not read the whole result set eagerly (`test/google/cloud/firestore/query/get_test.rb`)
  - A special testing class `ExplodingEnum` is added to helpers for this (`test/helper.rb`)
- Added one generic "gets query with explain" test (`test/google/cloud/firestore/query/get_test.rb`) which requires modifying a test result set to add Explanations
- Added comprehensive tests for the `explain` feature in `explain_test.rb`:
  - Tests ensuring that explain works with various query modifiers (order_by, limit, cursors)
  - Tests verifying that explain works correctly regardless of method call order (before or after other modifiers)
  - Tests for proper serialization/deserialization of query with explain options (both analyze: true and false)
  - Tests ensuring parameter validation works correctly (analyze must be boolean, explain can only be called once)
  - Tests for complex queries with explain option in get_test.rb
- Added acceptance tests for the `explain` feature in `acceptance/firestore/aggregate_query_explain_test.rb`

TODO: run the acceptance tests in `acceptance/firestore/aggregate_query_explain_test.rb`