defaultF11:
	echo "Processing $(FILE)"
# Compile program $(FILE)
	./BasTo6809 -ascii $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Add other commands to copy the program onto a .DSK file and start an emulator
#	-rm GO.BIN
#	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
#	-rm $(FILENOEXT).bin
#	-mv GO.BIN $(FILENOEXT).bin
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN
#	mame -debug -window -r 1280x800 coco3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -autoboot_command "\n\n\n\nLOADM\"$(FILENOEXT)\":EXEC\n" -ui_active -natural
# Or Xroar
#	xroar -machine coco3h -ram 2048 -kbd-translate -load-fd0 ./DISK1.DSK 

# Compile a 64k CoCo 1 program
Command1:
	echo "Processing $(FILE)"
# Compile program $(FILE)
	./BasTo6809 -ascii $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Add other commands to copy the program onto a .DSK file and start an emulator
# Use the CoCo 1 Super Loader so it will load a 64k program
	-rm GO.BIN
	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
	-rm $(FILENOEXT).bin
	-mv GO.BIN $(FILENOEXT).bin
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN
#	mame -debug -window -r 1280x800 coco3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -autoboot_command "\n\n\n\nLOADM\"$(FILENOEXT)\":EXEC\n" -ui_active -natural
# Or Xroar
	xroar -machine coco3h -ram 2048 -kbd-translate -load-fd0 ./DISK1.DSK 3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -autoboot_command "\n\n\n\nLOADM\"$(FILENOEXT)\":EXEC\n" -ui_active -natural

Command2:
# Compile program $(FILE)
	./BasTo6809 -ascii $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN

Command3:
# Compile program $(FILE)
	./BasTo6809 -ascii $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN

Command4:
# -b1 option will make a faster and smaller binary but LWASM will take a long time to generate the .BIN file
	./BasTo6809 -ascii -b1 $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN

# Could have this option to compile and save the DISK1.DSK image to an SD card directly
Command5:
# Compile program $(FILE) to an assembly file
	./BasTo6809 -ascii $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN
# Copy to an SD card called SD16MB to use with the CoCo SDC
#	-rm /Volumes/SD16MB/DISK1.DSK
#	cp ./DISK1.DSK /Volumes/SD16MB/DISK1.DSK
#	diskutil eject /Volumes/SD16MB/

Clean:
# Erase .bin/.BIN files
	-rm -f *.bin *.BIN
