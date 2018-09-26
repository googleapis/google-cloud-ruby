REM This file runs tests for merges and PRs.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries.

CALL cd github/google-cloud-ruby/
CALL . ${KOKORO_GFILE_DIR}/env_vars.sh