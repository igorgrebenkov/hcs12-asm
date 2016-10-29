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
str1        DC.B        $21, $54, $12, $56, $15, $1F, $00


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
; Stack usage
            OFFSET 0
str1_arr    DS.W        1               ; pointer to first elem of string
charPtr     DS.W        1               ; pointer to char found
charFind    DS.B        1               ; the char we are looking for

mainLoop:
                leas        -5,sp           ; allocate 4 bytes on stack for variables
                ldx         #str1           ; load pointer to str
                stx         str1_arr,sp     ; store pointer to str on stack
                ldx         #-$1            ; load -1 to charPtr; if char not found we will know it this way
                stx         charPtr,sp      ; put charPtr on stack
                ldaa        #$12
                staa        charFind,sp     ; put char we are looking for on stack
                jsr         strchr
                ldy         charPtr,sp
               
                
; Subroutine: char* strchr(char* str, int character)
; Parameters:
;       str - the string we are searching 
;       character - the character we are looking for
; Local variables: none
; Returns:
;       charPtr - pointer to the char we are looking for (if found)
;               - else, stack variable with value -1
; Description: Searches for the character in the input string

; Stack usage
                OFFSET 0
schr_x          DS.W        1       ; x register
schr_a          DS.B        1       ; a register
schr_b          DS.B        1       ; b register
schr_ra         DS.W        1       ; return address
schr_str1_arr   DS.W        1       ; the string we are searching
schr_charPtr    DS.W        1       ; pointer to char we found (if found)
schr_charFind   DS.B        1       ; the char we are looking for

strchr:         pshx                            ; preserve x
                psha                            ; preserve a
                pshb                            ; preserve b
                ldx         schr_str1_arr,sp    ; load pointer to string
                ldaa        schr_charFind,sp    ; load char to find in a register
schr_while:
                tst         0,X                 ; is current char nul?
                beq         schr_endwhile
                ldab        0,X                 ; load current char to b register
                cba                             ; compare a to b
                beq         schr_found          ; if we have a match, we can exit to save it
                inx                             ; increment x
                bra         schr_while
schr_found:                             
                stx         schr_charPtr,sp     ; save pointer to the car 
schr_endwhile:                 
                pulb                            ; restore b
                pula                            ; restore a
                pulx                            ; restore x
                rts
 


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
