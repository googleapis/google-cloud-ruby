REM Run trampoline from gfile, so that the repos that copy this script can run

CD github\\%REPO_DIR%

FOR /F "tokens=*" %%g IN ('git log --format^=%%B -n 1 %KOKORO_GIT_COMMIT%') do (
    SET COMMIT_MESSAGE="%%g"
)

IF "%JOB_TYPE%"=="presubmit"(
    ECHO %COMMIT_MESSAGE% | FIND /I "[ci skip]" > Nul && ( 
        ECHO "[ci skip] found. Exiting"
    ) || (
        python %KOKORO_GFILE_DIR%\\trampoline_windows.py
    )
) ELSE (
    python %KOKORO_GFILE_DIR%\\trampoline_windows.py
)
