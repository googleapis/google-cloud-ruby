# Contributing to Google Cloud Firestore

Thank you for your interest in making a contribution to google-cloud-ruby. Community contributions are an essential part
of open source, and we want to make contributing easy for you. If you have any suggestions for how to improve this
guide, please [open an issue](https://github.com/googleapis/google-cloud-ruby/issues) and let use know!

### Code of Conduct

Please note that this project is covered by a Contributor Code of Conduct. By participating in this project you agree to
abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more information.

## Overview

1. [Open an issue](#open-an-issue)
1. [Sign Contributor License Agreement](#sign-contributor-license-agreement)
1. [Setup project](#setup-project)
1. [Run CI](#run-ci)
1. [Make changes](#make-changes)
1. [Commit changes](#commit-changes)
1. [Run CI again](#run-ci-again)
1. [Submit your pull request](#submit-your-pull-request)

## Open an issue

Pull requests should generally be directed by an existing issue, otherwise you risk working on something that the
maintainers might not be able to accept into the project. Please take a look through [the repository
issues](https://github.com/googleapis/google-cloud-ruby/issues), and if you do not see an existing one for your problem
or feature, please open a new issue using one of the provided templates.

## Sign Contributor License Agreement

Before we can accept your pull requests you'll need to sign a Contributor License Agreement (CLA):

- **If you are an individual writing original source code** and **you own the intellectual property**, then you'll need
  to sign an [individual CLA](https://developers.google.com/open-source/cla/individual).
- **If you work for a company that wants to allow you to contribute your work**, then you'll need to sign a [corporate
  CLA](https://developers.google.com/open-source/cla/corporate).

You can sign these electronically. After that, we'll be able to accept your pull requests.

## Setup project

In order to make changes, there is a small amount of setup:

1. Install a [supported version](google-cloud-firestore.gemspec) (or versions) of Ruby. (You may choose to manage your
   Ruby and gem installations with [RVM](https://rvm.io/), [rbenv](https://github.com/rbenv/rbenv), or
   [chruby](https://github.com/postmodern/chruby).)

1. Install [Bundler](http://bundler.io/).

   ```sh
   $ gem install bundler
   ```

1. [Fork](https://docs.github.com/en/github/collaborating-with-pull-requests/working-with-forks) the
   [google-cloud-ruby](https://github.com/googleapis/google-cloud-ruby) repo, clone your fork, and configure the
   `upstream`
   [remote](https://docs.github.com/en/github/collaborating-with-pull-requests/working-with-forks/configuring-a-remote-for-a-fork_):

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

1. Install the top-level project dependencies (or update your dependencies in an existing clone):

   ```sh
   $ bundle update
   ```

1. Install (or update) the library dependencies:

   ```sh
   $ cd google-cloud-firestore
   $ bundle install
   ```

1. Create a new topic branch off the `main` branch:

   ```bash
   git checkout -b <topic-branch>
   ```

## Run CI

You are now ready to run local CI checks for the library, which you should do **before** you make any changes. Doing so
ensures that everything is OK with your local environment and the latest dependency versions. You don't want any
surprises later.

To run the code style checks, documentation tests, and unit tests together, use the `ci` task:

``` sh
$ bundle exec rake ci
```

To run the command above, plus all acceptance tests, use `rake ci:acceptance` or its handy alias, `rake ci:a`. Keep in
mind that the acceptance tests typically take much longer to run than the other CI checks.

The rake tasks aggregated in the commands above can be run individually to streamline your workflow when developing or
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
Guide](https://github.com/bbatsov/ruby-style-guide) with a few exceptions based on Seattle.rb style:

* Avoid parentheses when possible, including in method definitions.
* Use double-quoted strings.

You can check your code against these rules by running Rubocop like so:

```sh
$ bundle exec rake rubocop
```

In the rare case that you need to override the existing configuration in order to accommodate your changes, you
can do so for just this library by updating [.rubocop.yml](.rubocop.yml).

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
example's title, you may encounter breaking tests.

There are generally no assertions or mock verifications in these tests. They just check that the examples are
syntactically correct and execute against the library source code without error.

### Unit tests

The project uses the [minitest](https://github.com/seattlerb/minitest) library, including
[specs](https://github.com/seattlerb/minitest#specs), [mocks](https://github.com/seattlerb/minitest#mocks),
[minitest-autotest](https://github.com/seattlerb/minitest-autotest), and
[minitest-focus](https://github.com/seattlerb/minitest-focus).

To run the unit tests:

``` sh
$ bundle exec rake test
```

Although the unit tests are intended to run quickly, you may want to isolate one or more of the tests by placing the
`focus` keyword just above the test declaration. (See [minitest-focus](https://github.com/seattlerb/minitest-focus)
for details.)

#### Conformance tests

The unit tests for google-cloud-firestore include [generated conformance
tests](test/google/cloud/firestore/conformance_test.rb) based on specifications that are imported from the `firestore`
subdirectory in the [googleapis/conformance-tests](https://github.com/googleapis/conformance-tests/) repo. If you need
execute one or more of these tests in isolation, you can do so by placing the `focus` keyword just above one of the
calls to `define_method`. This will isolate a subset of the conformance tests. To isolate a single conformance test
within the subset, insert a conditional statement into the `test_file.tests.each` loop near the bottom of the
`conformance_test.rb` file. In the conditional, call `next` unless the current test `description` matches the test you
want to isolate.

### Acceptance Tests

The Firestore acceptance tests interact with the live service API. Follow the instructions in the [Authentication
Guide](AUTHENTICATION.md) for enabling the product API. Occasionally, some API features may not yet be generally
available, making it difficult for some contributors to successfully run the entire acceptance test suite. However,
please ensure that you do successfully run acceptance tests for any code areas covered by your pull request.

To run the acceptance tests, first create and configure a project in the Google Developers Console, as described in the
[Authentication Guide](AUTHENTICATION.md). Be sure to download the JSON KEY file. Make note of the PROJECT_ID and the
KEYFILE location on your system.

#### Running the acceptance tests

To run the acceptance tests:

``` sh
$ bundle exec rake acceptance[\\{my-project-id},\\{/path/to/keyfile.json}]
```

Or, if you prefer you can store the values in the `GCLOUD_TEST_PROJECT` and `GCLOUD_TEST_KEYFILE` environment variables:

``` sh
$ export GCLOUD_TEST_PROJECT=\\{my-project-id}
$ export GCLOUD_TEST_KEYFILE=\\{/path/to/keyfile.json}
$ bundle exec rake acceptance
```

If you want to use a different project and credentials for acceptance tests, you can use the more specific
`FIRESTORE_TEST_PROJECT`  and `FIRESTORE_TEST_KEYFILE` environment variables:

``` sh
$ export FIRESTORE_TEST_PROJECT=\\{my-project-id}
$ export FIRESTORE_TEST_KEYFILE=\\{/path/to/keyfile.json}
$ bundle exec rake acceptance
```

## Make changes

All contributions should include tests that ensure the contributed code behaves as expected.

### Console

In order to run code interactively, you can automatically load google-cloud-firestore and its dependencies in IRB. This
requires that your developer environment has already been configured by following the steps described in the
[Authentication Guide](AUTHENTICATION.md). An IRB console can be created with:

```sh
$ bundle exec rake console
```

## Commit changes

Commit your changes using [conventional commits](https://www.conventionalcommits.org/) and include the associated GitHub
issue. Changes in the `samples` directory should receive the `chore` commit type, since these changes should not result
in a release. Below is an example of a `feat` type commit that will result in a semver `minor` release. Notice how it is
scoped to the short name of the library, contains a bulleted list of public API changes, and ends with the `closes`
GitHub keyword. If this is the only new commit in your branch when you open your pull request, the commit body including
the `closes` phrase will be copied to your PR description. If you have multiple commits, you should copy the body of
this anchor commit manually to the PR description, so that GitHub will [automatically close the related
issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue).

```bash
git commit -am "feat(firestore): Add my new feature

* Add MyClass#my_method

closes: #123"
```

The messages for any subsequent commits you may add do not necessarily need to follow the conditional commits format, as
these messages will be manually dropped or added as bullet points to the original message when the PR is merged.

## Run CI again

Repeat the [Run CI](#run-ci) step above and ensure that everything is passing in `rake ci` and `rake acceptance`. Or at least
that `rake ci` is green and you haven't broken anything new in `rake acceptance`.
before you open your pull request.

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

1. Ensure that the GitHub checks are passing.

