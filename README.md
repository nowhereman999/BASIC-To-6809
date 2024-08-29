# BASIC-To-6809
A BASIC compiler for the TRS80 Color Computer

For more info check out the blog post here:
https://wordpress.com/post/nowhereman999.wordpress.com/5054

## Building
For each BasTo6809*.bas file:
1. Load the file into QB64E
2. Compile the file by selecting `Run->Make Executable Only`

## Releasing
1. Update `V$ = "X.Y"` in Basto6809.Main.bas
2. Update this README file.
3. `git commit . -m "Updated version"`
4. `git tag vX.Y`
5. `git push origin tag vX.Y`
6. Edit the newly created release located in Releases.

## Releases
V 2.03
- Added -v (version) and -h (help) commandline options

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
- The three programs are: BasTo6809_2.00.Main.bas, BasTo6809_2.00.1.Tokenizer.bas & BasTo6809_2.00.2.Compile.bas
- Once all three are compiled start the compiler with the usual options as (or similar to): ./BasTo6809_2.00.Main -ascii -v0 -o2 -b0 YourProgram.bas

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
