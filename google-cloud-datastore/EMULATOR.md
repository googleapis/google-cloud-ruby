# Google Cloud Datastore Emulator

To develop and test your application locally, you can use the [Google Cloud
Datastore
Emulator](https://cloud.google.com/datastore/docs/tools/datastore-emulator),
which provides [local
emulation](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/) of the
production Google Cloud Datastore environment. You can start the Google Cloud
Datastore emulator using the `gcloud` command-line tool.

When you run the Cloud Datastore emulator you will see a message similar to the
following printed:

```
If you are using a library that supports the DATASTORE_EMULATOR_HOST
environment variable, run:

  export DATASTORE_EMULATOR_HOST=localhost:8978
```

Now you can connect to the emulator using the `DATASTORE_EMULATOR_HOST`
environment variable:

```ruby
require "google/cloud/datastore"

# Make Datastore use the emulator
ENV["DATASTORE_EMULATOR_HOST"] = "localhost:8978"

datastore = Google::Cloud::Datastore.new project: "emulator-project-id"

task = datastore.entity "Task", "emulatorTask" do |t|
  t["type"] = "Testing"
  t["done"] = false
  t["priority"] = 5
  t["description"] = "Use Datastore Emulator"
end

datastore.save task
```

Or by providing the `emulator_host` argument:

```ruby
require "google/cloud/datastore"

datastore = Google::Cloud::Datastore.new emulator_host: "localhost:8978"

task = datastore.entity "Task", "emulatorTask" do |t|
  t["type"] = "Testing"
  t["done"] = false
  t["priority"] = 5
  t["description"] = "Use Datastore Emulator"
end

datastore.save task
```
