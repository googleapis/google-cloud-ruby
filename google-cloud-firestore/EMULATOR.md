# Google Cloud Firestore Emulator

To develop and test your application locally, you can use the [Google Cloud
Firestore
Emulator](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/firestore/),
which provides local emulation of the production Google Cloud Firestore 
environment. You can start the Google Cloud Firestore emulator using 
the `gcloud` command-line tool.

`gcloud beta emulators firestore start --host-port=0.0.0.0:8080`

When you run the Cloud Firestore emulator you will see a message similar to the
following printed:

```
If you are using a library that supports the FIRESTORE_EMULATOR_HOST
environment variable, run:

  export FIRESTORE_EMULATOR_HOST=localhost:8080
```

Now you can connect to the emulator using the `FIRESTORE_EMULATOR_HOST`
environment variable:

```ruby
require "google/cloud/firestore"

# Make Firestore use the emulator
ENV["FIRESTORE_EMULATOR_HOST"] = "127.0.0.1:8080"

firestore = Google::Cloud::Firestore.new project_id: "emulator-project-id"

# Get a document reference
nyc_ref = firestore.doc "cities/NYC"

nyc_ref.set({ name: "New York City" }) # Document created
```

Or by providing the `emulator_host` argument:

```ruby
require "google/cloud/firestore"

firestore = Google::Cloud::Firestore.new project_id: "emulator-project-id",
                                         emulator_host: "127.0.0.1:8080"

# Get a document reference
nyc_ref = firestore.doc "cities/NYC"

nyc_ref.set({ name: "New York City" }) # Document created
```
