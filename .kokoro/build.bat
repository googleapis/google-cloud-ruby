REM This file runs tests for merges, PRs, and nightlies.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries.
REM  * Nightlies run all acceptance tests for every library.

REM Currently only runs tests on 2.5.1

CALL cd github/google-cloud-ruby/
CALL ruby --version

IF "%JOB_TYPE%"=="nightly" (
    CALL bundle update && bundle exec rake kokoro:nightly
) ELSE (
    IF "%JOB_TYPE%"=="continuous" (
        CALL git fetch --depth=10000
        CALL bundle update && bundle exec rake kokoro:continuous
    ) ELSE (
        CALL bundle update && bundle exec rake kokoro:presubmit
    )
)
