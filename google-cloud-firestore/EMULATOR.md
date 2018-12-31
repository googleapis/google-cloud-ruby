# Google Cloud Firestore Emulator

To develop and test your application locally, you can use the [Google Cloud
Firestore
Emulator](https://cloud.google.com/firestore/docs/security/test-rules-emulator#install_the_emulator),
which provides local emulation of the production Google Cloud Firestore
environment. You can start the Google Cloud Firestore emulator using the
[`firebase` command-line tool](https://firebase.google.com/docs/cli/).

When you run the Cloud Firestore emulator you will see a message similar to the
following printed:

```
$ firebase serve --only firestore
API endpoint: http://[::1]:8080
API endpoint: http://127.0.0.1:8080
Dev App Server is now running.
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
