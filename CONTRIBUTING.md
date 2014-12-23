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

### Regression Tests

To run the regression tests, first create and configure a project in the Google Developers Console. Be sure to download the JSON KEY file. Make note of the PROJECT_ID and the KEYFILE location on your system.

Then Install the [gcloud command-line tool](https://developers.google.com/cloud/sdk/gcloud/) and use it to create the indexes used in the datastore regression tests.

From the project's root directory:

``` sh
# Install the app component
$ gcloud components update app

# Set the default project in your env
$ gcloud config set project PROJECT_ID

# Authenticate the gcloud tool with your account
$ gcloud auth login

# Create the indexes
$ gcloud preview datastore create-indexes regression/data/
```

As soon as the indexes are prepared you can run the regression tests:

``` sh
$ rake test:regression[PROJECT_ID,KEYFILE_PATH]
```

Or, if you prefer you can store the values in the `GCLOUD_TEST_PROJECT` and `GCLOUD_TEST_KEYFILE` environment variables:

``` sh
$ export GCLOUD_TEST_PROJECT=my-project-id
$ export GCLOUD_TEST_KEYFILE=/path/to/keyfile.json
$ rake test:regression
```

If you want to use different values for Datastore vs. Storage regression tests, you can use the `DATASTORE_` and `STORAGE_` environment variables:

``` sh
$ export DATASTORE_PROJECT=my-project-id
$ export DATASTORE_KEYFILE=/path/to/keyfile.json
$ export STORAGE_PROJECT=my-other-project-id
$ export STORAGE_KEYFILE=/path/to/other/keyfile.json
$ rake test:regression
```

## Coding Style

Please follow the established coding style in the library. The style is is largely based on [The Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) with a few exceptions based on seattle-style:

* Avoid parenthesis when possible, including in method definitions.
* Always use double quotes strings. ([Option B](https://github.com/bbatsov/ruby-style-guide#strings))

You can check your code against these rules by running Rubocop like so:

```sh
$ rake rubocop
```
