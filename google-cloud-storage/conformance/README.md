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

Because the conformance tests are dynamically generated at run time, working with them is more difficult than working with hand-written tests. If you need to execute one or more of these tests in isolation, you can do so by placing the `focus` keyword just above one of the calls to `define_method`. This will isolate a subset of the conformance tests.
