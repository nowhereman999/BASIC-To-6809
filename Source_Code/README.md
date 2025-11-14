# BASIC-To-6809
A BASIC compiler for the TRS-80 Color Computer 1,2 & 3 and also the Dragon computers.

Binaries for M1 Mac & Windows are available in the binaries folder
Linux users can find a helpful build script in the binaries folder
There may be more updated versions of the Binaries for Windows and Linux available here:
https://github.com/pwillard/basto6809Manual

Installation and much more info is available in the manual found here:
https://github.com/nowhereman999/BASIC-To-6809/blob/main/Manual.pdf

For more info check out the blog post here:
https://wordpress.com/post/nowhereman999.wordpress.com/5054

V 5.00
- Fully supports all Variable Types, Variable default to float, so to max speed you must assign variable types to
  there minimum size and accuracy needed. 

V 4.43
- Added support for the CoCoMP3 hardware (many commands, read the manual for more info)

V 4.42
- Added support for AUDIO ON|OFF and MOTOR ON|OFF

V 4.41
- Added the DRAW command for all graphics modes including the semi-graphics modes
- Improved the handling of single line IF commands that have THEN or ELSE with a line number and not a GOTO line number 
- Fixed POKE command so it can now handle math funxtions directly for both the address and the value to poke
- Fixed a bug with LINE command with horizontal lines with two colours, depending on the offset it could draw the line smaller
  than it should be
- Updated SDECB.bas IDE to ignore TIMER, it can now be treated as a variable to be set just as on Extended Color BASIC

V 4.40
- Added -dragon option, which will output a compiled program that will work for the Dragon computers keyboard layout instead
  of the CoCo keyboard layout
- Removed Keyboardinput.asm as the INKEY and INPUT commands no longer use it, should save about 300 bytes

V 4.39
- Fixed SCREEN and GMODE commands so that the graphic screen is only shown with the SCREEN 1 command now and pointers for screen
  locations are set properly
- Fixed an issue with IF/THEN/ELSE in certain conditions

V 4.38
- Tweaked the COPYBLOCKS command, if there is a 6309 in the CoCo it will use TFM to do the copy (way faster)
- Fixed a bug where the SCREEN command wasn't going back to text mode or graphics mode when sprites are being used

V 4.37
- Added TRIM$,LTRIM$ & RTRIM$ commands that will remove the spaces in a string
- Fixed a bug where the IRQ wasn't being set properly if you used PLAY and a CoCo 3 GMODE 

V 4.36
- Added command CPUSPEED # where # is 1 for .895 Mhz, 2 for 1.79 Mhz, 3 for 2.8636 MHz and anything else will
  set the speed to max for that computer's hardware.  Which also will put a 6309 in native mode.
- Added command COPYBLOCKS, which copies 8k blocks using stack blasting useful for CoCo3 copying from buffer 0 to buffer 1
- Fix a bug with deep IF/THEN/ELSE layers that could exit to the wrong location
- Tweaked the DIV16 & DIV16Rounding code so that the resulting value in D will be reflected in the condition codes when exiting the
  routine
- IDE fixed F11 not working

V 4.35
- Fixed a problem with handling DATA statements that had many comma's in a row like (DATA "THIS",,,2,,)

V 4.34
- Can now handle 10000 IF/THEN/ELSE commands per program, was previously set at 100
- Fixed a bug detecting string array variables
- Made STRING$ function now handle ascii codes instead of only string values for the 2nd value in the command
- Fixed a bug with MID$
- can now handle 1000 deep expression comparisons, was limited to 10 previously
- Fixed a bug with IF/THEN/ELSE where compiler could re-use the same labels
- Fixed a bug with numeric arrays with one element (wasn't pointing at the correct RAM location)
- Fixed a bug with the SDC_GETCURDIR$ command
- Fixed a bug with the PLAY command (IRQ was returning to the wrong location)
- PLAY command now automatically plays at normal speed then automatically speeds up the CoCo after playing

V 4.33
- If your CoCo 3 can support 2.8 Mhz high speed the compiled code now runs at triple speed (2.8 Mhz)
  for most operations (not disk, etc.)

V 4.32
- Added new command SDC_BIGLOADM, for fast loading the CoCo 3 memory banks, useful for loading game backgrounds or
  Other large amounts for data
- Added support for Drive number 0 or 1 for the SDC_Play commands

V 4.31
- Fixed a bug in the SDC_LOADM command that wasn't loading from drive # 0 properly    

V 4.30
- Fixed a couple bugs with the LOADM command (wasn't finding the last granule properly if the file used granules beyond $40)

V 4.29
- Added support for the NTSC composite video out modes (256 colours) for the CoCo3, these are new GMODE values from 160 to 165 - See
  the updated manual for more info
  - Added new command NTSC_FONTCOLOURS b,f to set the background and foreground colours of the fonts used with the new NTSC composite output GMODEs

V 4.28
- Fixed a bug where the tokenizer couldn't handle a number then an operator then a numeric command like 120+RNDZ(20)

V 4.27
- Added some CoCo hardware detection code, to detect if the CoCo is running on a CoCo 1 & 2 or a CoCo 3 and also
  detect if there is a 6309 or a 6809 installed.  With this info the LOADM command and all the SDC_PLAY commands will now go to
  normal speed while using those commands and go back to high speed/native mode (if it can) afterwards.
  
V 4.26
- Fixed LOADM command not working if your CoCo has a 6309 as it would mess with the timing and LOADM would fail, now it goes back to
  Emulation mode so the timings are the same as the 6809 while loading.  After loading it will put the 6309 back into native mode.

V 4.25
- Fixed a bug with with using numeric commands like RNDZ(x) before an close bracket of a graphics command like SET(x,y,RNDZ(3))

V 4.24
- Fixed a bug in the compiler when it was assigning the value of an equation to a variable.  If the equation didn't have a
  variable and it was doing AND, OR, XOR or MOD it was not setting the variable properly.  It also wasn't handling HEX values
  properly in this same routine.

V 4.23
- Made the Tokenizer a little more robust, it now detects array names better if there aren't spaces before the array name and
  the array is being used in an equation.

V 4.22
- Fixed a bug with large BASIC programs especially if it used a large amount of space for the ADDASSEM: section

V 4.21
- Fixed a bug where the PROGRAM start was not being setup to the correct address when GMODE was being used.  Thanks to 
  Tazman (Scott Cooper) for finding the bug.

V 4.20
- Fixed a bug in GMODE 1 graphic commands (This mode only supports two colours, not 9 like GMODE 0)
- Added printing to the screen using the semi-graphic modes, the semi-graphics modes use the built in VDG font except for GMODE 4
  which uses SG6 and the built in fonts aren't supported in the this mode.  So the font that is shown is a large 6x6 matrix font.
  Now every GMODE can now print text on the screen using LOCATE x,y:PRINT #-3,"Hello World"

V 4.11
- Can now handle MID$(String,Start) which will copy the String starting at location Start copying the rest of the string.  It no
  longer needs to be MID$(String,Start,Length).  

V 4.10
- Added text fonts that can be used directly in any graphics mode including CoCo 3 modes but not the semi graphic modes
  Use LOCATE x,y and PRINT #-3,"Hello World" to print
  to the graphics screen.  You must select the font using the -f option.  The font names end with _Bx_Fx where Bx is the Background
  colour and Fx is the Foreground colour. Example: -fCoCoT1_B0_F2
- Can now put compiler options on the first line of the program using ' CompilerOptins:
  Example:  'CompileOptions: -fArcade_B0_F1 -o -s32

V 4.03
- Fixed a bug in the GCOPY command
- Tweaked the code for the GMODE command

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
