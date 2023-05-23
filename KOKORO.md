# Kokoro

## Overview

### All

#### General

- [signet](https://github.com/googleapis/signet) and [googleauth](https://github.com/googleapis/google-auth-library-ruby) use the build scripts defined in the .kokoro folder in google-cloud-ruby. [google-api-client](https://github.com/googleapis/google-api-ruby-client) has its own build process currently, although work is being done to make it consistent with the other repos.
- Docker images are now built from [testing-infra-docker](https://github.com/googleapis/testing-infra-docker).

#### Presubmit

- Run when a PR is opened, or when a commit is pushed to an open PR. They run unit tests only.
- Will skip all tests if the commit message contains either "[ci skip]" or "[skip ci]"

#### Continuous

- Run when a PR is merged to main. They run all unit tests. They run acceptance tests for a gem if the commit on main which triggered the build contains changes to that gem.

#### Nightly

- Run ...nightly. They run unit tests for all gems and acceptances tests for every gem that has acceptance tests.

#### Release

- Run when autorelease triggers them. Autorelease scans the googleapis repos for open PRs with the "autorelease: pending" tag every 15 minutes. It will trigger a build when a PR opened by either [releasetool](https://github.com/googleapis/releasetool) or [release-please](https://github.com/googleapis/release-please) is merged and the release has been tagged.
- Will, after publishing the gem to rubygems.org, build and push the ref docs to a staging bucket. This bucket is scanned once an hour. Upon finding changes docpublisher will copy the ref docs into the bucket used to serve googleapis.dev.

#### Samples

##### Presubmits

- Run when a PR is opened, or when a commit is pushed to an open PR. They run unit tests only.

- Runs tests for every sample where:
  - The sample has been updated
  - The parent gem has been updated
  - Any of the child gems of the parent gem have been updated

##### Continuous

- Run when a PR is merged to main.

- Runs all tests for every sample.

- Installs gems from main branch.

##### Nightly

- Runs all tests for every sample.

- Installs latest version of gem from rubygems.

### Ubuntu

- Uses the default kokoro ubuntu GCE image.
- Compute resources are shared across the yoshi-ubuntu pool.
- Uses the same version of trampoline as other yoshi projects.
- In addition to the regular library tests it is used for releases, publishing docs to googleapis.dev, and running [linkinator](https://github.com/JustinBeckwith/linkinator) against the repo and googleapis.dev ref docs (during the continuous/post build).
- For presubmit, continuous, and nightly builds, tests will be run on every version of ruby listed in the [ruby-multi docker image](https://github.com/googleapis/testing-infra-docker/blob/master/ruby/multi/Dockerfile). Releases and continuous/post builds use the last version defined in that image.
- Presubmits use the "multi" Dockerfile. Continuous, and nightly use the "multi-node" Dockerfile. Releases use the "release" dockerfile.
- In addition to the different gem release builds, there is a "republish" release build. This can be triggered manually via fusion, and will rebuild and re-upload all ref docs to googleapis.dev.

### OSx

- Doesn't use docker/trampoline.
- Access to the test environment setup is very limited, so the ruby versions must be installed during the kokoro builds.
- Presubmits will test on the 3rd ruby version in the [ruby-multi docker image](https://github.com/googleapis/testing-infra-docker/blob/master/ruby/multi/Dockerfile).
- Continuous and nightly builds will test on all versions in the image.

### Windows

- Uses a modified version of trampoline, .kokoro/trampoline_windows.py.
- Uses the "windows" Dockerfile in [testing-infra-docker](https://github.com/googleapis/testing-infra-docker)
- Only tests against a single ruby version which is set directly in the windows Dockerfile. Doesn't rely on the kokoro ruby versions.
- Uses the cloud-devrel-kokoro-resources/yoshi-ruby-windows GCE image.
- Compute resources are shared only with other yoshi-ruby repos, under yoshi-ruby-25-win. The "25" is unneccessary, the same pool can be used for future ruby versions, provided the windows docker image is updated.


## Maintenance

### Adding a gem to CI

1. Create the internal configs by following the steps [outlined here](https://docs.google.com/document/d/17Wg3ar8wlFTtut2CcAV9Geg8K9x28MK_UtUsYoyEx2s/edit#heading=h.o8nsr6d5n4va)
1. Once the gem has been added to the monorepo, run `bundle exec rake kokoro:build` from the root directory of the project. This will create configs in .kokoro/continuous, .kokoro/nightly, and .kokoro/release.
1. Open a PR. On that PR, under "checks", follow the "details" link beside OSx, Ubuntu, and Windows and verify that the gem's tests were run without issue.

### Updating ruby versions

1. Update the `RUBY_VERSIONS` in the [testing-infra-docker](https://github.com/googleapis/testing-infra-docker) ruby/multi/Dockerfile. When your PR is merged, the images will rebuild automatically. (Note: The windows image is not rebuilt automatically and needs to be handled manually.) This update must be in main to proceed.
1. Run `bundle exec rake kokoro:build` which will update .kokoro/osx.sh to use the ruby versions set above.
1. Open a PR.
1. Create the internal configs by following the steps [outlined here](https://docs.google.com/document/d/17Wg3ar8wlFTtut2CcAV9Geg8K9x28MK_UtUsYoyEx2s/edit#heading=h.o8nsr6d5n4va)

### Updating the windows docker image

1. In a GCP project, under "Compute Engine" create an instance. For the "boot disk" option, select "Custom Images". Set it to show images from Cloud Devrel Kokoro Resources and select the Yoshi-Ruby-Windows image.
1. If you decide to use a different GCE image, be aware that docker for windows can only build windows containers that are based on the same windows version as the host, and that there are [known issues](https://cloud.google.com/compute/docs/containers/#mtu_failures) with running docker for windows on GCP.
1. Once the VM has finished setting up, RDP in. Clone the google-cloud-ruby repo. Update .kokoro/docker/windows/Dockerfile to use your ruby version of choice from https://github.com/oneclick/rubyinstaller2/releases.
1. Verify that the image will build and can run the repo tests.
1. Follow the instructions for [pushing images to container registry](https://cloud.google.com/container-registry/docs/pushing-and-pulling).
1. Open a PR containing your changes to the Dockerfile.
