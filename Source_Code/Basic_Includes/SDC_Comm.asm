********************************************************************
* CoCo SDC Low-level interface routine
*
*--------------------------------------------------------------------------
* CommSDC
*
*    This is the core routine used for all
*    transactions with the SDC controller.
*
* Entry:
*    A = Command code
*    B = LSN hi byte   or  First parameter byte
*    X = LSN lo word   or  2nd and third parameter bytes
*    U = Address of 256 byte I/O buffer ($FFFF = none)
*
* Exit:
*    Carry set on error.
*    B = controller status code.
*    A, X, Y and U are preserved.
*

* Hardware Addressing - CoCo Scheme
CTRLATCH       equ       $FF40              controller latch (write)
CMDREG         equ       $FF48              command register (write)
STATREG        equ       $FF48              status register (read)
PREG1          equ       $FF49              param register 1
PREG2          equ       $FF4A              param register 2
PREG3          equ       $FF4B              param register 3
DATREGA        equ       PREG2              first data register
DATREGB        equ       PREG3              second data register

* Status Register Masks
BUSY           equ       %00000001          set while a command is executing
READY          equ       %00000010          set when ready for a data transfer
FAILED         equ       %10000000          set on command failure

* Mode and Command Values
CMDMODE        equ       $43                control latch value to enable command mode
;CMDREAD        equ       $80                read logical sector
;CMDWRITE       equ       $A0                write logical sector
;CMDEX          equ       $C0                extended command
;CMDEXD         equ       $E0                extended command with data block

CommSDC:       pshs      u,y,x,a,cc         preserve resgisters
               lsr       ,s                 shift carry flag out of saved CC

* Put controller in Command mode
               ldy       #DATREGA           setup Y for hardware addressing
               lda       #CMDMODE           the magic number
               sta       -10,y              send to control latch (FF40)

* Put input parameters into the hardware registers.
* It does no harm to put random data in the
* registers for commands which dont use them.
               stb       -1,y               high byte to param reg 1
               stx       ,y                 low word to param regs 2 and 3

* Wait for Not Busy.
               bsr      waitForIt           run polling loop
               bcs      cmdExit             exit if error or timeout

* Send command to controller
               lda      1,s                 get preserved command code from stack
               sta      -2,y                send to command register (FF48)

* Determine if a data block needs to be sent.
* Any command which requires a data block will
* have bit 5 set in the command code.
               bita      #$20               test the "send block" command bit
               beq       rxBlock            branch if no block to send

* Wait for Ready to send
               bsr      waitForIt           run polling loop
               bcs      cmdExit             exit if error or timeout
               leax     ,u                  move data address to X

* Send 256 bytes of data
               ldd       #32*256+8          32 chunks of 8 bytes
txChunk        ldu       ,x                 send one chunk...
               stu       ,y
               ldu       2,x
               stu       ,y
               ldu       4,x
               stu       ,y
               ldu       6,x
               stu       ,y
               abx                          point X at next chunk
               deca                         decrement chunk counter
               bne       txChunk            loop until all 256 bytes sent

* Wait for command completion
               lda       #5                 timeout retries
waitCmplt      bsr       waitForIt          run polling loop
               bitb      #BUSY              test BUSY bit
               beq       cmdExit            exit if completed
               deca                         decrement retry counter
               bne       waitCmplt          repeat until 0
               coma                         set carry for timeout error
               bra       cmdExit            exit

* For commands which return a 256 byte response block the
* controller will set the READY bit in the Status register
* when it has the data ready for transfer.   For commands
* which do not return a response block the BUSY bit will
* be cleared to indicate that the command has completed.
*
rxBlock        bsr       longWait           run long status polling loop
               bls       cmdExit            exit if error, timeout or completed
               leax      1,u                test the provided buffer address
               beq       cmdExit            exit if "no buffer" ($FFFF)
               leax      ,u                 move data address to X

* Read 256 bytes of data
               ldd       #32*256+8          32 chunks of 8 bytes
rxChunk        ldu       ,y                 read one chunk...
               stu       ,x
               ldu       ,y
               stu       2,x
               ldu       ,y
               stu       4,x
               ldu       ,y
               stu       6,x
               abx                          update X for next chunk
               deca                         decrement chunk counter
               bne       rxChunk            loop until all 256 bytes transferred
               clrb                         status code for SUCCESS, clear carry

* Exit
cmdExit        rol       ,s                 rotate carry into saved CC on stack
               clr       -10,y              end command mode
               puls      cc,a,x,y,u,pc      restore irq masks, update carry and return

*--------------------------------------------------------------------------
* Wait for controller status to indicate either "Not Busy" or "Ready".
* Will time out if neither condition satisfied within a suitable period.
*
* Exit:
*    CC.C set on error or time out.
*    CC.Z set on "Not Busy" status (if carry cleared).
*    B = status
*    X is clobbered.  A, Y and U are preserved.
*
longWait       bsr       waitForIt          enter here for doubled timeout
               bcc       waitRet            return if cleared in 1st pass
waitForIt      ldx       #0                 setup timeout counter
waitLp         comb                         set carry for assumed FAIL
               ldb       -2,y               read status
               bmi       waitRet            return if FAILED
               lsrb                         BUSY --> Carry
               bcc       waitDone           branch if not busy
               bitb      #READY/2           test READY (shifted)
               bne       waitRdy            branch if ready for transfer
               bsr       waitRet            consume some time
               ldb       #$81               status = timeout
               leax      ,-x                decrement timeout counter
               beq       waitRet            return if timed out
               bra       waitLp             try again

waitDone       clrb                         Not Busy: status = 0, set Z
waitRdy        rolb                         On Ready: clear C and Z
waitRet        rts                          return

