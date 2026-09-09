# BigQuery Benchmark
This directory contains benchmarks for BigQuery client.

## Usage

### Queries

`BIGQUERY_PROJECT=<your project id> ruby benchmark/benchmark.rb benchmark/queries.json`

BigQuery service caches requests so the benchmark should be run
at least twice, disregarding the first result.

### Inserts

`BIGQUERY_PROJECT=<project-id> ruby benchmark/inserts.rb <insert-count>`

Both synchronous and asynchronous inserts are performed and benchmarked.
