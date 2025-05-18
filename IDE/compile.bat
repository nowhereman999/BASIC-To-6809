@echo off
SET target=%1
SET FILE=%2
SET FILENOEXT=%3

IF "%target%"=="" GOTO default
IF "%target%"=="Command1" GOTO cmd1
IF "%target%"=="Command2" GOTO cmd2
IF "%target%"=="Command3" GOTO cmd3
IF "%target%"=="Command4" GOTO cmd4
IF "%target%"=="Command5" GOTO cmd5

ECHO Unknown target: %target%
GOTO end

:default
ECHO Running default build...
REM Compile program %FILE%
./BasTo6809 -ascii %FILE%
REM Use LWASM to assemble %FILENOEXT%.asm into a CoCo LOADMable program called %FILENOEXT%.bin
	lwasm -9bl -p cd -o.\%(FILENOEXT%.bin %FILENOEXT%.asm > .\NEW_Assembly_Listing.txt
REM Add other commands to copy the program onto a .DSK file and start an emulator in debug mode
REM	-rm GO.BIN
REM	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
REM	-rm $(FILENOEXT).bin
REM	-mv GO.BIN $(FILENOEXT).bin
REM	-imgtool del coco_jvc_rsdos ./DISK1.DSK $(FILENOEXT).bin
REM	imgtool put coco_jvc_rsdos ./DISK1.DSK $(FILENOEXT).bin $(FILENOEXT).BIN
REM	mame -debug -window -r 1280x800 coco3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -ui_active -natural
GOTO end

:cmd1
ECHO Running Command1...
REM Compile program %FILE%
./BasTo6809 -ascii %FILE%
GOTO end

:cmd2
ECHO Running Command2...
REM Compile program %FILE%
./BasTo6809 -ascii %FILE%
REM Use LWASM to assemble %FILENOEXT%.asm into a CoCo LOADMable program called %FILENOEXT%.bin
	lwasm -9bl -p cd -o.\%(FILENOEXT%.bin %FILENOEXT%.asm > .\NEW_Assembly_Listing.txt
GOTO end

:cmd3
ECHO Running Command3...
REM Compile program %FILE%
./BasTo6809 -ascii %FILE%
REM Use LWASM to assemble %FILENOEXT%.asm into a CoCo LOADMable program called %FILENOEXT%.bin
	lwasm -9bl -p cd -o.\%(FILENOEXT%.bin %FILENOEXT%.asm > .\NEW_Assembly_Listing.txt
REM Compress big >32k files and name if GO.BIN
REM	-rm GO.BIN
	.\cc1sl -l %FILENOEXT%.bin -oGO.BIN
GOTO end

:cmd4
ECHO Running Command4...
REM Compile program %FILE%
./BasTo6809 -ascii %FILE%
REM Use LWASM to assemble %FILENOEXT%.asm into a CoCo LOADMable program called %FILENOEXT%.bin
	lwasm -9bl -p cd -o.\%(FILENOEXT%.bin %FILENOEXT%.asm > .\NEW_Assembly_Listing.txt
GOTO end

:cmd5
ECHO Running Command5...
REM Compile program %FILE%
./BasTo6809 -ascii %FILE%
REM Use LWASM to assemble %FILENOEXT%.asm into a CoCo LOADMable program called %FILENOEXT%.bin
	lwasm -9bl -p cd -o.\%(FILENOEXT%.bin %FILENOEXT%.asm > .\NEW_Assembly_Listing.txt
GOTO end

:end