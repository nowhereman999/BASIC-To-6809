# Trace function in mame Verbose
# 6309 version
# trace output.tr.txt,0,,{tracelog "A=%02X,B=%02X,E=%02X,F=%02X,X=%04X,Y=%04X,U=%04X,S=%04X,CC=%02X ",a,b,e,f,x,y,u,s,cc}
# trace output.tr.txt,0,noloop,{tracelog "A=%02X,B=%02X,E=%02X,F=%02X,X=%04X,Y=%04X,U=%04X,S=%04X,CC=%02X ",a,b,e,f,x,y,u,s,cc}
# 6809 version
# trace output.tr.txt,0,,{tracelog "A=%02X,B=%02X,X=%04X,Y=%04X,U=%04X,S=%04X,CC=%02X ",a,b,x,y,u,s,cc}
# trace output.tr.txt,0,noloop,{tracelog "A=%02X,B=%02X,X=%04X,Y=%04X,U=%04X,S=%04X,CC=%02X ",a,b,x,y,u,s,cc}
#
# Amiga MC68000 - Trace Function
# trace output.tr.SpriteJumpCheck.txt,0,,{tracelog "D0=%08X,D1=%08X,D2=%08X,D3=%08X,D4=%08X,D5=%08X,D6=%08X,D7=%08X\nA0=%08X,A1=%08X,A2=%08X,A3=%08X,A4=%08X,A5=%08X,A6=%08X,SP=%08X ",d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,sp}
#
# 6502 - Trace emulation:
# trace output.tr.txt,0,noloop,{tracelog "A=%02X,X=%02X,Y=%02X,P=%02X,SP=%04X,IR=%02X ",a,x,y,p,sp,ir}
#
# Put an ascii file on a coco disk image:
# decb copy -0 PICALC.bas DISK1.DSK,PICALC.BAS -a0l
# decb kill DISK1.DSK,TEST1.BAS
# decb copy -0 PICALC.bas DISK1.DSK,TEST1.BAS -a0l

defaultF11:
	echo "Processing $(FILE)"
# Compile program $(FILE)
	./BasTo6809 -ascii $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
#	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
	./lwasm -9bl -o$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt -i
# Add other commands to copy the program onto a .DSK file and start an emulator
	-rm GO.BIN
	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
	-rm $(FILENOEXT).bin
	-mv GO.BIN $(FILENOEXT).bin
# Copy a BLANK disk image to one called DISK1.DSK
	-cp ./BLANK.DSK DISK1.DSK
# Copy users executable program onto DISK1
# decb copy -2 -b -r <pcfilename.bin> <diskimage.dsk>,<COCOMP3.BIN>
	./decb copy -2 -b -r $(FILENOEXT).bin DISK1.DSK,$(FILENOEXT).BIN
#	./decb copy -2 -b -r AMITEST.BIN DISK1.DSK,AMITEST.BIN
#	./decb copy -2 -b -r 3D000001.BIN DISK1.DSK,3D000001.BIN
	./mame -src_debug_info ./$(FILENOEXT).bin.mdi -debug -window -r 1280x800 coco2b -ramsize 2M -ext multi -ext:multi:slot2 ccpsg -ext:multi:slot3 orch90 -ext:multi:slot4 fdc -flop1 ./DISK1.DSK -printout PrinterFile.txt -nothrottle -frameskip 0 -autoboot_command "\n\n\n\nLOADM\"$(FILENOEXT)\":EXEC\n" -ui_active -skip_gameinfo -natural
# Or Xroar
#	xroar -machine coco3h -ram 2048 -no-ratelimit -kbd-translate -load-fd0 ./DISK1.DSK 

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
	xroar -machine coco -ram 64 -no-ratelimit -kbd-translate -load-fd0 ./DISK1.DSK 

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
	echo "Processing $(FILE) for SD"
	@echo "Mounting SD card..."
	@if [ -n "$(SDCARD_DEV)" ]; then \
		diskutil mountDisk /dev/$(SDCARD_DEV); \
	else \
		echo "SD card not found."; \
	fi

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
# Copy to an SD card called SD16MB to use with the CoCo SDC
	-rm /Volumes/SD16MB/DISK1.DSK
	cp ./DISK1.DSK /Volumes/SD16MB/DISK1.DSK
	diskutil eject /Volumes/SD16MB/

Clean:
# Erase .bin/.BIN files
	-rm -f *.bin *.BIN
