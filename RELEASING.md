# Releasing Google Cloud Ruby Client

These instructions apply to every gem within the Google Cloud Ruby Client
project.

## Releasing individual gems and meta-packages

The Google Cloud Ruby Client project uses [semantic
versioning](http://semver.org). Replace the `<prev_version>` and `<version>`
placeholders shown in the examples below with the appropriate numbers, e.g.
`0.1.0` and `0.2.0`. Replace the `<gem>` placeholder with the appropriate full
name of the package, e.g. `google-cloud-datastore`.

After all [pull
requests](https://github.com/googleapis/google-cloud-ruby/pulls) for a
release have been merged and all Kokoro and [Circle CI
builds](https://circleci.com/gh/googleapis/google-cloud-ruby) are
green, you may create a release as follows:

1. If you haven't already, switch to the master branch, ensure that you have no
   changes, and pull from origin.

    ```sh
    $ git checkout master
    $ git status
    $ git pull <remote> master --rebase
    ```

2. Build the gem locally. (Depending on your environment, you may need to
   `bundle exec` to rake commands; this will be shown.)

    ```sh
    $ cd <gem>
    $ bundle exec rake build
    ```

3. Install the gem locally. (The `rake install` task shown below may not always
   work as expected. Fall back to running `gem install` in an empty gemset if
   needed.)

    ```sh
    $ bundle exec rake install
    ```

4. Using IRB (not `rake console`!), manually test the gem that you installed in
   the previous step.

5. Return to the root directory of the project, and review the changes since the
   last release.

    ```sh
    $ cd ..
    $ bundle exec rake changes[<gem>]
    ```

6. Review the commits in the changes output, making notes of significant
   changes. (For examples of what a significant change is, browse the changes in
   the gem's `CHANGELOG.md`.)

7. Edit the gem's `CHANGELOG.md`. Using your notes from the previous step, write
   bullet-point lists of the major and minor changes. You can also add examples,
   fixes, thank yous, and anything else helpful or relevant. See
   google-cloud-node
   [v0.18.0](https://github.com/GoogleCloudPlatform/google-cloud-node/releases/tag/v0.18.0)
   for an example with all the bells and whistles.

8. Edit the gem's `version.rb` file, if present, or the `version` setting in its
   `.gemspec` file, changing the value to your new version number.

9. If your package is new, ensure that it has been added to the [top-level
   `Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/google-cloud/v0.52.0/Gemfile).
   Follow the steps in [Adding a new gem to
   meta-packages](#adding-a-new-gem-to-meta-packages), below.

10. If the [semver](http://semver.org/) version change for your package requires
    an increase in the requirement for your package in
    `google-cloud/google-cloud.gemspec` and/or
    `stackdriver/stackdriver.gemspec`, replace the old version requirement with
    your new requirement. Note that because of the use of the [pessimistic
    operator (`~>`)](https://robots.thoughtbot.com/rubys-pessimistic-operator),
    only certain version changes will require updating the requirement. Note
    also that the dependency requirements in the `google-cloud` and
    `stackdriver` gems must remain compatible so the two can co-exist in the
    same bundle.

11. If your package is new, ensure that a nav link and a main entry including
    code example have been added to the [top-level
    README](https://github.com/googleapis/google-cloud-ruby/blob/google-cloud/v0.52.0/README.md).

12. In the root directory of the project, test that all the version dependencies
    are correct.

    ```sh
    $ bundle update
    $ bundle exec rake ci[yes]
    ```

13. Commit your changes. Copy and paste the significant points from your
    `CHANGELOG.md` edit as the description in your commit message.

    ```sh
    $ git commit -am "Release <gem> <version> ..."
    ```

14. Tag the version.

    ```sh
    $ git tag <gem>/v<version>
    ```

15. Push the tag. This will trigger a build job on [Circle
    CI](https://circleci.com/gh/googleapis/google-cloud-ruby).

    ```sh
    $ git push <remote> <gem>/v<version>
    ```

16. Wait until the [Circle CI
    build](https://circleci.com/gh/googleapis/google-cloud-ruby) has
    passed for the tag.

17. Confirm that the new version is displayed on the [google-cloud-ruby gh-pages
    doc
    site](https://https://googleapis.github.io/google-cloud-ruby/docs/).

    If the gh-pages doc site has not been updated, inspect the build logs to
    confirm that the release task completed successfully, and that the docs
    build succeeded. This can still fail even on a green build because it is an
    "after" action in the build.

18. Confirm that the gem for the new version is available on
    [RubyGems.org](https://rubygems.org/gems/google-cloud).

19. On the [google-cloud-ruby releases
    page](https://github.com/googleapis/google-cloud-ruby/releases),
    click [Draft a new
    release](https://github.com/googleapis/google-cloud-ruby/releases/new).
    Complete the form. Include the bullet-point lists of the major and minor
    changes from the gem's `CHANGELOG.md`. You can also add examples, fixes,
    thank yous, and anything else helpful or relevant. See google-cloud-node
    [v0.18.0](https://github.com/GoogleCloudPlatform/google-cloud-node/releases/tag/v0.18.0)
    for an example with all the bells and whistles.

20. Click `Publish release`.

21. Repeat steps 1 through 20 if you are releasing multiple gems.

22. If you updated `google-cloud/google-cloud.gemspec` for a version change to
    any gem, repeat steps 1 through 21 for the `google-cloud` gem.

23. If you updated `stackdriver/stackdriver.gemspec` for a version change to any
    gem, repeat steps 1 through 21 for the `stackdriver` gem.

24. Wait until the last tag build job has successfully completed on Circle CI.
    Then push your commits to the master branch. This will trigger another
    [Circle CI](https://circleci.com/gh/googleapis/google-cloud-ruby)
    build on master branch.

    ```sh
    $ git push <remote> master
    ```

25. After the Circle CI master branch build has successfully completed, confirm
    that Kokoro and [Travis CI (Mac OS
    X)](https://travis-ci.org/googleapis/google-cloud-ruby) and
    [Appveyor CI
    (Windows)](https://ci.appveyor.com/project/googleapis/google-cloud-ruby)
    master branch builds are also green.

High fives all around!

## Adding a new gem to meta-packages

There are extra steps required to add a new package to the `google-cloud` and/or
`stackdriver` meta-package gems. These instructions are for the `google-cloud`
gem.

1. Add the gem to
   [`google-cloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/google-cloud/v0.52.0/google-cloud/Gemfile).
2. Add the gem to
   [`google-cloud/google-cloud.gemspec`](https://github.com/googleapis/google-cloud-ruby/blob/google-cloud/v0.52.0/google-cloud/google-cloud.gemspec).
3. Add the gem to
   [`gcloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/google-cloud/v0.52.0/gcloud/Gemfile).
