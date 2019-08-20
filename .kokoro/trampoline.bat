REM Run trampoline from gfile, so that the repos that copy this script can run

CD github\\%REPO_DIR%

REM FOR /F "tokens=*" %%g IN ('git log --format^=%%B -n 1 %KOKORO_GIT_COMMIT%') do (
REM     SET "COMMIT_MESSAGE=%%g"
REM )

REM IF "%JOB_TYPE%"=="presubmit" (
REM     ECHO %COMMIT_MESSAGE% | FIND /I "[ci skip]" > Nul && ( 
REM         ECHO "[ci skip] found. Exiting"
REM     ) || (
REM         python %KOKORO_GFILE_DIR%\\trampoline_windows.py
REM     )
REM ) ELSE (
REM     python %KOKORO_GFILE_DIR%\\trampoline_windows.py
REM )

python %KOKORO_GFILE_DIR%\\trampoline_windows.py
