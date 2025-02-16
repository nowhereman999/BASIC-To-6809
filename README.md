# BASIC-To-6809
A BASIC compiler for the TRS80 Color Computer

For more info check out the blog post here:
https://wordpress.com/post/nowhereman999.wordpress.com/5054

V 4.02
- Numeric array sizes can now be larger than 255, it will now accept DIM A(1000) or DIM MyArray(300,2,2)
- String array sizes can now be larger than 255, it will now accept DIM A$(1000) or DIM MyArray$(300,2,2), the default size for strings (which includes array elements) is 255 therefore you must use the compiler option -sxx where xxx is the size of the string and make it a smaller string size if you are going to use many string arrays

V 4.01
- With the GMODE ModeNumber,GraphicsPage the compiler can now handle variables for the GraphicsPage value.  The ModeNumber value will always need to be an actual number
- Palette command now will wait for a vsync to change the value (should make sure there's no sparkels)

V 4.00
- Added New command GMODE which allows you to easily select every graphic mode the CoCo 1,2 or 3 can produce
- Added New command GCOPY which allows you to copy graphic pages to other graphic pages
- Tweaked LINE, CIRCLE & PAINT commands to use all the available graphic modes and colours of the CoCo 1,2 or 3

V 3.03
- Tweaked the AND, OR, XOR commands as the optimizer was not handling them properly

V 3.02
- Fixed a bug with optimiing when it is doing exponents

V 3.01
- Fixed a small bug with Printing of double quotes ""

V 3.00
- Added SDC file support, you can now read and write files on the SDC filesystem directly
- If a 6309 is present it puts it in native mode (should speed up code about 15%)
- Added compiler option -a which makes your program autostart
- Fixed a bug where if a variable name had AND,OR,MOD,XOR,NOT or DIVR in the name it would create variable names and operators out of it
- Fixed a bug with IF command with multiple numeric commands that weren't evaluating properly 

V 2.22
- Fixed a bug with a comment at the end of a DATA statement, it was sometimes not being ignored

V 2.21
- Fixed a bug handling close brackets

V 2.20
- Fixed handling of direct number conversion of a number that starts with a minus sign
- Fixed handling of DATA values that start with a minus sign
- Matched how BASIC converts a float to an INT (negative numbers always get the integer -1)
- Fixed a bug in multidimensional arrays

V 2.19
- Fixed LINE-(x,y),PSET command

V 2.18
- Fixed assignning a variable to numeric commands

V 2.17
- Added CMPNE(FP_A,FP_B) - Floating Point Compare if Not Equal

V 2.16
- Found a problem with comparing floating point numbers where the exponent was not being compared correctly
- Tweaked getting the 2nd value in a floatting point number if it was a typed value
- Tweaked getting numeric value in as a floating point number can now handle the value if it starts with a decimal
- Tweaked the identification of a label and a variable

V 2.15
- Added limited Floating Point support by integrating the Floating point library - by Lennart Benschop
- Fixed a bug compiling single lines with IF THEN ELSE

V 2.14
- Added more commands for streaming audio directly off the CoCo SDC: SDCPLAYORCS, SDCPLAYORCL & SDCPLAYORCR
  These commands require either an Orchestra 90 or CocoFLASH (https://www.go4retro.com/products/cocoflash/) cartridge
  The SDCPLAYORCS command streams stereo 8 bit unsigned audio at 22,375hz to both the left and right channels
  The SDCPLAYORCL streams mono 8 bit unsigned audio at 44,750hz to the Left channel output
  The SDCPLAYORCR streams mono 8 bit unsigned audio at 44,750hz to the Right channel output
- Added version checking if the user is going to have SDC streaming commands like SDCPLAY as the SDC needs version 127 or higher
- Fixed handling of REM's that were commenting out actual code, it now display better in the .asm file
  It was also causing errors as some of the command values were printing as ASCII LF/BREAK/Carriage return symbols

V 2.13
- Added SDCPLAY command to let you play audio files directly off the CoCo SDC

V 2.12
- Added GET and PUT commands, added option for PUT command to use the usual PSET (default), PRESET, AND, OR, NOT but also added
  XOR

V 2.11
- Tweaked PLAY command, had problems with Quoted PLAY string

V 2.10
- Added PLAY command and tweaked DRAW command so it handles ;X with a string if the DRAW command doesn't end with a semi colon
- Fixed a NASTY bug where certain bytes in ADDASSEM/ENDASSEM would write over actual program code

V 2.09
- Fixed a bug with INKEY$

V 2.08
- Broke some regular printing with the printing to graphics screen, this is now been fixed
- Fixed a bug with getting the value of an expression before an open bracket if an array was before the open bracket

V 2.07
- Fixed a bug with REM or ' at the end of a line that has variables in it, the line was past the variable name was being ignored by the parser

V 2.06
- Added feature to print to the PMODE 4 screen using PRINT #-3,"Hello World", use LOCATE x,y to set the location on screen of the text
- Select which font from the commandline using option -fxxxx where xxxx is either Arcade or CoCoT1

V 2.05
- Added printing to the serial port with PRINT #-2,

V 2.04
- Added Disk I/O access commands in the file Disk_Command.asm
- The Compiler can now do a LOADM command

V 2.03
- Added -v (version) and -h (help) commandline options, now uses -V for verbose level

V 2.02
- Fixed issue with INPUT command with quotes and numeric commands being identified as numeric arrays

V 2.01
- Added option -k to allow the user to keep the temporary files that are generated when the compiler is processing the .BAS program.  The default is to always delete these temp files.

V 2.00
- Can now handle many more variables
- Tokenizer can now parse code better, but still will require spaces in some cases in order to distinguish between commands and variables
- Internally it's now a lot easier to add new BASIC commands.
- Drawing horizontal lines has been sped up a lot, this also speeds up drawing Boxes and Filling boxes with the ,B or ,BF options for the LINE command
- Handling of DATA commands is improved, it can handle multiple DATA : DATA commands on a single line and it can now handle string values without quotes, just as the CoCo will

- Compiler now has 3 programs to compile before you can use it.  Load them into QB64 and compile them in the same foler as the other folders in the .zip file (Basic_Includes & Basic_Commands)
- The three programs are: BasTo6809.bas, BasTo6809.1.Tokenizer.bas & BasTo6809.2.Compile.bas
- Once all three are compiled start the compiler with the usual options as (or similar to): ./BasTo6809 -ascii -v0 -o2 -b0 YourProgram.bas

V 1.19
- The program now closes files #1 and #2 before killing the old one and renaming the Temp.txt to the correct .asm filename when removing unnecessary lines, this was causing file permission errors on Windows OS machines
V 1.18
- Fixed ADDASSEM and ENDASSEM which are now working correctly
- Added option and changed the code to allow the user to select the Max size of string arrays, max will be 255
  but the user should be able to set it lower to save space
V 1.17
- Fixed numeric and String arrays with multi dimensions, wasn't storing the values properly
- Renamed inlude file PRINT.ASM to Print.asm
- Fixed VAL command, would return with zero if the string started with a space before the number
- Fixed the Print command, was ignoring , or ; after a string variable
