@echo off
setlocal

set "REPO_ROOT=%CD%"
set "TARGET=%REPO_ROOT%\skills"

if defined HOME (
  set "HOME_DIR=%HOME%"
) else (
  set "HOME_DIR=%USERPROFILE%"
)

set "LINK_PARENT=%HOME_DIR%\.agents"
set "LINK=%LINK_PARENT%\skills"

if not exist "%TARGET%\" (
  echo Target directory does not exist: "%TARGET%"
  exit /b 1
)

if not exist "%LINK_PARENT%\" (
  mkdir "%LINK_PARENT%"
)

if exist "%LINK%" (
  echo Link path already exists: "%LINK%"
  echo Remove it first if you want to recreate the junction.
  exit /b 1
)

mklink /J "%LINK%" "%TARGET%"

if errorlevel 1 (
  echo Failed to create junction.
  exit /b 1
)

echo Created junction:
echo   "%LINK%" -^> "%TARGET%"