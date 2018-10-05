#!/bin/bash

# This file runs tests for merges, PRs, and nightlies.
# There are a few rules for what tests are run:
#  * PRs run all non-acceptance tests for every library.
#  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries.
#  * Nightlies run all acceptance tests for every library.
#  * Currently only runs tests on 2.5.0

set -eo pipefail

# Debug: show build environment
env | grep KOKORO

cd github/google-cloud-ruby/

# Print out Ruby version
ruby --version

# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
    EXIT_STATUS=1
}

if [ "$JOB_TYPE" = "nightly" ]; then
    (bundle update && bundle exec rake kokoro:nightly) || set_failed_status
elif [ "$JOB_TYPE" = "continuous" ]; then
    git fetch --depth=10000
    (bundle update && bundle exec rake kokoro:continuous) || set_failed_status
else
    (bundle update && bundle exec rake kokoro:presubmit) || set_failed_status
fi


exit $EXIT_STATUS
