REM This file runs tests for merges, PRs, and nightlies.
REM There are a few rules for what tests are run:
REM  * PRs run all non-acceptance tests for every library, against all rubies.
REM  * Merges run all non-acceptance tests for every library, and acceptance tests for all altered libraries, against all rubies.
REM  * Nightlies run all acceptance tests for every library, against all rubies.

"C:\Program Files\Git\bin\bash.exe" github/google-cloud-ruby/.kokoro/windows.sh
