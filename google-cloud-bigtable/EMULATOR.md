# Cloud Bigtable Emulator

To develop and test your application locally, you can use the [Cloud Bigtable
Emulator](https://cloud.google.com/bigtable/docs/emulator), which provides
[local emulation](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/)
of the production Cloud Bigtable environment. You can start the Cloud Bigtable
emulator using the `gcloud` command-line tool.

To configure your ruby code to use the emulator, set the
`BIGTABLE_EMULATOR_HOST` environment variable to the host and port where the
emulator is running. The value can be set as an environment variable in the
shell running the ruby code, or can be set directly in the ruby code as shown
below.

```ruby
require "google/cloud/bigtable"

# Make Bigtable use the emulator
ENV["BIGTABLE_EMULATOR_HOST"] = "localhost:8086"

bigtable = Google::Cloud::Bigtable.new "emulator-project-id"
```

Or by providing the `emulator_host` argument:

```ruby
require "google/cloud/bigtable"

bigtable = Google::Cloud::Bigtable.new emulator_host: "localhost:8086"
```
