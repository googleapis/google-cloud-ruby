# Benchwrapper

A small gRPC wrapper around the spanner client library. This allows the
benchmarking code to prod at spanner without speaking Ruby.

## Running

```
cd google-cloud-spanner/benchmark/benchwrapper
export SPANNER_EMULATOR_HOST=localhost:8080
bundle exec benchwrapper.rb --port=8081
```

## Generating ProtoBuf code

```bash
cd google-cloud-spanner/benchmark/benchwrapper
bundle install
bundle exec grpc_tools_ruby_protoc --ruby_out=. --grpc_out=. spanner.proto
```
