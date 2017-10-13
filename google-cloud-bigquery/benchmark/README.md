# BigQuery Benchmark
This directory contains benchmarks for BigQuery client.

## Usage
`ruby benchmark/benchmark.rb -- <your project id> benchmark/queries.json`

BigQuery service caches requests so the benchmark should be run
at least twice, disregarding the first result.
