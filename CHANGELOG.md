# Release History

### 0.3.0 / 2015-08-21

#### Major changes

Add BigQuery service

#### Minor changes

* Improve error messaging when uploading files to Storage
* Add `GCLOUD_PROJECT` and `GCLOUD_KEYFILE` environment variables
* Specify OAuth 2.0 scopes when connecting to services

### 0.2.0 / 2015-07-22

#### Major changes

Add Pub/Sub service

#### Minor changes

* Add top-level `Gcloud` object with instance methods to initialize connections
  with individual services (e.g. `Gcloud#storage`)
* Add credential options to `Gcloud::Storage::File#signed_url`
* Add method aliases to improve usability of Storage API
* Improve documentation

### 0.1.1 / 2015-06-16

* Storage downloads files in binary mode (premist).
* Updated documentation.

### 0.1.0 / 2015-03-31

Initial release supporting Datastore and Storage services.
