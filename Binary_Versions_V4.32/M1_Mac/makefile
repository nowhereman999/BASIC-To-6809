# Makefile

# Use a default if not provided
TARGET ?= HELLO

compile:
	./BasTo6809 $(TARGET).BAS
	./lwasm -9bl -p cd -o./$(TARGET).BIN $(TARGET).asm > ./NEW_Assembly_Listing.txt

compilefastest:
	./BasTo6809 -b1 TARGET
	./lwasm -9bl -p cd -o./$(TARGET).BIN $(TARGET).asm > ./NEW_Assembly_Listing.txt
