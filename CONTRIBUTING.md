# Contributing to Gcloud

1. **Sign one of the contributor license agreements below.**
2. Fork the repo, develop and test your code changes.
3. Send a pull request.

## Contributor License Agreements

Before we can accept your pull requests you'll need to sign a Contributor License Agreement (CLA):

- **If you are an individual writing original source code** and **you own the intellectual property**, then you'll need to sign an [individual CLA](https://developers.google.com/open-source/cla/individual).
- **If you work for a company that wants to allow you to contribute your work**, then you'll need to sign a [corporate CLA](https://developers.google.com/open-source/cla/corporate).

You can sign these electronically (just scroll to the bottom). After that, we'll be able to accept your pull requests.

## Tests

Tests are very important part of gcloud-ruby. All contributions should include tests that ensure the contributed code behaves as expected.

### Unit Tests

To run the unit tests, simply run:

``` sh
$ rake test
```

### Acceptance Tests

To run the acceptance tests, first create and configure a project in the Google Developers Console. Be sure to download the JSON KEY file. Make note of the PROJECT_ID and the KEYFILE location on your system.

Then Install the [gcloud command-line tool](https://developers.google.com/cloud/sdk/gcloud/) and use it to create the indexes used in the datastore acceptance tests.

From the project's root directory:

``` sh
# Install the app component
$ gcloud components update app

# Set the default project in your env
$ gcloud config set project PROJECT_ID

# Authenticate the gcloud tool with your account
$ gcloud auth login

# Create the indexes
$ gcloud preview datastore create-indexes acceptance/data/
```

As soon as the indexes are prepared you can run the acceptance tests:

``` sh
$ rake test:acceptance[PROJECT_ID,KEYFILE_PATH]
```

Or, if you prefer you can store the values in the `GCLOUD_TEST_PROJECT` and `GCLOUD_TEST_KEYFILE` environment variables:

``` sh
$ export GCLOUD_TEST_PROJECT=my-project-id
$ export GCLOUD_TEST_KEYFILE=/path/to/keyfile.json
$ rake test:acceptance
```

If you want to use different values for Datastore vs. Storage acceptance tests, you can use the `DATASTORE_TEST_` and `STORAGE_TEST_` environment variables:

``` sh
$ export DATASTORE_TEST_PROJECT=my-project-id
$ export DATASTORE_TEST_KEYFILE=/path/to/keyfile.json
$ export STORAGE_TEST_PROJECT=my-other-project-id
$ export STORAGE_TEST_KEYFILE=/path/to/other/keyfile.json
$ rake test:acceptance
```

### Local Datastore Devserver

You can run the Datstore acceptance tests against a devserver running locally. To switch to the devserver set the `DATASTORE_HOST` environment variable with the location of the local devserver.

``` sh
$ DATASTORE_HOST=http://127.0.0.1:8080 rake test:acceptance:datastore
```

## Coding Style

Please follow the established coding style in the library. The style is is largely based on [The Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) with a few exceptions based on seattle-style:

* Avoid parenthesis when possible, including in method definitions.
* Always use double quotes strings. ([Option B](https://github.com/bbatsov/ruby-style-guide#strings))

You can check your code against these rules by running Rubocop like so:

```sh
$ rake rubocop
```
