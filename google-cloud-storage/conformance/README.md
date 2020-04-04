# Storage Conformance Tests

The conformance test definitions and data in this directory should be updated (copied) manually without modification from [googleapis/conformance-tests](https://github.com/googleapis/conformance-tests/tree/master/storage).

## Compiling the test definitions

After copying the latest test definition protos, in the `google-cloud-storage/conformance` directory, run:

```
protoc --proto_path=v1/proto --ruby_out=v1/proto google/cloud/conformance/storage/v1/tests.proto
```

The output directory is the same is the input directory, so after successful compilation you should see new `_pb.rb` files that match the protobuf files. Commit all new and updated files in git.

## Running the tests

The conformance tests are included in the ordinary unit test suite. In the `google-cloud-storage` directory, run `rake test`.
