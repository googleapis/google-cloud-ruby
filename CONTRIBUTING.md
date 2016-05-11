# Contributing to Gcloud

1. **Sign one of the contributor license agreements below.**
2. Fork the repo, develop and test your code changes.
3. Send a pull request.

## Contributor License Agreements

Before we can accept your pull requests you'll need to sign a Contributor License Agreement (CLA):

- **If you are an individual writing original source code** and **you own the intellectual property**, then you'll need to sign an [individual CLA](https://developers.google.com/open-source/cla/individual).
- **If you work for a company that wants to allow you to contribute your work**, then you'll need to sign a [corporate CLA](https://developers.google.com/open-source/cla/corporate).

You can sign these electronically (just scroll to the bottom). After that, we'll be able to accept your pull requests.

## Setup

In order to use the gcloud-ruby console and run the project's tests, there is a
small amount of setup:

1. Install Ruby.
    gcloud-ruby requires Ruby 2.0+. You may choose to manage your Ruby and gem installations with [RVM](https://rvm.io/), [rbenv](https://github.com/rbenv/rbenv), or [chruby](https://github.com/postmodern/chruby).

2. Install [Bundler](http://bundler.io/).

    ```sh
    $ gem install bundler
    ```

3. Install the project dependencies.

    ```sh
    $ bundle install
    ```

## Console

In order to run code interactively, you can automatically load gcloud-ruby and
its dependencies in IRB with:

```sh
$ bundle exec rake console
```

## Tests

Tests are very important part of gcloud-ruby. All contributions should include tests that ensure the contributed code behaves as expected.

### Unit Tests

To run the unit tests, simply run:

``` sh
$ rake test
```

### Acceptance Tests

The gcloud-ruby acceptance tests interact with the following live service APIs:

* BigQuery
* Cloud Datastore
* Cloud DNS
* Cloud Pub/Sub
* Cloud Storage

Follow the instructions in the [Authentication guide](AUTHENTICATION.md) for enabling APIs. Some of the APIs may not yet be generally available, making it difficult for some contributors to successfully run the entire acceptance test suite. However, please ensure that you do successfully run acceptance tests for any code areas covered by your pull request.

To run the acceptance tests, first create and configure a project in the Google Developers Console, as described in the [Authentication guide](AUTHENTICATION.md). Be sure to download the JSON KEY file. Make note of the PROJECT_ID and the KEYFILE location on your system.


#### Datastore acceptance tests

To run the Datastore acceptance tests, you must first create indexes used in the tests.

##### Datastore indexes

Install the [gcloud command-line tool](https://developers.google.com/cloud/sdk/gcloud/) and use it to create the indexes used in the datastore acceptance tests. From the project's root directory:

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

#### DNS Acceptance Tests

To run the DNS acceptance tests you must give your service account permissions to a domain name in [Webmaster Central](https://www.google.com/webmasters/verification) and set the `GCLOUD_TEST_DNS_DOMAIN` environment variable to the fully qualified domain name. (e.g. "example.com.")

#### Running the acceptance tests

To run the acceptance tests:

``` sh
$ rake test:acceptance[PROJECT_ID,KEYFILE_PATH]
```

Or, if you prefer you can store the values in the `GCLOUD_TEST_PROJECT` and `GCLOUD_TEST_KEYFILE` environment variables:

``` sh
$ export GCLOUD_TEST_PROJECT=my-project-id
$ export GCLOUD_TEST_KEYFILE=/path/to/keyfile.json
$ rake test:acceptance
```

If you want to use different values for Datastore vs. Storage acceptance tests, for example, you can use the `DATASTORE_TEST_` and `STORAGE_TEST_` environment variables:

``` sh
$ export DATASTORE_TEST_PROJECT=my-project-id
$ export DATASTORE_TEST_KEYFILE=/path/to/keyfile.json
$ export STORAGE_TEST_PROJECT=my-other-project-id
$ export STORAGE_TEST_KEYFILE=/path/to/other/keyfile.json
$ rake test:acceptance
```

## Coding Style

Please follow the established coding style in the library. The style is is largely based on [The Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) with a few exceptions based on seattle-style:

* Avoid parenthesis when possible, including in method definitions.
* Always use double quotes strings. ([Option B](https://github.com/bbatsov/ruby-style-guide#strings))

You can check your code against these rules by running Rubocop like so:

```sh
$ rake rubocop
```

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more information.
