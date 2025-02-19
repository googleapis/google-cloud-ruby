
This is a test proxy for Bigtable client conformance tests, created following these guides: https://github.com/googleapis/cloud-bigtable-clients-test/blob/main/docs/test_proxy.md#additional-notes

## Run the Proxy

Run `bundle install` and then:

```bash
$ export PORT=1234 # default 9999 if not set
$ bundle exec ruby test_proxy.rb
```

## Protos

The file `proto/test_proxy.proto` was copied from https://github.com/googleapis/cndb-client-testing-protos/blob/main/google/bigtable/testproxy/test_proxy.proto, and compiled to `lib` via:

```bash
$ git clone git@github.com:googleapis/googleapis
$ git clone git@github.com/googleapis/cndb-client-testing-protos

 $ bundle exec grpc_tools_ruby_protoc \
 -I googleapis \
 -I cndb-client-testing-protos \
 --ruby_out=lib \
 --grpc_out=lib \
 --proto_path=proto \
 proto/test_proxy.proto
 ```
