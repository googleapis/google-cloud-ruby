# Google Cloud Storage Emulator

To develop and test your application locally, you can point the client at a
Cloud Storage emulator instead of the live service.

Set the `STORAGE_EMULATOR_HOST` environment variable to the host and port where
the emulator is running. You can set it in the shell that runs your Ruby code,
or in the code itself:

```ruby
require "google/cloud/storage"

# Make Storage use the emulator
ENV["STORAGE_EMULATOR_HOST"] = "localhost:4443"

storage = Google::Cloud::Storage.new

bucket = storage.create_bucket "my-bucket"
file = bucket.create_file StringIO.new("Hello world!"), "hello-world.txt"
file.name #=> "hello-world.txt"
```

You can also pass the `emulator_host` argument, or set `emulator_host` in the
configuration:

```ruby
require "google/cloud/storage"

storage = Google::Cloud::Storage.new emulator_host: "localhost:4443"

# Or, for every client:
Google::Cloud::Storage.configure do |config|
  config.emulator_host = "localhost:4443"
end
```

When an emulator host is set, the client:

* Uses `http://` if the host has no scheme. Include the scheme, such as
  `https://localhost:4443`, if the emulator serves HTTPS.
* Connects anonymously instead of looking up Application Default Credentials.
  Credentials passed with the `credentials` argument are still used.
* Doesn't require a project ID.
* Ignores the `endpoint` option.

`Google::Cloud::Storage.anonymous` also uses the emulator host from the
environment variable or the configuration.
