@echo off
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem ::             WLA DX compiling batch file v3              ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: Do not edit anything unless you know what you're doing! ::
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set WLAPATH=..\wladx\

rem Cleanup to avoid confusion
if exist object.o del object.o

rem Compile
"%WLAPATH%wla-z80.exe" -o dcsms.asm object.o

rem Make linkfile
echo [objects]>linkfile
echo object.o>>linkfile

rem Link
"%WLAPATH%wlalink.exe" -drvs linkfile dc.sms

rem Fixup for eSMS
if exist dc.sms.sym del dc.sms.sym
ren dc.sym dc.sms.sym

rem Cleanup to avoid mess
if exist linkfile del linkfile
if exist object.o del object.o

rem Check byte-perfect compatibility
echo.
if exist "Dragon Crystal (Europe).sms" fc /b "Dragon Crystal (Europe).sms" dc.sms