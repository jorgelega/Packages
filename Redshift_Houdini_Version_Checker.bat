@echo off
setlocal enabledelayedexpansion
title Redshift + Houdini Version Checker (clean)

:: Paths (change if needed)
set "RS_PATH=C:\ProgramData\Redshift"
set "RS_HOU_DIR=%RS_PATH%\Plugins\Houdini"
set "HOU_INSTALL=C:\Program Files\Side Effects Software"
set "HOU_DOCS=%USERPROFILE%\Documents"

echo.
echo ===========================================
echo   Redshift + Houdini Version Checker
echo ===========================================
echo.

:: ---- Verify Redshift plugin root ----
if not exist "%RS_PATH%" (
  echo Could not find Redshift at: %RS_PATH%
  set /p RS_PATH="Enter Redshift base (e.g. C:\ProgramData\Redshift): "
  set "RS_HOU_DIR=%RS_PATH%\Plugins\Houdini"
)

if exist "%RS_HOU_DIR%" (
  echo Redshift Houdini plugin root:
  echo   %RS_HOU_DIR%
  echo.

  :: ---- List Redshift plugin versions + find latest (pure CMD, robust) ----
  set "FOUND_RS="
  set "LATEST_VER="
  set "LATEST_KEY="

  echo Redshift plugin versions found:
  for /f "delims=" %%D in ('dir /b /ad "%RS_HOU_DIR%" 2^>nul') do (
    set "N=%%D"
    echo !N!| findstr /r "^[0-9][0-9.]*$" >nul
    if !errorlevel! equ 0 (
      echo   - %%D
      set "FOUND_RS=1"

      :: Split A.B.C.D (missing parts -> 0)
      for /f "tokens=1-4 delims=." %%a in ("!N!") do (
        set "A=%%a" & set "B=%%b" & set "C=%%c" & set "D=%%d"
      )
      if "!B!"=="" set "B=0"
      if "!C!"=="" set "C=0"
      if "!D!"=="" set "D=0"

      :: Zero-pad for string compare
      set "PA=00000!A!" & set "PA=!PA:~-5!"
      set "PB=00000!B!" & set "PB=!PB:~-5!"
      set "PC=00000!C!" & set "PC=!PC:~-5!"
      set "PD=00000!D!" & set "PD=!PD:~-5!"
      set "KEY=!PA!!PB!!PC!!PD!"

      if not defined LATEST_KEY (
        set "LATEST_KEY=!KEY!"
        set "LATEST_VER=!N!"
      ) else (
        if "!KEY!" GEQ "!LATEST_KEY!" (
          set "LATEST_KEY=!KEY!"
          set "LATEST_VER=!N!"
        )
      )
    )
  )

  echo -----------------------------
  if not defined LATEST_VER (
    :: Fallback: last lexicographic numeric-looking folder
    for /f "delims=" %%D in ('dir /b /ad "%RS_HOU_DIR%" ^| findstr /r "^[0-9][0-9.]*$" ^| sort') do set "LATEST_VER=%%D"
  )
  if defined LATEST_VER (
    echo Latest Redshift version detected: %LATEST_VER%
  ) else (
    echo Latest Redshift version detected: (none)
  )
  echo.
) else (
  echo Redshift Houdini plugin root not found: "%RS_HOU_DIR%"
  echo.
)

:: ---- Program Files: list Houdini installs (exclude "Houdini Server") ----
if exist "%HOU_INSTALL%" (
  echo Houdini versions installed in "%HOU_INSTALL%":
  set "ANY_HOU_PF="
  for /f "delims=" %%D in ('dir /b /ad "%HOU_INSTALL%" 2^>nul') do (
    set "DN=%%D"
    :: Must start with "Houdini " followed by a digit; exclude "Houdini Server"
    echo !DN!| findstr /r "^Houdini [0-9]" >nul
    if !errorlevel! equ 0 (
      echo !DN!| findstr /r /c:"^Houdini Server$" >nul
      if errorlevel 1 (
        echo   - %%D
        set "ANY_HOU_PF=1"
      )
    )
  )
  if defined ANY_HOU_PF echo.
)

:: ---- Documents: list user houdiniXX.X folders ----
if exist "%HOU_DOCS%" (
  echo Houdini user folders in "%HOU_DOCS%":
  set "ANY_HOU_DOCS="
  for /f "delims=" %%D in ('dir /b /ad "%HOU_DOCS%" 2^>nul') do (
    set "DN=%%D"
    :: Show folders starting with "houdini" followed by a digit
    echo !DN!| findstr /r "^houdini[0-9]" >nul
    if !errorlevel! equ 0 (
      echo   - %%D
      set "ANY_HOU_DOCS=1"
    )
  )
  if defined ANY_HOU_DOCS echo.
)

echo Done.
pause
exit /b 0
