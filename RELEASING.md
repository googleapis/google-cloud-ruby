# Releasing Google Cloud Ruby Client

These instructions apply to every gem within the [Google Cloud Ruby
Client](https://github.com/googleapis/google-cloud-ruby) project.

## Releasing individual gems and meta-packages

After all relevant [pull
requests](https://github.com/googleapis/google-cloud-ruby/pulls) for a
release have been merged and all [Kokoro builds](#checking-the-status-of-kokoro-builds) are
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
   [google-cloud-errors](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-errors),
   [google-cloud-core](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-core),
   and/or
   [stackdriver-core](https://github.com/googleapis/google-cloud-ruby/tree/master/stackdriver-core),
   be sure to release them first, in the order listed. Release
   [google-cloud](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud)
   and
   [stackdriver](https://github.com/googleapis/google-cloud-ruby/blob/master/stackdriver)
   last, in case of dependency changes. (See steps 13 and 14, below.)

1. In the root directory of the project, from the master branch, review the changes for the gem since its
   last release.

    ```sh
    $ git pull
    $ bundle exec rake changes[<gem>]
    ```

1. Review the commits in the output from the previous step, making note of
   significant changes. (For examples of what a significant change is, browse
   the changes in the gem's `CHANGELOG.md`.)

1. If your gem is new, follow the steps in [Adding a new gem to the top-level
   package and the meta-packages](#adding-a-new-gem-to-the-top-level-package-and-the-meta-packages),
   below.

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

1. Python 3.6 or 3.7 is required. If you do not have Python 3.6 or 3.7 installed we recommend [this guide](https://docs.python-guide.org/starting/installation/#installation-guides).

1. Update/Install releasetool with the following:

    ```sh
    $ python3 -m pip install --user --upgrade gcp-releasetool
    ```

1. While on the master branch, cd into the directory of the gem you would like to release, and run:

    ```sh
    $ python3 -m releasetool start
    ```

    1. If it's your first time running this, releasetool will likely ask you for a GitHub API token with write:repo_hook and public_repo permissions from https://github.com/settings/tokens.

    1. Next, releasetool will present you with an automatically generated changelog. Use the information from steps 4 and 5, as well as the provided PR numbers to edit and complete the changelog. Remove the "(#111)" style PR references before continuing.

    1. Releasetool will then ask you if your change is considered major, minor, or patch. This project uses [semantic versioning](http://semver.org).

    1. Releasetool will then create and switch to a branch called `release-#{gem-name}-v#{version}`, make all the necessary changes to the changelog and gem version, and open a [pull request](https://github.com/googleapis/google-cloud-ruby/pulls).

1. Review the PR created by releasetool in the previous step, apply the appropriate label (i.e. `api: #{gem_name}`), and request a review from googleapis/yoshi-ruby.

1. Repeat steps 3 through 12 if you are releasing multiple gems.

1. If you updated `google-cloud/google-cloud.gemspec` for a version change to
   any gem, repeat steps 4 through 12 for the `google-cloud` gem.

1. If you updated `stackdriver/stackdriver.gemspec` for a version change to any
   gem, repeat steps 4 through 12 for the `stackdriver` gem.

1. After your pull request has passed all checks and been approved by reviewers,
   **Squash and merge** it. Do **not** delete the branch. [Kokoro](#checking-the-status-of-kokoro-builds) will create the [GitHub release summary](https://github.com/googleapis/google-cloud-ruby/releases) and build and push the gem to [rubygems](https://rubygems.org/). If yoshi-automation reports a failure creating the [GitHub release summary](https://github.com/googleapis/google-cloud-ruby/releases), file a bug on [releasetool's issue tracker](https://github.com/googleapis/releasetool/issues), and [write the release manually](#writing-a-github-release-summary-manually). If yoshi-automation reports that the release build has failed, follow [these steps](#checking-the-status-of-kokoro-builds), selecting the Kokoro build titled "Kokoro - Release".

1. If everything has gone successfully, [yoshi-automation](https://github.com/yoshi-automation) will post twice on the merged PR. Once to provide the status and link for the [GitHub release summary](https://github.com/googleapis/google-cloud-ruby/releases), and again to provide the status of the task to publish to [rubygems](https://rubygems.org/). At this point, please delete the branch created by releasetool in step 11(iv).

1. Verify the [GitHub release summary](https://github.com/googleapis/google-cloud-ruby/releases), making sure that it fits the format of other releases, mirrors the changelog, is tagged to the appropriate commit hash, and is for the correct version.

1. Verify that the new version is displayed on the google-cloud-ruby doc site at `googleapis.dev/ruby/#{gem_name}/latest`. The docs are published from the staging bucket every 15 minutes, so it may a few minutes to update.

   If it's been 30 minutes and the docs have not updated, [inspect the Kokoro build logs](#checking-the-status-of-kokoro-builds) to confirm that the rake `release` task succeeded.

1. Verify that the correct version of the gem was published on [rubygems](https://rubygems.org/).

1. Verify that the [Kokoro Jobs](#checking-the-status-of-kokoro-builds) have succeeded. If so, you may now delete the branch belonging to the pull request. 

High fives all around!

## Adding a new gem to the top-level package and the meta-packages

There are extra steps required to add a new gem to the top-level package and the
`google-cloud` and/or `stackdriver` meta-package gems. These instructions are
for the `google-cloud` gem.

1. Add the gem to
   [`Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/Gemfile).
1. Add the gem to
   [`google-cloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud/Gemfile).
1. Add the gem to
   [`google-cloud/google-cloud.gemspec`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud/google-cloud.gemspec).
1. Add the gem to
   [`gcloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/gcloud/Gemfile).

## Checking the status of Kokoro builds

1. On the [commits](https://github.com/googleapis/google-cloud-ruby/commits/master) page, find the commit you expect to have launched a Kokoro build.

1. To the right of your commit, there should be either a red x, or a green checkmark. If it's the green checkmark, your build was a success, and no further inspection is necessary. If it's the red x, click it to find out why the build failed.

1. A modal will appear with the list of Kokoro builds. The build titled "Kokoro CI" can be ignored. To learn more about why a build failed or what it was testing for click "details" next to the build.

1. The "details" link will take you to a page on https://source.cloud.google.com/. On the "TARGETS" tab, there will be a link to the logs. It will look like `cloud-devrel/client-libraries/google-cloud-ruby/#{job_type}-#{operating_system}`. Click the link.

1. The next page will have a list of all the tasks carried out under the selected operating system. The top half will be a list of tasks and the links to their respective logs, the bottom half will be a list of tasks and their status (SUCCEEDED/FAILED). To learn more about why a task failed, clink the corresponding link on the top half of the screen.

1. You will be greeted with a screen similar to the one in step 4. The link to your task should look like `cloud-devrel/client-libraries/google-cloud-ruby/#{job_type}/#{operating_system}/#{task_name}`. Click it.

1. The "TARGET LOG" tab should be pre-selected, and will contain the complete logs. Examine the logs to determine what went wrong. Before taking the steps below, check to see if the issue appears on [the list of known issues](https://github.com/googleapis/google-cloud-ruby/wiki/Known-Issues#kokoro-build-failures). If you see the error there, and you are confident that your release is unrelated, no further steps are necessary.

1. If you feel the error was transient:
    1. If the error occurred on "Kokoro - Release", selected in step 2, go to [the PR containing your release](https://github.com/googleapis/google-cloud-ruby/pulls?utf8=%E2%9C%93&q=is%3Apr+is%3Aclosed+Release). Unselect the labels "autorelease: published" and "autorelease: failed". This will cause Kokoro to attempt to rebuild and publish the gem you are releasing.

    1. If the error occurred on "Kokoro - Linux", "Kokoro - OSx", or "Kokoro - Windows" and you have access to [fusion](https://fusion.corp.google.com/dashboard/findbuilds?search_pattern=google-cloud-ruby%2Fcontinuous&project_types=&include_inactive_projects=false), find the failing build, click on it, then click "rebuild". If you do not have access to [fusion](https://fusion.corp.google.com/dashboard/findbuilds?search_pattern=google-cloud-ruby%2Fcontinuous&project_types=&include_inactive_projects=false), file an [issue](https://github.com/googleapis/google-cloud-ruby/issues/new?template=bug_report.md) containing a link to the build logs, a brief summary, and "@googleapis/yoshi-ruby".

1. If you feel the error was deterministic:
    1. If you are confident that the error is unrelated to your release, please open an [issue](https://github.com/googleapis/google-cloud-ruby/issues/new?template=bug_report.md) with a description of the problem and a link to the build logs.

    1. If the error is related to your release and you have access to the googleapis [rubygems](https://rubygems.org/) account, follow [these instructions](http://help.rubygems.org/kb/gemcutter/removing-a-published-rubygem) to yank the gem. Open an [issue](https://github.com/googleapis/google-cloud-ruby/issues/new?template=bug_report.md) detailing what went wrong and begin working on a fix.

    1. If the error is related to your release and you do not have access to the googleapis [rubygems](https://rubygems.org/) account, please open an [issue](https://github.com/googleapis/google-cloud-ruby/issues/new?template=bug_report.md) containing a link to the build logs, a brief summary, and "@googleapis/yoshi-ruby".

## Writing a GitHub release summary manually
1. [Draft a new GitHub release summary](https://github.com/googleapis/google-cloud-ruby/releases/new).

1. Add a tag. The tag should be of the format `#{gem_name}/v#{version_number}`.

1. To the right of the tag and "@" symbol, there will be a dropdown with "Target: master. Click the dropdown, select the "Recent Commits" tab, and find and select the commit that was your merged PR.

1. Add a title in the format `Release #{gem_name} #{version_number}`.

1. Copy the content of the most recent update in the gem's `CHANGELOG.md` into the textarea with placeholder text "Describe this release".

1. Click "Publish release"
