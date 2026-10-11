@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "STLINK_CLI=C:\Program Files (x86)\STMicroelectronics\STM32 ST-LINK Utility\ST-LINK Utility\ST-LINK_CLI.exe"
set "FIRMWARE=%~dp0release\Robin_nano_v3.bin"
set "FLASH_ADDRESS=0x0800C000"
set "LOGFILE=%~dp0stlink_flash.log"

if not exist "%STLINK_CLI%" (
  echo ERROR: ST-LINK_CLI.exe not found.
  goto :fail
)
if not exist "%FIRMWARE%" (
  echo ERROR: Firmware not found: "%FIRMWARE%"
  goto :fail
)
for %%F in ("%FIRMWARE%") do set "FIRMWARE_SIZE=%%~zF"
if %FIRMWARE_SIZE% LEQ 0 goto :invalid_size
if %FIRMWARE_SIZE% GTR 475136 goto :invalid_size

echo MKS Robin Nano V3.1 - Marlin application upload
echo File: "%FIRMWARE%"
echo Size: %FIRMWARE_SIZE% bytes
echo Address: %FLASH_ADDRESS%
echo SWD frequency: 1800 kHz
echo Bootloader at 0x08000000 is preserved. No mass erase.
echo.
if /I "%~1"=="--dry-run" goto :dry_run

"%STLINK_CLI%" -c SWD Freq=1800 -P "%FIRMWARE%" %FLASH_ADDRESS% -V after_programming > "%LOGFILE%" 2>&1
set "FLASH_RESULT=%ERRORLEVEL%"
type "%LOGFILE%"
if not "%FLASH_RESULT%"=="0" goto :flash_failed

"%STLINK_CLI%" -c SWD Freq=1800 -Rst -Run >> "%LOGFILE%" 2>&1
if errorlevel 1 (
  echo ERROR: Reset/run failed. See "%LOGFILE%". Firmware was programmed.
  goto :fail
)
echo.
echo SUCCESS: Firmware programmed and verified. Reset/run requested.
echo Log: "%LOGFILE%"
if /I not "%~1"=="--no-pause" pause
exit /b 0

:dry_run
echo VALIDATION ONLY - no connection, erase, programming or reset.
echo "%STLINK_CLI%" -c SWD Freq=1800 -P "%FIRMWARE%" %FLASH_ADDRESS% -V after_programming
echo "%STLINK_CLI%" -c SWD Freq=1800 -Rst -Run
exit /b 0

:invalid_size
echo ERROR: Firmware size must be between 1 and 475136 bytes.
goto :fail

:flash_failed
echo ERROR: Programming/verification failed. Reset/run skipped.
echo CLI exit code: %FLASH_RESULT%
echo Log: "%LOGFILE%"

:fail
if /I not "%~1"=="--no-pause" if /I not "%~1"=="--dry-run" pause
exit /b 1
