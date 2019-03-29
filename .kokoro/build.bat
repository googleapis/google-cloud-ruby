REM This file runs tests for merges, PRs, and nightlies.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library, against all rubies.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries, against all rubies.
REM  * Nightlies run all acceptance tests for every library, against all rubies.

REM "C:\Program Files\Git\bin\bash.exe" %REPO_DIR%\.kokoro/windows.sh

ECHO %HOME%
REM SETX HOME C:\Users\ContainerAdministrator /m
REM ECHO %HOME%
REM SET HOME=C:\Users\ContainerAdministrator
REM ECHO %HOME%
ECHO "RUBY_OPT = %RUBY_OPT%"
ECHO "RUBYOPT = %RUBYOPT%"

REM SET "RUBYOPT=-Eutf-8"
REM SETX RUBYOPT %RUBYOPT%
REM ECHO "RUBYOPT = %RUBYOPT%"
CD %REPO_DIR%

REM ECHO ruby --version


SET EXIT_STATUS=0


git fetch --depth=10000
ECHO "Fetched"
bundle update || CALL:set_failed_status
ECHO "updated"
bundle exec rake kokoro:%JOB_TYPE% || CALL:set_failed_status

EXIT /B %EXIT_STATUS%

:set_failed_status 
    SET EXIT_STATUS=1
GOTO:EOF
