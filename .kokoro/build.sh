#!/bin/bash

# This file runs tests for merges PRs.
# There are a few rules for what tests are run:
#  * Only the latest Ruby version runs E2E and Spanner tests (for nightly and PR builds).
#    - This is indicated by setting RUN_ALL_TESTS before starting this script.
#  * PRs only run tests in modified directories, unless the `spec` or `.kokoro` directories
#    are modified, in which case all tests will be run.
#  * Nightly runs will run all tests.

set -eo pipefail

# Debug: show build environment
env | grep KOKORO


cd github/google-cloud-ruby/

git checkout master

# Print out Ruby version
ruby --version
echo $JOB_TYPE
# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

# CHANGED_DIRS is the list of top-level directories that changed. CHANGED_DIRS will be empty when run on master.
# See https://github.com/GoogleCloudPlatform/google-cloud-python/blob/master/.kokoro/build.sh for alt implementation
CHANGED_DIRS="$(git --no-pager diff --name-only HEAD^ HEAD | grep "/" | cut -d/ -f1 | sort | uniq || true)"

GEMSPECS=($(git ls-files -- */*.gemspec | cut -d/ -f1))
UPDATED_GEMS=()
RUBY_VERSIONS=("2.3.7" "2.4.4" "2.5.1")

for i in "${GEMSPECS[@]}"; do
  for j in "${CHANGED_DIRS[@]}"; do
    if [ "$i" = "$j" ]; then
      UPDATED_GEMS+=($i)
      echo "$i has been modified."
    fi
  done
done

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
  EXIT_STATUS=1
}

# Set other environment variables
sh ${KOKORO_GFILE_DIR}/env_vars.sh

# Setup service account credentials.
export GOOGLE_APPLICATION_CREDENTIALS=${KOKORO_GFILE_DIR}/service-account.json

if [ "$PACKAGE" = "post" ]; then
  rbenv global "2.5.1"
  (bundle update && bundle exec rake circleci:post) || set_failed_status
else
  cd $PACKAGE
  for version in "${RUBY_VERSIONS[@]}"; do
    rbenv global "$version"
    bundle update
    (bundle exec rake kokoro:$JOB_TYPE) || set_failed_status
  done
fi

exit $EXIT_STATUS
