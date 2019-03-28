REM This file runs tests for merges, PRs, and nightlies.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library, against all rubies.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries, against all rubies.
REM  * Nightlies run all acceptance tests for every library, against all rubies.

REM "C:\tools\msys64\usr\bin\bash" C:\src\%REPO_DIR%\.kokoro\windows.sh
REM sh C:\src\%REPO_DIR%\.kokoro\windows.sh
REM c:\tools\msys64\usr\bin\env MSYSTEM=MINGW64 c:\tools\msys64\usr\bin\bash -l -c /c/src/%REPO_DIR%/.kokoro/windows.sh
REM cd c:\src\%REPO_DIR%\

REM ruby --version

%REPO_DIR%
"C:\Program Files\Git\bin\bash.exe" %REPO_DIR%\.kokoro/windows.sh

