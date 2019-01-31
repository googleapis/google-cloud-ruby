# Releasing Google Cloud Ruby Client

These instructions apply to every gem within the [Google Cloud Ruby
Client](https://github.com/googleapis/google-cloud-ruby) project.

## Releasing individual gems and meta-packages

After all relevant [pull
requests](https://github.com/googleapis/google-cloud-ruby/pulls) for a
release have been merged and all Kokoro builds are
green, you may create a release as follows:

1. In root directory of the project, switch to the master branch, ensure that
   you have no changes, and pull from the [project
   repo](https://github.com/googleapis/google-cloud-ruby).

    ```sh
    $ git checkout master
    $ git status
    $ git pull <remote> master
    ```

1. Review the report of changes for all gems.

    ```sh
    $ bundle exec rake changes
    ```

1. Choose a gem to release based on the changes report from the previous step.
   If there are changes to
   [google-cloud-env](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-env),
   [google-cloud-core](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-core),
   and/or
   [stackdriver-core](https://github.com/googleapis/google-cloud-ruby/tree/master/stackdriver-core),
   be sure to release them first, in the order listed. Release
   [google-cloud](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud)
   and
   [stackdriver](https://github.com/googleapis/google-cloud-ruby/blob/master/stackdriver)
   last, in case of dependency changes. (See steps 15 and 16, below.)

1. In root directory of the project, review the changes for the gem since its
   last release.

    ```sh
    $ bundle exec rake changes[<gem>]
    ```

1. Review the commits in the output from the previous step, making note of
   significant changes. (For examples of what a significant change is, browse
   the changes in the gem's `CHANGELOG.md`.)

1. If your gem is new, ensure that it has been added to the [top-level
   `Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/Gemfile).
   Follow the steps in [Adding a new gem to
   meta-packages](#adding-a-new-gem-to-meta-packages), below.

1. If the [semver](http://semver.org/) version change for your gem requires
   an increase in the requirement for your gem in
   `google-cloud/google-cloud.gemspec` and/or
   `stackdriver/stackdriver.gemspec`, replace the old version requirement with
   your new requirement. Note that because of the use of the [pessimistic
   operator (`~>`)](https://robots.thoughtbot.com/rubys-pessimistic-operator),
   only certain version changes will require updating the requirement. Note
   also that the dependency requirements in the `google-cloud` and
   `stackdriver` gems must remain compatible so the two can co-exist in the
   same bundle.

1. If your gem is new, ensure that a nav link and a main entry including
   code example have been added to the [top-level
   README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md).

1. [Install releasetool](https://github.com/googleapis/releasetool#installation).

1. While on the master branch, cd into the directory of the gem you would like to release, and run:

    ```sh
    $ python3 -m releasetool start
    ```

    1. If it's your first time running this, it will likely ask you for a GitHub API token with write:repo_hook and public_repo permissions from https://github.com/settings/tokens.

    1. Next, the script will present you with an automatically generated changelog. Use the information from steps 4 and 5, as well as the provided PR numbers to edit and complete the changelog.

    1. The script will then ask you if your change is considered major, minor, or patch. This project uses [semantic versioning](http://semver.org).

    1. The script will then create and switch to a branch called release-#{gem-name}-v#{version}, make all the necessary changes to the changelog and gem version, and open a [pull request](https://github.com/googleapis/google-cloud-ruby/pulls).

1. Review the PR, apply the appropriate label(s), and request a review from googleapis/yoshi-ruby.

1. Repeat steps 4 through 11 if you are releasing multiple gems.

1. If you updated `google-cloud/google-cloud.gemspec` for a version change to
   any gem, repeat steps 5 through 11 for the `google-cloud` gem.

1. If you updated `stackdriver/stackdriver.gemspec` for a version change to any
   gem, repeat steps 5 through 11 for the `stackdriver` gem.

1. After your pull request has passed all checks and been approved by reviewers,
   **Squash and merge** it. This will trigger a build job on Kokoro, which will create the [release](https://github.com/googleapis/google-cloud-ruby/releases) and build and push the gem to [rubygems](https://rubygems.org/).

1. If everything has gone successfully, [yoshi-automation](https://github.com/yoshi-automation) will post twice on the merged PR. Once to provide the status and link for the [release](https://github.com/googleapis/google-cloud-ruby/releases), and again to provide the status of the task to publish to [rubygems](https://rubygems.org/).

1. Verify the [release](https://github.com/googleapis/google-cloud-ruby/releases), making sure that it fits the format of other releases, mirrors the changelog, is tagged to the appropriate commit hash, and is for the correct version.

1. Verify that the correct version of the gem was published on [rubygems](https://rubygems.org/).

1. Verify that the Kokoro Jobs have succeeded, by selecting the x or checkmark by your [commit](https://github.com/googleapis/google-cloud-ruby/commits/master). Pay special attention to the post task under the check "Kokoro - Linux".

High fives all around!

## Adding a new gem to meta-packages

There are extra steps required to add a new gem to the `google-cloud` and/or
`stackdriver` meta-package gems. These instructions are for the `google-cloud`
gem.

1. Add the gem to
   [`google-cloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud/Gemfile).
1. Add the gem to
   [`google-cloud/google-cloud.gemspec`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud/google-cloud.gemspec).
1. Add the gem to
   [`gcloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/gcloud/Gemfile).
