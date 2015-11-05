@echo off
echo.
echo ## _Clean ##
echo .

del /s *.~*;*.dof;*.bak;*.tds *.rsm *.csm *.ilc *.ild *.ilf *.ils *.#0?

rem del /s *.~*;*.dof;*.bak;*.tds *.dcu *.rsm *.csm *.ilc *.ild *.ilf *.ils *.#0?
del /F /S *.~*~

del /F /S *.dcu *.o *.so *.dSYM

rem del /F /S *.exe *.apk

rem exit