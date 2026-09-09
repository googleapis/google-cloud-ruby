# Contributing to Google Cloud Firestore samples

Thank you for your interest in making a contribution to the samples for google-cloud-firestore. These samples are used
in Google Cloud product documentation and typically are created and updated by Google. Outside contributors should be
sure to [open an issue](../CONTRIBUTING.md#open-an-issue) for discussion before starting any work.

## Overview

1. [Set up environment](#set-up-environment)
1. [Run CI](#run-ci)
1. [Make changes](#make-changes)
1. [Commit changes](#commit-changes)
1. [Run CI again](#run-ci-again)
1. [Open your pull request](#open-your-pull-request)

## Set up environment

Before you start on a pull request, you should prepare your work environment.

### Local development setup

To set up your local development environment:

1. Install a [supported version](../google-cloud-firestore.gemspec) (or versions) of Ruby. (You may choose to manage your
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

1. Create a new topic branch off of the `main` branch:

   ```bash
   git checkout -b <topic-branch>
   ```

1. Change to the library's sub-directory in the repo:

   ```sh
   $ cd google-cloud-firestore
   ```

1. Install (or update) the library dependencies:

   ```sh
   $ bundle update
   ```

1. Change to the library samples sub-directory:

   ```sh
   $ cd samples
   ```

1. Install (or update) the library samples dependencies:

   ```sh
   $ bundle update
   ```

### Acceptance tests setup

To set up your acceptance test credentials:

1. If needed, create a Google Cloud project. In the Google Cloud Console, on the project selector page, select or create
   a project.

1. Ensure that billing is enabled for your project.

1. Ensure that the Firestore API is enabled for your project. Note that if you have already enabled the Datastore API
   for your project, you will need to use a different project for Firestore.

1. Follow the instructions for [Creating a Service Account](../AUTHENTICATION.md#creating-a-service-account) in
   `AUTHENTICATION.md`, including downloading and securely storing a JSON key file. 

1. Set the `GCLOUD_TEST_KEYFILE` environment variable to the path of the JSON key file that you downloaded in the
   previous step:

   ``` sh
   $ export GCLOUD_TEST_KEYFILE=/path/to/keyfile.json
   ```

   If you are already using the `GCLOUD_TEST_KEYFILE` environment variable, and want to test the samples with a
   different key file, you can set the `FIRESTORE_TEST_KEYFILE` environment variable instead:

   ``` sh
   $ export FIRESTORE_TEST_KEYFILE=/path/to/keyfile.json
   ```

1. Set the `GCLOUD_TEST_PROJECT` environment variable to your Google Cloud project ID:

   ``` sh
   $ export GCLOUD_TEST_PROJECT=my-project-id
   ```

   If you are already using the `GCLOUD_TEST_PROJECT` environment variable, and want to test the samples with a
   different project, you can set the `FIRESTORE_TEST_PROJECT` environment variable instead:

   ``` sh
   $ export FIRESTORE_TEST_PROJECT=my-project-id
   ```

## Run CI

You are now ready to run local CI checks for the samples, which you should do **before** you make any changes. Doing so
ensures that everything is OK with your local environment and the latest dependency versions. You don't want any
surprises later.

If you haven't already done so, change to the library samples sub-directory in the repo:

```sh
$ cd google-cloud-firestore/samples
```

There are two rake commands that must be run separately to fulfill the CI checks.

| CI check                                      | Command     |
|-----------------------------------------------|------------ |
| [Static code analysis](#static-code-analysis) | `rubocop`   |
| [Acceptance tests](#acceptance-tests)         | `rake test` |

The subsections below describe the individual CI checks.

### Static code analysis

The project uses [Rubocop](https://github.com/rubocop/rubocop) configured with the shared
[googleapis/ruby-style](https://github.com/googleapis/ruby-style) rules to ensure that your code adheres to
Google's Ruby style. The style is largely based on [The Ruby Style
Guide](https://github.com/bbatsov/ruby-style-guide) with a few exceptions:

* Avoid parentheses when possible, including in method definitions.
* Use double-quoted strings.

You can check your code against these rules by running the Rubocop executable in the `google-cloud-firestore/samples`
directory:

```sh
$ bundle exec rubocop
```

In the rare case that you need to override the existing Rubocop configuration for the samples in order to accommodate
your changes, you can do so by updating [.rubocop.yml](.rubocop.yml) in the samples directory.

### Acceptance Tests

The acceptance tests (a.k.a. integration tests) ensure that the samples work correctly against the live service API.
To configure your Google Cloud project, see [Acceptance tests setup](#acceptance-tests-setup) above.

**Warning: You may incur charges while running the acceptance tests against your Google Cloud project.**

The acceptance tests are based on the [minitest](https://github.com/seattlerb/minitest) library, including
[specs](https://github.com/seattlerb/minitest#specs-) and [minitest-focus](https://github.com/seattlerb/minitest-focus).
Mocks are not generally used in acceptance tests. Because the acceptance test suite is often time-consuming to run in
its entirety, during development or debugging you may want to isolate one or more of the tests by placing the `focus`
keyword just above the test declaration. (See [minitest-focus](https://github.com/seattlerb/minitest-focus) for
details.)

To run the acceptance tests, run the following command in the `google-cloud-firestore/samples` directory:

``` sh
$ bundle exec rake test
```

By default, the Gemfile loads the latest *published* version of the `google-cloud-firestore` gem. If your samples depend
on changes to source code in your local `google-cloud-firestore` directory, set the `GOOGLE_CLOUD_SAMPLES_TEST`
environment variable and re-run `bundle update`:

``` sh
$ export GOOGLE_CLOUD_SAMPLES_TEST=master
$ bundle update
$ bundle exec rake test
```

There may be tests that usually pass but fail occasionally due to issues like eventual consistency. However, please
ensure that you do successfully run acceptance tests for any samples covered by your pull request.

## Make changes

All contributions should include new or updated tests to ensure that the contributed code behaves as expected.

To run a single test, temporarily add the `focus` keyword just above the test declaration. (See
[minitest-focus](https://github.com/seattlerb/minitest-focus) for details.) When you are done developing, be sure to
remove any usages of the `focus` keyword from your tests.

## Commit changes

Commit your changes using [conventional commits](https://www.conventionalcommits.org/), making sure to include the
associated GitHub issue number. Please use `chore` as the commit type for all samples changes to prevent them from
triggering a library release. Notice how the example message below is scoped to the short name of the library, contains
a bulleted list of region tag changes, and ends with the `closes` GitHub keyword. If this is the only new commit in your
branch when you open your pull request, the commit body including the `closes` phrase will be copied to your PR
description. If you have multiple commits, you should copy the body of this anchor commit manually to the PR
description, so that GitHub will [automatically close the related
issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue).

```bash
git commit -am "chore(firestore): Add samples

* Add firestore_use_case_1 region tag
* Add firestore_use_case_2 region tag

closes: #123"
```

The messages for any subsequent commits you may add do not necessarily need to follow the conventional commits format,
as these messages will be manually dropped or added as bullet points to the original message when the PR is squashed and
merged.

## Run CI again


1. If you haven't already done so, change to the library samples sub-directory in the repo:

   ```sh
   $ cd google-cloud-firestore/samples
   ```

1. Rebase your topic branch on the upstream `main` branch:

   ```bash
   git pull --rebase upstream main
   ```

1. Run the `rubocop` executable:

   ``` sh
   $ bundle exec rubocop
   ```

1. Run the `test` task:

   ``` sh
   $ bundle exec rake test
   ```

Ensure that everything is passing in `rubocop` and `rake test` before you open your pull request.

## Open your pull request

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

