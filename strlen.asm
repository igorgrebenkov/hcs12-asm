;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
; Insert here your data definition.
arr     DC.B      $32, $33, $34, $35, $37, $11, $64, $55, $00

    OFFSET 0
main_arr    DS.W    1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
            leas    -2,SP           ; allocate space for char array
            ldx     #arr            ; load address of first elem in char array
            pshx                    ; push address to stack
            jsr     strlen
          
            

; Subroutine: int strlen(char* str) 
; Parameters:
;       str - string to find length of (in the stack)
; Local Variables:
;       length - counter used to find length of string (in the stack)
; Returns:
;       the length of str
; Description: 
;       finds the length of a string
            OFFSET 0
slen_length DS.B    1       ; counter to calculate length
slen_X      DS.W    1       ; preserve x
slen_Y      DS.W    1       ; preserve y
slen_RA     DS.W    1       ; return address
slen_arr    DS.W    1       ; the array to check the length of

strlen:     pshy
            pshx
            leas        -1,SP
            ldx         slen_arr,sp
            ldy         #$0
while: 
            tst         0,X
            beq         end_while
            inx 
            iny
            bra         while         
end_while:  
            sty         slen_length,sp
            ldd         slen_length,sp
            pulx
            puly
            rts
            
            



;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
