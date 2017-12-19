# Releasing Google Cloud Ruby Client

These instructions apply to every gem within the Google Cloud Ruby Client project.

**Each gem must be released separately.** In order for the docs for the `google-cloud` package to build correctly, the only entry in `docs/manifest.json` that can be updated in the version commit preceding the release tag is the entry for the gem in the tag. The docs build will fail if you attempt to release multiple gems in parallel, since the first tag build will not yet find the listed docs for the other gems in the `gh-pages` branch.

The Google Cloud Ruby Client project uses [semantic versioning](http://semver.org). Replace the `<prev_version>` and `<version>` placeholders shown in the examples below with the appropriate numbers, e.g. `0.1.0` and `0.2.0`. Replace the `<gem>` placeholder with the appropriate full name of the package, e.g. `google-cloud-datastore`.

After all [pull requests](https://github.com/GoogleCloudPlatform/google-cloud-ruby/pulls) for a release have been merged and all [Circle CI builds](https://circleci.com/gh/GoogleCloudPlatform/google-cloud-ruby) are green, you may create a release as follows:

1. If you haven't already, switch to the master branch, ensure that you have no changes, and pull from origin.

    ```sh
    $ git checkout master
    $ git status
    $ git pull <remote> master --rebase
    ```

1. Build the gem locally. (Depending on your environment, you may need to `bundle exec` to rake commands; this will be shown.)

    ```sh
    $ cd <gem>
    $ bundle exec rake build
    ```

1. Install the gem locally.

    ```sh
    $ bundle exec rake install
    ```

1. Using IRB (not `rake console`!), manually test the gem that you installed in the previous step.

1. Return to the root directory of the project, and review the changes since the last release.

    ```sh
    $ cd ..
    $ bundle exec rake changes[<gem>]
    ```

1. Review the commits in the changes output, making notes of significant changes. (For examples of what a significant change is, browse the changes in the gem's `CHANGELOG.md`.

1. Edit the gem's `CHANGELOG.md`. Using your notes from the previous step, write bullet-point lists of the major and minor changes. You can also add examples, fixes, thank yous, and anything else helpful or relevant. See google-cloud-node [v0.18.0](https://github.com/GoogleCloudPlatform/google-cloud-node/releases/tag/v0.18.0) for an example with all the bells and whistles.

1. Edit the gem's `version.rb` file, changing the value of `VERSION` to your new version number.

1. Edit the gem's entry in `docs/manifest.json`, adding your new version number to the head of the list, and moving `"master"` to be just below it.

1. If the package is `< 1.0.0` and your version change is greater than the [semver](http://semver.org/) patch version, or if the package is `>= 1.0.0` and your version change increments the [semver](http://semver.org/) major version, edit the requirement for the gem in `google-cloud/google-cloud.gemspec` and `stackdriver/stackdriver.gemspec` (if the package is a dependency of stackdriver) , replacing the old version number for the gem with your new version number.

1. In the root directory of the project, test that all the version dependencies are correct.

    ```sh
    $ bundle update
    $ bundle exec rake ci[yes]
    ```

1. Commit your changes. Copy and paste the significant points from your `CHANGELOG.md` edit as the description in your commit message.

    ```sh
    $ git commit -am "Release <gem> <version> ..."
    ```

1. Ensure again that you have every commit from `origin master`.

    ```sh
    $ git pull <remote> master --rebase
    ```

1. Tag the version.

    ```sh
    $ git tag <gem>/v<version>
    ```

1. Push the tag. This will trigger a build job on [Circle CI](https://circleci.com/gh/GoogleCloudPlatform/google-cloud-ruby).

    ```sh
    $ git push <remote> <gem>/v<version>
    ```

1. Wait until the [Circle CI build](https://circleci.com/gh/GoogleCloudPlatform/google-cloud-ruby) has passed for the tag.

1. Confirm that the new version is displayed on the [google-cloud-ruby gh-pages doc site](http://googlecloudplatform.github.io/google-cloud-ruby/), both in the packages pulldown and the version switcher.

   If the gh-pages doc site has not been updated, inspect the build logs to confirm that the release task completed successfully, and that the docs build succeeded. This can still fail even on a green build because it is an "after" action in the build.

1. Confirm that the gem for the new version is available on [RubyGems.org](https://rubygems.org/gems/google-cloud).

1. On the [google-cloud-ruby releases page](https://github.com/GoogleCloudPlatform/google-cloud-ruby/releases), click [Draft a new release](https://github.com/GoogleCloudPlatform/google-cloud-ruby/releases/new). Complete the form. Include the bullet-point lists of the major and minor changes from the gem's `CHANGELOG.md`. You can also add examples, fixes, thank yous, and anything else helpful or relevant. See google-cloud-node [v0.18.0](https://github.com/GoogleCloudPlatform/google-cloud-node/releases/tag/v0.18.0) for an example with all the bells and whistles.

1. Click `Publish release`.

1. Repeat steps 1 through 20 if you are releasing multiple gems.

1. Wait until the last tag build job has successfully completed on Circle CI. Then push your commits to the master branch. This will trigger another [Circle CI](https://circleci.com/gh/GoogleCloudPlatform/google-cloud-ruby) build on master branch.

    ```sh
    $ git push <remote> master
    ```

1. After the Circle CI master branch build has successfully completed, confirm that [Travis CI (Mac OS X)](https://travis-ci.org/GoogleCloudPlatform/google-cloud-ruby) and [Appveyor CI (Windows)](https://ci.appveyor.com/project/GoogleCloudPlatform/google-cloud-ruby) master branch builds are also green.

1. If your version change is greater than the [semver](http://semver.org/) patch version, then when you are done releasing all individual packages, you should follow these same instructions to release the `google-cloud` umbrella package. Furthermore, if your major releases included at least one dependency of the `stackdriver` umbrella package (currently those dependencies are `google-cloud-debugger`, `google-cloud-error_reporting`, `google-cloud-logging`, and `google-cloud-trace`), then you should also follow these same instructions to release the `stackdriver` umbrella package. It is important that the dependencies of the `google-cloud` and `stackdriver` gems remain compatible so the two can co-exist in the same bundle.

High fives all around!
