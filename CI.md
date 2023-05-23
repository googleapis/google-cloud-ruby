# CI information for google-cloud-ruby

This document describes how continuous integration is configured for this repository. It documents the current setup, what runs when, how to modify the configuration, and what tools exist to run jobs locally.

## Overview

Continuous integration refers to tests that run _automatically_ against the source in this repository under different conditions.

### Test trigger

Tests can run in response to four types of triggering events:

* **Presubmit**: Tests may run to validate code in a pull request before it is accepted into the main code base.
* **Continuous**: Tests may run when new code is merged into the main branch.
* **Nightly**: Tests may run each night on a schedule.
* **Manual**: Some tests may be triggered manually.

### Test matrix

The full test suite can be conceptualized as a matrix across four dimensions: test type, test platform, Ruby version, and target gem.

1.  **Test type**

    Several types of tests are defined, to validate different concerns:

    * **Unit tests**: Small, fast tests that check the code itself.
    * **Rubocop test**: The [Rubocop](https://rubocop.org/) style checker and linter.
    * **Build test**: Runs a build of the gem.
    * **Yardoc test**: Runs the [YARD](https://yardoc.org/) documentation generation.
    * **Linkinator test**: Runs the [Linkinator](https://github.com/JustinBeckwith/linkinator) tool to find broken documentation links.
    * **Acceptance tests**: A small number of slower tests for a client that runs against the actual backend service. (i.e. similar to integration tests)
    * **Sample tests**: Tests of code samples, usually run against the actual backend service.

    Note: the repo also has a directory of integration tests, but they are not currently run by the CI system.

2.  **OS and architecture platform**

    We test against several operating systems: Linux (Ubuntu), MacOS Big Sur, and Windows 10. These currently run on the 64-bit Intel architecture, but we may extend this to include ARM in the future.

3.  **Ruby version**

    We generally support four minor Ruby versions at any given time. (These are Ruby 2.5, 2.6, 2.7, and 3.0 at the time of this writing.)

4.  **Target library**

    Google-cloud-ruby is a "monorepo", meaning it includes the source for multiple (and indeed, a large number of) individual libraries, each with its own test suite.

It is generally not feasible to run the entire matrix of tests at any one time. In most cases, we'll select a strategic subset of the matrix. For example, for presubmit and continuous tests, we normally do not test every target library, but select only those whose code as "changed" in a given pull request or commit. Similarly, we often limit the Ruby version coverage, sometimes testing only the oldest and newest supported versions, or even testing only the single newest version, if we believe that other tests will give adequate coverage to other versions. The CI configuration specifies exactly which tests will run under which circumstances, and this document will describe the setup below.

### Test runner

We use two different CI systems to run tests: **GitHub Actions**, a GitHub-provided CI system closely integrated into GitHub's development tooling and ecosystem, and **Kokoro**, an internal Google system. In general, the latter is used for tests that require or access security-sensitive data, notably acceptance tests that use real credentials to hit Google Cloud backends, while the former is used for all other tests.

Finally, tests may be run locally using Ruby tools. We'll discuss the Ruby tools first before covering CI system configuration.

## Local invocation and scripts

The "command line front-end" for the CI system is a [Toys](https://github.com/dazuma/toys) script that knows how to kick off the different kinds of tests provided by each library. (The actual implementation of each test may be a combination of rake tasks and other tools.) The command line script:

* Selects _target libraries_ to test, based on either command line arguments, the current directory, or an analysis of changes.
* Selects _test types_ to run based on command line arguments.

The tool is written in Ruby and runs on the current Ruby version and OS architecture. It performs the selected tests in the specified two-dimensional test matrix of target libraries and test types, logs the output, and prints a summary of failed tests at the end. The implementation is in [.toys/ci.rb](.toys/ci.rb).

### Running the tool locally

To run the tool, first install the Toys gem (`gem install toys`) and then execute `toys ci <args...>`. The arguments should specify which tests to run, and optionally, how to choose the libraries to run them on.

For detailed usage information, run `toys ci --help`.

Importantly, _do not use bundle exec_ when running Toys. That is, do _not_ run `bundle exec toys ci`. Toys handles bundler for you, and does not expect to be run inside a bundle.

#### Selecting tests

You must include at least one test selection flag:

* `--test` (Runs the unit tests.)
* `--rubocop` (Runs Rubocop.)
* `--build` (Runs a gem build.)
* `--yard` (Runs Yardoc/)
* `--linkinator` (Runs Linkinator. Assumes YARD has also been run, so typically you'll combine this with `--yard`.)
* `--acceptance` (Runs acceptance tests.)
* `--samples-master` (Runs sample tests against the current code in git.)
* `--samples-latest` (Runs sample tests against the current released library.)
* `--all-tasks` (Runs all tests.)

If you pass `--all-tasks`, you can selectively _disable_ individual tests by using `--no-<test-name>`. For example `--all-tasks --no-acceptance` to run everything except acceptance tests.

#### Selecting libraries

By default, if you run `toys ci` in the repo root directory, it will analyze local changes since the last commit (i.e. git status) and run tests for the list of libraries associated with those changed files. This might be the empty list if there are no local changes, or if the local changes are not associated with any particular gem.

You can also provide command line arguments to control the set of libraries to test. For example:

* If you set `--base=<REF>`, the changes between the given commit and `HEAD` will be analyzed. In general, you need to provide a SHA or a branch or tag name. Additionally, `--base=HEAD^` is supported, as it's a common case to test changes since the previous commit, but no other "navigation" refs are supported. (You may also set `--head=<REF>`, but this will check out a new `HEAD` and may put your local clone in a grafted state, so use with caution.)
* You can set `--gems=<NAMES>` to a comma-delimited list of gem names, to ignore changes and just test specific gems.
* You can set the `--all-gems` flag to test all gems. Use this with caution as it can take a long time to iterate over all gems.
* If you set `--max-gem-count=<NUM>`, it will place a limit on the number of gems the tool will test. If more than the given number of gems are selected (perhaps because changes have been made across many gem directories, or because you provided `--all-gems`), then the tool will bail, print a warning, and run _no tests_. The test _will not fail_ in this case.

Alternatively, if you run `toys ci` from within a particular library's directory, it will run the tests for that particular library, regardless of changes.

#### Other flags

A few additional flags of note:

* Normally, a `bundle install` is run implicitly before the tests in each gem directory. You can disable this by passing `--no-bundle`. You can run a `bundle update` instead by passing `--bundle-update`.
* It's possible to install or update the bundle without actually performing any tests by passing `--bundle` or `--bundle-update`, and not providing any other test selection flag. For example, you can update the bundles for all gems using `toys ci --all-gems --bundle-update`.
* If you run acceptance or sample tests, you will need to provide a project ID and credentials. You can do this by setting the `GOOGLE_CLOUD_PROJECT` and `GOOGLE_APPLICATION_CREDENTIALS` environment variables, or you can set the `--project=` and `--keyfile=` flags.
* Get online help by passing `--help` (i.e. `toys ci --help`).
* You can pass `--verbose` (or `-v`) to turn on verbose logging.

There are also a few other flags that are used by GitHub Actions and Kokoro to configure their jobs, and generally shouldn't be set locally. These include `--github-event-name=`, `--github-event-payload=`, and `--load-kokoro-context`.

#### Examples

To run unit tests for libraries with uncommitted changes:

    toys ci --test

To run unit and rubocop tests for _all_ libraries:

    toys ci --test --rubocop --all-gems

To run acceptance tests for libraries that changed since a given commit SHA, and provide needed credentials:

    toys ci --acceptance --project=my-project --keyfile=/path/to/my/keyfile.json --base=9fbcc35

To update the bundle and run all tests except acceptance and samples, for a specific library:

    toys ci --bundle-update --test --rubocop --build --yard --linkinator --gems=google-cloud-pubsub
    # or...
    cd google-cloud-pubsub && toys ci --bundle-update --test --rubocop --build --yard --linkinator

## CI configuration

This section describes the automated CI runs. First we'll provide an overview of which tests will run in which circumstances. We'll then cover the Kokoro configuration that runs the acceptance and sample tests, and the GitHub Actions configuration that runs everything else.

### Choosing tests

Not all tests run in every circumstance. Which tests actually run depends on how the tests were triggered, among other concerns. For example, we've seen how the tool can analyze changes and run tests only for modified libraries. Here we'll cover which tests actually run under what circumstance. (Later, we'll provide more details on configuration, documenting where these decisions are implemented so they can be changed.)

#### Presubmit tests

Presubmit tests attempt to validate the changes in a pull request, but otherwise need to run fairly quickly so that reviewers can get feedback. Thus:

* All test types are run on presubmit, except samples-latest. (Sample tests are run only against current code in git, because the intent is to test against potentially new code.)
* Presubmit tests analyze the changes between the pull request code—or more specifically, the "merge ref", which is generally a preview of the result of merging a PR—and the HEAD of the branch to be merged into. It tests only libraries modified by this diff. (For acceptance and sample tests, however, `--max-gem-count` is set to 4 to disable those types if there are a large number of libraries because they can take a long time.)
* All the tests are run against Linux and the latest version of Ruby. Additionally, unit tests (and only unit tests) are run against Linux and _all_ four supported minor releases of Ruby, _and_ are run against Windows and MacOS against the latest version of Ruby.

Thus, we omit quite a bit of the test matrix. We do not run any acceptance tests on Windows or on older versions of Ruby, for example. This choice was made to keep tests relatively small and quick for presubmit.

#### Continuous tests

Continuous tests are configured similarly to Presubmit tests because, again, we expect them to run fairly often, on every commit to the main branch. Thus:

* All test types are run, except samples-latest. (Sample tests are run only against current code in git, because the intent is to test against potentially new code.)
* Continuous tests analyze the changes between the commit and the previous commit. It tests only libraries modified by this diff. (For acceptance and sample tests, however, `--max-gem-count` is set to 4 to disable those types if there are a large number of libraries because they can take a long time.)
* All the tests are run against Linux and the latest version of Ruby. Additionally, unit tests (and only unit tests) are run against Linux and _all_ four supported minor releases of Ruby, _and_ are run against Windows and MacOS against the latest version of Ruby. Finally, acceptance and sample tests are run on both the oldest and newest versions of Ruby (on Linux).

The only real difference between the matrix covered by presubmit and continuous tests is that continuous tests run acceptance and sample tests against the oldest supported Ruby, whereas presubmit tests do not.

#### Nightly tests

Nightly tests run overnight on a cron, and are intended to run only once per day. Thus, we allow for a larger matrix of tests, and longer run times.

* All test types are run, except samples-master. (Nightly tests run sample tests against the latest released libraries, not the current code.)
* Nightly tests do not analyze changes, but run tests for _all_ libraries. This is how we get regular coverage of all libraries, not just those seeing active development. (`--max-gem-count` is not set.)
* Ruby and OS versions are identical to continuous tests. All tests are run against Linux and the latest version of Ruby. Additionally, unit tests (and only unit tests) are run against Linux and _all_ four supported minor releases of Ruby, _and_ are run against Windows and MacOS against the latest version of Ruby. Finally, acceptance and sample tests are run on both the oldest and newest versions of Ruby (on Linux).

Thus, the difference between nightly and continuous is that: continuous runs samples-master whereas nightly runs samples-latest, and continuous analyzes the changes in the given commit whereas nightly tests all libraries.

### Kokoro configuration

All acceptance tests and samples tests run in Kokoro, an internal Google system that is used because these tests must handle credentials that we currently do not want exposed to GitHub Actions. We try to limit Kokoro usage only to those tests, because configuring Kokoro is a bit of a pain. It is necessary to edit corresponding config files in two places: in the [`.kokoro/` directory](.kokoro/) in the git repo, _and_ in a corresponding directory in Google's internal source control.

#### Test infrastructure stack

The Kokoro test infrastructure is based on [Trampoline](https://github.com/googlecloudplatform/docker-ci-helper), a script that allows Kokoro to run tests in a Docker container. The image is located in [this repo](https://github.com/googleapis/testing-infra-docker/tree/master/ruby), and includes installations of a set of Ruby versions (one per currently supported minor version of Ruby, generally 4 in all), along with Bundler, and reasonable versions of Python and NodeJS that are used for running other tools. From this image, the container runs [this script](.kokoro/integration.sh), which iterates over a set of requested Ruby versions, and runs `toys ci` with a given set of arguments. The set of Ruby versions to use, and the arguments to Toys that control which tests are run, are provided in the `$RUBY_VERSIONS` and `$EXTRA_CI_ARGS` environment variables that are set in the Kokoro configurations below.

Note: Some of this stack is shared with the _release infrastructure_, described in [RELEASING.md](RELEASING.md), which also uses Kokoro. If changes are made on one side, make sure the effect on the other is evaluated/tested.

#### Test environment

Credentials and other environment settings are pulled in from a few separate sources.

* Secrets used by the CI jobs, are currently downloaded from a GCS bucket. This bucket (`cloud-devrel-kokoro-resources/google-cloud-ruby`) is downloaded into a directory in the file system, and accessed by [this class](.toys/.lib/repo_context.rb), which points the `GOOGLE_APPLICATION_CREDENTIALS` environment variable at a service account key, and loads other environment variables from a JSON file.
* In the near future, we'd like to move the above secrets into Secret Manager. At that point, we'd need to update the `$SECRET_MANAGER_KEYS` environment variable to specify which secrets to download (which is handled by [this file](.kokoro/populate-secrets.sh)), and update the [accessing class](.toys/.lib/repo_context.rb) to look there instead.
* In the past most secrets were set in Keystore, and downloaded by Kokoro into a particular directory in the file system. Currently, the CI system does not depend on Keystore secrets any more, but a few are still present in the environment pending further cleanup. (The release script still does use one Keystore key.)

#### Test configurations

Kokoro configurations for the three test trigger types (presubmit, continuous, and nightly) are in correspondingly named subdirectories of the [`.kokoro/` directory](.kokoro/). Each subdirectory has some number (either 2 or 4) of Kokoro jobs that will be triggered concurrently, on Linux. Each of these jobs specifies values of `$RUBY_VERSIONS` and `$EXTRA_CI_ARGS` as described above, to control what tests are run. Therefore, most changes to the setup of tests, can be made here in these configuration files.

For example: continuous and nightly tests both run on both the oldest and newest Ruby. There is only one [continuous acceptance test config](.kokoro/continuous/acceptance.cfg), and it sets `$RUBY_VERSIONS` to `"OLDEST NEWEST"` indicating that the _one_ Kokoro job should run against both Ruby versions in sequence. However, there are two separate configs for nightly acceptance tests, [one for oldest Ruby](.kokoro/nightly/acceptance-oldest.cfg) and [one for newest Ruby](.kokoro/nightly/acceptance-newest.cfg). These set `$RUBY_VERSIONS` to only one value each: `"OLDEST"`, and `"NEWEST"`, respectively. Hence, each of these separate Kokoro jobs runs against a different Ruby version, and they run concurrently. (We should note, by the way, that the symbolic values `"OLDEST"` and `"NEWEST"` are mapped to specific Ruby versions in [`integration.sh`](.kokoro/integration.sh).) Therefore, if we want to change which versions of Ruby are run sequentially, we can modify this environment variable in the Kokoro configs. If we want to change versions of Ruby run concurrently in separate Kokoro jobs, we need to add or remove Kokoro config files (again, both here and in Google's internal source control.)

The `$EXTRA_CI_ARGS` environment variable contains command line arguments passed directly to `toys ci`, as documented above. For example, presubmit tests analyze the changes between the PR and the main branch by setting `--base=main`, continuous tests analyze the changes since the previous commit by setting `--base=HEAD^`, and nightly tests test all libraries by setting `--all-gems`. These command line arguments can be modified to change the behavior of the various tests.

Of note: the _actual_ trigger of Kokoro tests (i.e. whether it's a presubmit triggered by a PR, a continuous test triggered by pushes to the main branch, or a nightly test triggered by a cron) is controlled by the config files in the internal Google source control. For example, the time setting for the cron can be edited only in the internal config.

#### Limitations

An earlier version of this test infrastructure also ran Kokoro tests in Windows and MacOS. These have been removed, largely because it is difficult to maintain and troubleshoot those platforms on Kokoro. If we should need to resurrect them at some point, you can see the last version of those scripts in [this commit](https://github.com/googleapis/google-cloud-ruby/tree/8b3487510fcbad469b2bfcab67eb506e993684d7/.kokoro), and also see [this document](https://github.com/googleapis/google-cloud-ruby/blob/8b3487510fcbad469b2bfcab67eb506e993684d7/KOKORO.md).

Previously, we also created separate Kokoro jobs _per library_ in some cases. This would allow us to massively parallelize those runs, but it also meant maintaining large (and growing) numbers of Kokoro configs, not to mention hammering Kokoro's infrastructure every time we ran those jobs. At this time, we are trying to avoid per-library Kokoro configs, but that does imply a limit on the size of our Kokoro jobs to prevent them from taking too long to run.

Currently, we have configured a 200-minute time limit on Kokoro runs. As of May 2021, most runs (even nightly runs) are well under an hour, so this should not be a significant issue for the time being, but if it does become an issue, the time limit is configured is in the _internal_ Kokoro configs in Google's internal source control (specifically in the root `common.cfg` for this repo.)

### GitHub Actions configuration

GitHub Actions runs all tests that do not need to access Google service backends and thus do not require Google credentials. This includes unit tests, rubocop, builds, and documentation.

GitHub Actions are configured by [`.github/workflows/ci.yml`](.github/workflows/ci.yml). It runs on the `pull_request` (for presubmit), `push` (for continuous), and `schedule` (for nightly) events. In each case, it configures a matrix defining which tests to run on which Ruby versions and operating systems. It then runs `toys ci` passing the GitHub event along with the tests configured by the matrix. The `toys ci` script then decides which libraries to test based on the GitHub event.

A bunch of things can be updated directly in the `ci.yml` configuration. The cron time for the nightly job, and the Ruby version - OS platform - test list matrix, can all be edited directly in that file. However, the logic deciding which libraries to test and how to interpret changes in the commit, lives in the [Toys CI script](.toys/ci.rb) itself.
