@echo off
setlocal EnableDelayedExpansion

rem ------------------------------------------------------------------
rem  Helper: get the base name of the file (without extension)
rem ------------------------------------------------------------------
set "FILENOEXT=%~n1"

rem ------------------------------------------------------------------
rem  Default target (called with: build.bat defaultF11 MYFILE.BAS)
rem ------------------------------------------------------------------
if /i "%~1"=="defaultF11" goto :defaultF11
if /i "%~1"=="Command1"   goto :Command1
if /i "%~1"=="Command2"   goto :Command2
if /i "%~1"=="Command3"   goto :Command3
if /i "%~1"=="Command4"   goto :Command4
if /i "%~1"=="Command5"   goto :Command5
if /i "%~1"=="Clean"      goto :Clean

echo Usage: %~nx0 ^<target^> [FILE]
echo.
echo Targets:
echo   defaultF11  - full 2 MB CoCo 3 build + emulator start
echo   Command1    - 64 k CoCo 1 build with Super Loader
echo   Command2    - simple compile + disk copy (no loader)
echo   Command3    - same as Command2
echo   Command4    - compile with -b1 (smaller/faster binary)
echo   Command5    - compile + disk copy + optional SD-card copy
echo   Clean       - delete all .bin/.BIN files
goto :eof

rem ------------------------------------------------------------------
rem  defaultF11
rem ------------------------------------------------------------------
:defaultF11
echo Processing %2
call :SetFile %2

echo Compiling BAS to ASM...
BasTo6809.exe -ascii %FILE%

echo Assembling with LWASM...
lwasm.exe -9bl -p cd -o./%FILENOEXT%.bin %FILENOEXT%.asm > NEW_Assembly_Listing.txt

echo Copying blank disk image...
copy /Y BLANK.DSK DISK1.DSK >NUL

echo Copying binary to disk image...
decb.exe copy -2 -b -r %FILENOEXT%.bin DISK1.DSK,%FILENOEXT%.BIN

rem Uncomment the line below to start MAME (adjust path if needed)
rem start "" mame.exe -debug -window -r 1280x800 coco3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -autoboot_command "\n\n\n\nLOADM\"%FILENOEXT%\":EXEC\n" -ui_active -natural

goto :eof

rem ------------------------------------------------------------------
rem  Command1  (64 k CoCo 1 + Super Loader)
rem ------------------------------------------------------------------
:Command1
echo Processing %2
call :SetFile %2

BasTo6809.exe -ascii %FILE%
lwasm.exe -9bl -p cd -o./%FILENOEXT%.bin %FILENOEXT%.asm > NEW_Assembly_Listing.txt

if exist GO.BIN del /F /Q GO.BIN
cc1sl.exe -l %FILENOEXT%.bin -oGO.BIN
if exist %FILENOEXT%.bin del /F /Q %FILENOEXT%.bin
ren GO.BIN %FILENOEXT%.bin

copy /Y BLANK.DSK DISK1.DSK >NUL
decb.exe copy -2 -b -r %FILENOEXT%.bin DISK1.DSK,%FILENOEXT%.BIN
goto :eof

rem ------------------------------------------------------------------
rem  Command2 (simple compile + disk copy)
rem ------------------------------------------------------------------
:Command2
echo Processing %2
call :SetFile %2

BasTo6809.exe -ascii %FILE%
lwasm.exe -9bl -p cd -o./%FILENOEXT%.bin %FILENOEXT%.asm > NEW_Assembly_Listing.txt

copy /Y BLANK.DSK DISK1.DSK >NUL
decb.exe copy -2 -b -r %FILENOEXT%.bin DISK1.DSK,%FILENOEXT%.BIN
goto :eof

rem ------------------------------------------------------------------
rem  Command3  (simple compile + disk copy)
rem ------------------------------------------------------------------
:Command3
echo Processing %2
call :SetFile %2

BasTo6809.exe -ascii %FILE%
lwasm.exe -9bl -p cd -o./%FILENOEXT%.bin %FILENOEXT%.asm > NEW_Assembly_Listing.txt

copy /Y BLANK.DSK DISK1.DSK >NUL
decb.exe copy -2 -b -r %FILENOEXT%.bin DISK1.DSK,%FILENOEXT%.BIN
goto :eof

rem ------------------------------------------------------------------
rem  Command4  (-b1 for smaller binary)
rem ------------------------------------------------------------------
:Command4
echo Processing %2 (with -b1)
call :SetFile %2

BasTo6809.exe -ascii -b1 %FILE%
lwasm.exe -9bl -p cd -o./%FILENOEXT%.bin %FILENOEXT%.asm > NEW_Assembly_Listing.txt

copy /Y BLANK.DSK DISK1.DSK >NUL
decb.exe copy -2 -b -r %FILENOEXT%.bin DISK1.DSK,%FILENOEXT%.BIN
goto :eof

rem ------------------------------------------------------------------
rem  Command5  (compile + disk + optional SD-card copy)
rem ------------------------------------------------------------------
:Command5
echo Processing %2
call :SetFile %2

BasTo6809.exe -ascii %FILE%
lwasm.exe -9bl -p cd -o./%FILENOEXT%.bin %FILENOEXT%.asm > NEW_Assembly_Listing.txt

copy /Y BLANK.DSK DISK1.DSK >NUL
decb.exe copy -2 -b -r %FILENOEXT%.bin DISK1.DSK,%FILENOEXT%.BIN

rem ----- OPTIONAL: copy to an SD card mounted as drive S: -----
rem if exist S:\ (
rem     copy /Y DISK1.DSK S:\DISK1.DSK
rem     echo DISK1.DSK copied to SD card (S:)
rem ) else (
rem     echo SD card not found (drive S:). Skipping copy.
rem )
goto :eof

rem ------------------------------------------------------------------
rem  Subroutine: set FILE and FILENOEXT from the passed argument
rem ------------------------------------------------------------------
:SetFile
set "FILE=%~1"
if not defined FILE (
    echo *** ERROR: No file specified.
    exit /b 1
)
set "FILENOEXT=%~n1"
goto :eof