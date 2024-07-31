# BASIC-To-6809
A BASIC compiler for the TRS80 Color Computer

For more info check out the blog post here:
https://wordpress.com/post/nowhereman999.wordpress.com/5054

V 1.17

- Fixed numeric and String arrays with multi dimensions, wasn't storing the values properly

- Renamed inlude file PRINT.ASM to Print.asm

- Fixed VAL command, would return with zero if the string started with a space before the number

- Fixed the Print command, was ignoring , or ; after a string variable
 
V 1.18
- Fixed ADDASSEM and ENDASSEM which are now working correctly

- Added option and changed the code to allow the user to select the Max size of string arrays, max will be 255
  but the user should be able to set it lower to save space
  
V 1.19
- The program now closes files #1 and #2 before killing the old one and renaming the Temp.txt to the correct .asm filename when removing unnecessary lines, this was causing file permission errors on Windows OS machines
