# BASIC-To-6809
A BASIC compiler for the TRS80 Color Computer

For more info check ou the blog post here:
https://wordpress.com/post/nowhereman999.wordpress.com/5054

Added Version 1.17 with the following fixes/changes
'        - Fixed numeric and String arrays with multi dimensions, wasn't storing the values properly
'        - Renamed inlude file PRINT.ASM to Print.asm
'        - Fixed VAL command, would return with zero if the string started with a space before the number
'        - Fixed the Print command, was ignoring , or ; after a string variable
