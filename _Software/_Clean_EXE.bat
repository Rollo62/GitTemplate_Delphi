@echo off
echo .
echo ## _Clean_EXE ##
echo . Remove Binary folders and Files
echo .
call _Clean.bat

echo .

rem del /s "Src\Android\Debug\*.*"
erase /Q /F /S  "Src\Android\*.*"
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
rem pause
