#!/bin/bash

# This file runs tests for merges PRs.
# There are a few rules for what tests are run:
#  * Only the latest Ruby version runs E2E and Spanner tests (for nightly and PR builds).
#    - This is indicated by setting RUN_ALL_TESTS before starting this script.
#  * PRs only run tests in modified directories, unless the `spec` or `.kokoro` directories
#    are modified, in which case all tests will be run.
#  * Nightly runs will run all tests.

set -eo pipefail

cd github/google-cloud-ruby/

# Print out Ruby version
ruby --version

# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

bundle update

# CHANGED_DIRS is the list of top-level directories that changed. CHANGED_DIRS will be empty when run on master.
# See https://github.com/GoogleCloudPlatform/google-cloud-python/blob/master/.kokoro/build.sh for alt implementation
CHANGED_DIRS=$(git --no-pager diff --name-only HEAD $(git merge-base HEAD master) | grep "/" | cut -d/ -f1 | sort | uniq || true)

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
  EXIT_STATUS=1
}


# Setup service account credentials.
export GOOGLE_APPLICATION_CREDENTIALS=${KOKORO_GFILE_DIR}/service-account.json

case $JOB_TYPE in
test)
  (bundle update && bundle exec rake circleci:build) || set_failed_status
  ;;
post)
  (bundle update && bundle exec rake circleci:post) || set_failed_status
  ;;
release)
  (bundle update && bundle exec rake circleci:release) || set_failed_status
  ;;
*)
  ;;
esac

exit $EXIT_STATUS
