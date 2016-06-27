# Releasing gcloud-ruby

The gcloud-ruby library uses [semantic versioning](http://semver.org). Replace the `<prev_version>` and `<version>` placeholders shown in the examples below with the appropriate numbers, e.g. `0.1.0` and `0.2.0`.

After all [pull requests](https://github.com/GoogleCloudPlatform/gcloud-ruby/pulls) for a release have been merged and all [Travis CI builds](https://travis-ci.org/GoogleCloudPlatform/gcloud-ruby) are green, you may create a release as follows:

1. Build the gcloud-ruby gem locally.

  ```sh
  $ rake build
  ```

1. Install the gcloud-ruby gem locally.

  ```sh
  $ rake install
  ```

1. Using IRB (not `rake console`!), manually test the gem that you installed in the previous step.

1. Open the GitHub compare view in your browser.

  ```sh
  open https://github.com/GoogleCloudPlatform/gcloud-ruby/compare/v<prev_version>...master
  ```

1. Review the commits in the GitHub compare view, making notes of significant changes. (For examples of what a significant change is, browse the changes in the [CHANGELOG.md](CHANGELOG.md).

1. If you haven't already, switch to the master branch, ensure that you have no changes, and pull from origin.

  ```sh
  $ git checkout master
  $ git status
  $ git pull --rebase
  ```

1. Edit [CHANGELOG.md](CHANGELOG.md). Using your notes from the previous step, write bullet-point lists of the major and minor changes. You can also add examples, fixes, thank yous, and anything else helpful or relevant. See gcloud-node [v0.18.0](https://github.com/GoogleCloudPlatform/gcloud-node/releases/tag/v0.18.0) for an example with all the bells and whistles.

1. Edit [lib/gcloud/version.rb](lib/gcloud/version.rb), changing the value of `VERSION` to your new version number.

1. Commit your changes. Copy and paste the significant points from your `CHANGELOG.md` edit as the description in your commit message.

  ```sh
  $ git commit -am "Bump for version <version> ... "
  ```

1. Ensure again that you have every commit from `origin master`.

  ```sh
  $ git pull --rebase
  ```

1. Tag the version.

  ```sh
  $ git tag -m 'v<version>' v<version>
  ```

1. Push your commit.

  ```sh
  $ git push
  ```

1. Push your tag.

  ```sh
  $ git push --tags
  ```

1. On the [gcloud-ruby releases page](https://github.com/GoogleCloudPlatform/gcloud-ruby/releases), click [Draft a new release](https://github.com/GoogleCloudPlatform/gcloud-ruby/releases/new). Complete the form. Include the bullet-point lists of the major and minor changes from [CHANGELOG.md](CHANGELOG.md). You can also add examples, fixes, thank yous, and anything else helpful or relevant. See gcloud-node [v0.18.0](https://github.com/GoogleCloudPlatform/gcloud-node/releases/tag/v0.18.0) for an example with all the bells and whistles.

1. Click `Publish release`.

1. Check that the [Travis CI build](https://travis-ci.org/GoogleCloudPlatform/gcloud-ruby) has passed for the version commit.

1. Confirm that the gem for the new version is available on [RubyGems.org](https://rubygems.org/gems/gcloud).

1. Confirm that the new version is displayed after "Latest release" on the [gcloud-ruby gh-pages site](http://googlecloudplatform.github.io/gcloud-ruby/).

High fives all around!
