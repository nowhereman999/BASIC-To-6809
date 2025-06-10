defaultF11:
	echo "Processing $(FILE)"
# Compile program $(FILE)
	./BasTo6809 -ascii -b1 $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# Add other commands to copy the program onto a .DSK file and start an emulator in debug mode
#	-rm GO.BIN
#	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
#	-rm $(FILENOEXT).bin
#	-mv GO.BIN $(FILENOEXT).bin
#	-imgtool del coco_jvc_rsdos ./DISK1.DSK $(FILENOEXT).bin
#	imgtool put coco_jvc_rsdos ./DISK1.DSK $(FILENOEXT).bin $(FILENOEXT).BIN
#	mame -debug -window -r 1280x800 coco3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -ui_active -natural

Command1:
# Compile program $(FILE)
	./BasTo6809 -ascii -b1 $(FILE)

Command2:
# Compile program $(FILE)
	./BasTo6809 -ascii -b1 $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt

Command3:
# Compile program $(FILE)
	./BasTo6809 -ascii -b1 $(FILE)
# Use LWASM to assemble $(FILENOEXT).asm into a CoCo LOADMable program called $(FILENOEXT).bin
	./lwasm -9bl -p cd -o./$(FILENOEXT).bin $(FILENOEXT).asm > ./NEW_Assembly_Listing.txt
# for a coco1 program that is bigger than 32k you must use the CoCo1 Super loader.
	-rm GO.BIN
	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
	-rm $(FILENOEXT).bin
	-mv GO.BIN $(FILENOEXT).bin

Command4:
# -b1 option will make a faster and smaller binary but LWASM will take a long time to generate the .BIN file
	./BasTo6809 -ascii -b1 test1.bas
# Use LWASM to assemble test1.asm into a CoCo LOADMable program called test1.bin
	./lwasm -9bl -p cd -o./test1.bin test1.asm > ./NEW_Assembly_Listing.txt
# for a coco1 program that is bigger than 32k you must use the CoCo1 Super loader.
	-rm GO.BIN
	./cc1sl -l $(FILENOEXT).bin -oGO.BIN
	-rm $(FILENOEXT).bin
	-mv GO.BIN $(FILENOEXT).bin

Command5:
	./BasTo6809 -ascii -b1 test1.bas
# Use LWASM to assemble test1.asm into a CoCo LOADMable program called test1.bin
	./lwasm -9bl -p cd -o./test1.bin test1.asm > ./NEW_Assembly_Listing.txt
# Add other commands to copy the program onto a .DSK file and start an emulator
#	-imgtool del coco_jvc_rsdos ./DISK1.DSK $(FILENOEXT).bin
#	imgtool put coco_jvc_rsdos ./DISK1.DSK $(FILENOEXT).bin $(FILENOEXT).BIN
#	mame -window -r 1280x800 coco3h -ramsize 2M -flop1 ./DISK1.DSK -throttle -frameskip 0 -ui_active -natural
# Or Xroar
#	xroar -machine coco3h -ram 2048 -kbd-translate -load-fd0 ./DISK1.DSK 

Clean:
# Erase .bin/.BIN files
	-rm -f *.bin *.BIN
