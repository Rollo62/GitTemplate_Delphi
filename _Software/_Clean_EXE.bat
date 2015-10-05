@echo off
echo .
echo . CLEAN: Remove Binary folders and Files
echo .
_Clean.bat



rem erase /Q /F /S  Src\Android\*.*
rem erase /Q /F /S  Src\iOSDevice32\*.*
rem erase /Q /F /S  Src\iOSDevice64\*.*
rem erase /Q /F /S  Src\iOSSimulator\*.*
rem erase /Q /F /S  Src\Osx32\*.*
rem erase /Q /F /S  Src\Win32\*.*
rem erase /Q /F /S  Src\Win64\*.*

rd    /S /Q     "Src\Android"
rd    /S /Q     "Src\iOSDevice32"
rd    /S /Q     "Src\iOSDevice64"
rd    /S /Q     "Src\iOSSimulator"
rd    /S /Q     "Src\Osx32"
rd    /S /Q     "Src\Osx64"
rd    /S /Q     "Src\Win32"
rd    /S /Q     "Src\Win64"

echo .
echo . Done
echo .

timeout 5
pause
