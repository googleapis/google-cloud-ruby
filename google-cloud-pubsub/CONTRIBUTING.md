# Contributing to Google Cloud Pub/Sub

Thank you for your interest in making a contribution to google-cloud-ruby. Community contributions are an essential part
of open source, and we want to make contributing easy for you. If you have any suggestions for how to improve this
guide, please [open an issue](https://github.com/googleapis/google-cloud-ruby/issues) and let us know!

### Code of Conduct

Please note that this project is covered by a Contributor Code of Conduct. By participating in this project you agree to
abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more information.

## Overview

1. [Open an issue](#open-an-issue)
1. [Sign Contributor License Agreement](#sign-contributor-license-agreement)
1. [Set up environment](#set-up-environment)
1. [Run CI](#run-ci)
1. [Make changes](#make-changes)
1. [Commit changes](#commit-changes)
1. [Run CI again](#run-ci-again)
1. [Submit your pull request](#submit-your-pull-request)

## Open an issue

Pull requests should generally be directed by an existing issue, otherwise you risk working on something that the
maintainers might not be able to accept into the project. Please take a look through [the repository
issues](https://github.com/googleapis/google-cloud-ruby/issues?q=is%3Aissue+label%3A%22api%3A+pubsub%22), and if you
do not see an existing issue for your problem or feature, please open one using one of the provided templates.

## Sign Contributor License Agreement

Before we can accept your pull requests you'll need to sign a Contributor License Agreement (CLA):

- **If you are an individual writing original source code** and **you own the intellectual property**, then you'll need
  to sign an [individual CLA](https://developers.google.com/open-source/cla/individual).
- **If you work for a company that wants to allow you to contribute your work**, then you'll need to sign a [corporate
  CLA](https://developers.google.com/open-source/cla/corporate).

You can sign these electronically. After that, we'll be able to accept your pull requests.

## Set up environment

Before you start on a pull request, you should prepare your work environment for development, acceptance testing and the
interactive console (optional).

### Local development setup

To set up your local development environment:

1. Install a [supported version](google-cloud-pubsub.gemspec) (or versions) of Ruby. (You may choose to manage your
   Ruby and gem installations with [RVM](https://rvm.io/), [rbenv](https://github.com/rbenv/rbenv),
   [chruby](https://github.com/postmodern/chruby) or a similar tool.)

1. Install [Bundler](http://bundler.io/).

   ```sh
   $ gem install bundler
   ```

1. [Fork](https://docs.github.com/en/github/collaborating-with-pull-requests/working-with-forks) the
   [google-cloud-ruby](https://github.com/googleapis/google-cloud-ruby) repo, clone your fork, and configure the
   `upstream`
   [remote](https://docs.github.com/en/github/collaborating-with-pull-requests/working-with-forks/configuring-a-remote-for-a-fork):

   ```bash
   git clone https://github.com/<your-username>/google-cloud-ruby.git
   cd google-cloud-ruby
   git remote add upstream git@github.com:googleapis/google-cloud-ruby.git
   ```

1. If your fork and clone are not brand new, get the latest changes from `upstream`:

   ```bash
   git checkout main
   git pull upstream main
   ```

1. Change to the library's sub-directory in the repo:

   ```sh
   $ cd google-cloud-pubsub
   ```

1. Install (or update) the library dependencies:

   ```sh
   $ bundle update
   ```

1. Create a new topic branch off of the `main` branch:

   ```bash
   git checkout -b <topic-branch>
   ```

### Acceptance tests setup

To set up your acceptance test credentials:

1. If needed, create a Google Cloud project. In the Google Cloud Console, on the project selector page, select or create
   a project.

1. Ensure that billing is enabled for your project.

1. Ensure that the Cloud Pub/Sub API is enabled for your project.

1. Follow the instructions for [Creating a Service Account](AUTHENTICATION.md#creating-a-service-account) in
   `AUTHENTICATION.md`, including downloading and securely storing a JSON key file. 

1. Set the `GCLOUD_TEST_KEYFILE` environment variable to the path of the JSON key file that you downloaded in the
   previous step:

   ``` sh
   $ export GCLOUD_TEST_KEYFILE=/path/to/keyfile.json
   ```

   If you are already using the `GCLOUD_TEST_KEYFILE` environment variable, and wish to test this library with a
   different key file, you may set the `PUBSUB_TEST_KEYFILE` environment variable instead:

   ``` sh
   $ export PUBSUB_TEST_KEYFILE=/path/to/keyfile.json
   ```

1. Set the `GCLOUD_TEST_PROJECT` environment variable to your Google Cloud project ID:

   ``` sh
   $ export GCLOUD_TEST_PROJECT=my-project-id
   ```

   If you are already using the `GCLOUD_TEST_PROJECT` environment variable, and wish to test this library with a
   different project, you may set the `PUBSUB_TEST_PROJECT` environment variable instead:

   ``` sh
   $ export PUBSUB_TEST_PROJECT=my-project-id
   ```

### Interactive console setup (optional)

To set up your interactive console credentials:

1. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of your service account JSON key file (see
   above):

   ``` sh
   $ export GOOGLE_APPLICATION_CREDENTIALS=/path/to/keyfile.json
   ```

   If you are already using the `GOOGLE_APPLICATION_CREDENTIALS` environment variable, and wish to test this library
   with a different key file, you may set the `PUBSUB_CREDENTIALS` environment variable instead:

   ``` sh
   $ export PUBSUB_CREDENTIALS=/path/to/keyfile.json
   ```

1. Set the `GOOGLE_CLOUD_PROJECT` environment variable to your Google Cloud project ID:

   ``` sh
   $ export GOOGLE_CLOUD_PROJECT=my-project-id
   ```

   If you are already using the `GOOGLE_CLOUD_PROJECT` environment variable, and wish to test this library with a
   different project, you may set the `PUBSUB_PROJECT` environment variable instead:

   ``` sh
   $ export PUBSUB_PROJECT=my-project-id
   ```


## Run CI

You are now ready to run local CI checks for the library, which you should do **before** you make any changes. Doing so
ensures that everything is OK with your local environment and the latest dependency versions. You don't want any
surprises later.

If you haven't already done so, change to the library's sub-directory in the repo:

```sh
$ cd google-cloud-pubsub
```

To run the code style checks, documentation tests, and unit tests together, use the `ci` task:

``` sh
$ bundle exec rake ci
```

To run the command above, plus all acceptance tests, use `rake ci:acceptance` or its handy alias, `rake ci:a`. Keep in
mind that the acceptance tests typically take longer than the other CI checks and require authentication credentials.
See the [Acceptance tests](#Acceptance-tests) section below for more information.

The Rake tasks aggregated in the commands above can be run individually to streamline your workflow when developing or
debugging.

| CI check                                      | Command           |
|-----------------------------------------------|------------------ |
| [Static code analysis](#Static-code-analysis) | `rake rubocop`    |
| [Documentation tests](#Documentation-tests)   | `rake doctest`    |
| [Unit tests](#Unit-tests)                     | `rake test`       |
| [Acceptance tests](#Acceptance-tests)         | `rake acceptance` |

The subsections below describe the individual CI checks.

### Static code analysis

The project uses [Rubocop](https://github.com/rubocop/rubocop) configured with the shared
[googleapis/ruby-style](https://github.com/googleapis/ruby-style) rules to ensure that your code adheres to
Google's Ruby style. The style is largely based on [The Ruby Style
Guide](https://github.com/bbatsov/ruby-style-guide) with a few exceptions:

* Avoid parentheses when possible, including in method definitions.
* Use double-quoted strings.

You can check your code against these rules by running the Rubocop Rake task:

```sh
$ bundle exec rake rubocop
```

In the rare case that you need to override the existing Rubocop configuration for this library in order to accommodate
your changes, you can do so by updating [.rubocop.yml](.rubocop.yml).

### Documentation tests

When adding a new feature, you should almost always add one or more in-line documentation code examples demonstrating
the use of the feature, using [YARD](https://github.com/lsegal/yard)'s
[`@example`](http://www.rubydoc.info/gems/yard/file/docs/Tags.md#example) tag. Be sure to write a complete, executable
example that includes the library `require` statement and client initialization.

The project uses [yard-doctest](https://github.com/p0deje/yard-doctest) to execute each sample as a unit test:

``` sh
$ bundle exec rake doctest
```

If you add, remove or modify documentation examples, you may need to update the setup for the tests. The fixtures, stubs
and mocks required to run the tests are located in [support/doctest_helper.rb](support/doctest_helper.rb). Please note
that much of the setup is matched to its corresponding example by the title of the `@example` tag. If you alter an
example's title, you may encounter broken tests.

There are generally no assertions or mock verifications in these tests. They simply check that the examples are
syntactically correct and execute against the library source code without error.

### Unit tests

The project uses the [minitest](https://github.com/seattlerb/minitest) library, including
[specs](https://github.com/seattlerb/minitest#specs-), [mocks](https://github.com/seattlerb/minitest#mocks-),
[minitest-autotest](https://github.com/seattlerb/minitest-autotest), and
[minitest-focus](https://github.com/seattlerb/minitest-focus).

To run the unit tests:

``` sh
$ bundle exec rake test
```

Although the unit tests are intended to run quickly, during development or debugging you may want to isolate one or more
of the tests by placing the `focus` keyword just above the test declaration. (See
[minitest-focus](https://github.com/seattlerb/minitest-focus) for details.)

### Acceptance Tests

The acceptance tests (a.k.a. integration tests) ensure that the library works correctly against the live service API.
To configure your Google Cloud project, see [Acceptance tests setup](#acceptance-tests-setup) above.

**Warning: You may incur charges while running the acceptance tests against your Google Cloud project.**

Like the unit tests, the acceptance tests are based on the [minitest](https://github.com/seattlerb/minitest) library,
including [specs](https://github.com/seattlerb/minitest#specs-) and
[minitest-focus](https://github.com/seattlerb/minitest-focus). Mocks are not generally used in acceptance tests.

Because the acceptance test suite is often time-consuming to run in its entirety, during development or debugging you
may want to isolate one or more of the tests by placing the `focus` keyword just above the test declaration. (See
[minitest-focus](https://github.com/seattlerb/minitest-focus) for details.)

To run the acceptance tests:

``` sh
$ bundle exec rake acceptance
```

Some acceptance tests may depend on API features that are not yet generally available, and will fail unless your project
is added to an internal allowlist. There may also be tests that usually pass but fail occasionally due to issues like
eventual consistency. However, please ensure that you do successfully run acceptance tests for any code areas covered by
your pull request.

## Make changes

All contributions should include new or updated tests to ensure that the contributed code behaves as expected.

When starting work on a new feature, it often makes sense to begin with a basic acceptance test to ensure that the new
feature is present in the live service API and is available to your project. To run your new test exclusively,
temporarily add the `focus` keyword just above the test declaration. (See
[minitest-focus](https://github.com/seattlerb/minitest-focus) for details.) Also, the acceptance tests have a retry
mechanism that can sometimes make it hard to see the correct error when things go wrong. To disable retries while
debugging errors, temporarily comment out or remove the `run_one_method` method definition in
[acceptance/pubsub_helper.rb](acceptance/pubsub_helper.rb).

When you are done developing, be sure to remove any usages of the `focus` keyword from your tests and restore the
`run_one_method` method definition if you removed it.

### Console

The project includes a Rake task that automatically loads `google-cloud-pubsub` and its dependencies in IRB. To
configure your Google Cloud project for IRB, see [Interactive console setup](#interactive-console-setup-optional) above.

**Warning: You may incur charges while using the library with your Google Cloud project.**

If you haven't already done so, change to the library's sub-directory in the repo:

```sh
$ cd google-cloud-pubsub
```

The preloaded IRB console can be used as follows:

```sh
$ bundle exec rake console
irb(main):001:0> require "google/cloud/pubsub"
=> true
irb(main):002:0> pubsub = Google::Cloud::PubSub.new
```

Using the console provides an interactive alternative to acceptance testing that may make it easier to explore usage and
debug problems.

## Commit changes

Commit your changes using [conventional commits](https://www.conventionalcommits.org/), making sure to include the
associated GitHub issue number. Below is an example of a `feat` type commit that will result in a semver `minor`
release. Notice how it is scoped to the short name of the library, contains a bulleted list of public API changes, and
ends with the `closes` GitHub keyword. If this is the only new commit in your branch when you open your pull request,
the commit body including the `closes` phrase will be copied to your PR description. If you have multiple commits, you
should copy the body of this anchor commit manually to the PR description, so that GitHub will [automatically close the
related issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue).

```bash
git commit -am "feat(pubsub): Add my new feature

* Add MyClass#my_method

closes: #123"
```

The messages for any subsequent commits you may add do not necessarily need to follow the conventional commits format,
as these messages will be manually dropped or added as bullet points to the original message when the PR is squashed and
merged.

## Run CI again


1. If you haven't already done so, change to the library's sub-directory in the repo:

   ```sh
   $ cd google-cloud-pubsub
   ```

1. Rebase your topic branch on the upstream `main` branch:

   ```bash
   git pull --rebase upstream main
   ```

1. Run the `ci` task:

   ``` sh
   $ bundle exec rake ci
   ```

1. Run the `acceptance` task:

   ``` sh
   $ bundle exec rake acceptance
   ```

Ensure that everything is passing in `rake ci` and `rake acceptance`, or at least that `rake ci` is green and you
haven't broken anything new in `rake acceptance`, before you open your pull request.

## Submit your pull request

1. Rebase your topic branch on the upstream `main` branch:

   ```bash
   git pull --rebase upstream main
   ```

1. Push your topic branch to your fork:

   ```bash
   git push origin -u
   ```

1. Open a [pull
   request](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
   using the first line of your conventional commit as the title, and with the associated GitHub issue in the
   description. By convention in this project, the assignee of the pull request will be the maintainer who will merge it
   once it is approved. If you are a maintainer of the project, typically you should assign the pull request to
   yourself.

1. Ensure that all of the GitHub checks are passing.

