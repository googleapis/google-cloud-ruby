# BigQuery Benchmark
This directory contains benchmarks for BigQuery client.

## Usage
`BIGQUERY_PROJECT=<your project id> ruby benchmark/benchmark.rb benchmark/queries.json`

BigQuery service caches requests so the benchmark should be run
at least twice, disregarding the first result.
