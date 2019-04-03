REM This file runs tests for merges, PRs, and nightlies.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library, against all rubies.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries, against all rubies.
REM  * Nightlies run all acceptance tests for every library, against all rubies.

SET /A ERROR_CODE=1

CD C:\

REM Rubocop expects native line endings
REM TODO: set this in Dockerfile or change rubocop config
git config --system --unset core.autocrlf
git config --global core.autocrlf auto

REM Ruby can't access the files in the mounted volume.
REM Neither Powershell's Copy-Item nor xcopy correctly copy the symlinks.
REM So we clone/checkout the repo ourselves rather than relying Kokoro.
SET "run_kokoro=bundle update && bundle exec rake kokoro:%JOB_TYPE%"

SET "git_commands=ECHO %JOB_TYPE%"

IF "%JOB_TYPE%"=="presubmit" (
    SET "git_commands=git fetch && git checkout %KOKORO_GIT_COMMIT%"
    SET clone_command="`git clone #{ENV['KOKORO_GITHUB_PULL_REQUEST_URL'].split('/pull')[0]}.git`"
)
IF "%JOB_TYPE%"=="continuous" (
    SET "git_commands=git fetch --depth=10000 && git checkout %KOKORO_GIT_COMMIT%"
    SET clone_command="`git clone #{ENV['KOKORO_GITHUB_COMMIT_URL'].split('/commit')[0]}.git`"
)
IF "%JOB_TYPE%"=="nightly" (
    SET "git_commands=git fetch --depth=10000 && git checkout %KOKORO_GIT_COMMIT%"
    SET clone_command="`git clone #{ENV['KOKORO_GITHUB_COMMIT_URL'].split('/commit')[0]}.git`"
)

ruby -e %clone_command% && CD %REPO_DIR% && %git_commands% && %run_kokoro% && SET /A ERROR_CODE=0


EXIT /B %ERROR_CODE%
