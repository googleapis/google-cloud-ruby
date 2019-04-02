REM This file runs tests for merges, PRs, and nightlies.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library, against all rubies.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries, against all rubies.
REM  * Nightlies run all acceptance tests for every library, against all rubies.

REM Ruby can't access the files in the mounted volumn, so copying it
powershell -C Copy-Item -Recurse C:\src\%REPO_DIR% C:\repo

SET /A ERROR_CODE=0

cd ..
cd repo

IF "%JOB_TYPE%"=="continuous" (
    git fetch --depth=10000
)

bundle update || CALL :set_error_code
bundle exec rake kokoro:%JOB_TYPE% || CALL :set_error_code

EXIT /B %ERROR_CODE%

:set_error_code
SET /A ERROR_CODE=1 
EXIT /B 0
