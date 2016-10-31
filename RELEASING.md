# Releasing google-cloud-ruby

These instructions apply to every gem within the google-cloud-ruby project. Each gem should be released separately.

The google-cloud-ruby project uses [semantic versioning](http://semver.org). Replace the `<prev_version>` and `<version>` placeholders shown in the examples below with the appropriate numbers, e.g. `0.1.0` and `0.2.0`. Replace the `<gem>` placeholder with the appropriate full name of the package, e.g. `google-cloud-datastore`.

After all [pull requests](https://github.com/GoogleCloudPlatform/google-cloud-ruby/pulls) for a release have been merged and all [Travis CI builds](https://travis-ci.org/GoogleCloudPlatform/google-cloud-ruby) and [Appveyor CI builds](https://ci.appveyor.com/project/GoogleCloudPlatform/google-cloud-ruby) are green, you may create a release as follows:

1. Build the gem locally.

  ```sh
  $ rake build
  ```

1. Install the gem locally.

  ```sh
  $ rake install
  ```

1. Using IRB (not `rake console`!), manually test the gem that you installed in the previous step.

1. Open the GitHub compare view in your browser.

  ```sh
  open https://github.com/GoogleCloudPlatform/google-cloud-ruby/compare/v<prev_version>...master
  ```

1. Review the commits in the GitHub compare view, making notes of significant changes. (For examples of what a significant change is, browse the changes in the gem's `CHANGELOG.md`

1. If you haven't already, switch to the master branch, ensure that you have no changes, and pull from origin.

  ```sh
  $ git checkout master
  $ git status
  $ git pull --rebase
  ```

1. Edit the gem's `CHANGELOG.md`. Using your notes from the previous step, write bullet-point lists of the major and minor changes. You can also add examples, fixes, thank yous, and anything else helpful or relevant. See google-cloud-node [v0.18.0](https://github.com/GoogleCloudPlatform/google-cloud-node/releases/tag/v0.18.0) for an example with all the bells and whistles.

1. Edit the gem's `version.rb`, changing the value of `VERSION` to your new version number.

1. Commit your changes. Copy and paste the significant points from your `CHANGELOG.md` edit as the description in your commit message.

  ```sh
  $ git commit -am "Release <gem> <version> ..."
  ```

1. Ensure again that you have every commit from `origin master`.

  ```sh
  $ git pull --rebase
  ```

1. Tag the version.

  ```sh
  $ git tag -m '<gem>/v<version>' <gem>/v<version>
  ```

1. Push your commit.

  ```sh
  $ git push
  ```

1. Push your tag.

  ```sh
  $ git push --tags
  ```

1. On the [google-cloud-ruby releases page](https://github.com/GoogleCloudPlatform/google-cloud-ruby/releases), click [Draft a new release](https://github.com/GoogleCloudPlatform/google-cloud-ruby/releases/new). Complete the form. Include the bullet-point lists of the major and minor changes from the gem's `CHANGELOG.md`. You can also add examples, fixes, thank yous, and anything else helpful or relevant. See google-cloud-node [v0.18.0](https://github.com/GoogleCloudPlatform/google-cloud-node/releases/tag/v0.18.0) for an example with all the bells and whistles.

1. Click `Publish release`.

1. Check that the [Travis CI build](https://travis-ci.org/GoogleCloudPlatform/google-cloud-ruby) has passed for the version commit.

1. Confirm that the gem for the new version is available on [RubyGems.org](https://rubygems.org/gems/google-cloud).

1. Confirm that the new version is displayed after "Latest release" on the [google-cloud-ruby gh-pages site](http://googlecloudplatform.github.io/google-cloud-ruby/).

1. Confirm that the new version is displayed in the packages pulldown and the version switcher on the [google-cloud-ruby docs site](https://googlecloudplatform.github.io/google-cloud-ruby/#/). Verify that the new docs version contains the public API changes in the release.

High fives all around!
