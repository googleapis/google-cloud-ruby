#!/bin/bash

# This file runs tests for merges, PRs, and nightlies.
# There are a few rules for what tests are run:
#  * PRs run all non-acceptance tests for every library against the second latest ruby.
#  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries, against all rubies.
#  * Nightlies run all acceptance tests for every library, against all rubies.

set -eo pipefail

# Debug: show build environment
env | grep KOKORO

cd $REPO_DIR

# Capture failures
EXIT_STATUS=0 # everything passed
function set_failed_status {
    EXIT_STATUS=1
}

source ~/.rvm/scripts/rvm
command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
rvm get head --auto-dotfiles

versions=(2.4.10 2.5.8 2.6.6 2.7.2 3.0.0)
rvm_versions=$(rvm list rubies)

if [[ $JOB_TYPE = "presubmit" ]]; then
    COMMIT_MESSAGE=$(git log --format=%B -n 1 $KOKORO_GIT_COMMIT)
    if [[ $COMMIT_MESSAGE = *"[ci skip]"* || $COMMIT_MESSAGE = *"[skip ci]"* ]]; then
        echo "[ci skip] found. Exiting"
    else
        version=${versions[4]}
        if [[ $rvm_versions != *$version* ]]; then
            rvm install $version
        fi
        rvm use $version@global --default
        gem update --system
        bundle update
        bundle exec rake kokoro:presubmit || set_failed_status
    fi
else
    for version in "${versions[@]}"; do
        if [[ $rvm_versions != *$version* ]]; then
            rvm install "$version"
        fi
        rvm use "$version"@global --default
        git fetch --depth=10000
        gem update --system
        bundle update
        bundle exec rake kokoro:"$JOB_TYPE" || set_failed_status
    done
fi

exit $EXIT_STATUS
