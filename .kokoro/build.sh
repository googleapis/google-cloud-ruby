#!/bin/bash

# This file runs tests for merges, PRs, and nightlies.
# There are a few rules for what tests are run:
#  * PRs run all non-acceptance tests for every library.
#  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries.
#  * Nightlies run all acceptance tests for every library.

set -eo pipefail

# Debug: show build environment
env | grep KOKORO

cd github/google-cloud-ruby/

# Print out Ruby version
ruby --version

# Temporary workaround for a known bundler+docker issue:
# https://github.com/bundler/bundler/issues/6154
export BUNDLE_GEMFILE=

RUBY_VERSIONS=("2.3.8" "2.4.5" "2.5.3")

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
    EXIT_STATUS=1
}

if [ "$PACKAGE" = "post" ]; then
    rbenv global "2.5.3"
    (bundle update && bundle exec rake kokoro:post) || set_failed_status
elif [ "$JOB_TYPE" = "nightly" ]; then
    for version in "${RUBY_VERSIONS[@]}"; do
        rbenv global "$version"
        (bundle update && bundle exec rake kokoro:nightly) || set_failed_status
    done
elif [ "$JOB_TYPE" = "continuous" ]; then
    git fetch --depth=10000
    for version in "${RUBY_VERSIONS[@]}"; do
        rbenv global "$version"
        (bundle update && bundle exec rake kokoro:continuous) || set_failed_status
    done
else
    for version in "${RUBY_VERSIONS[@]}"; do
        rbenv global "$version"
        (bundle update && bundle exec rake kokoro:presubmit) || set_failed_status
    done
fi

exit $EXIT_STATUS
