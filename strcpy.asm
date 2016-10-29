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
arr_source      DC.B    $33, $56, $31, $76, $62, $00    ; source array
arr_dest        DC.B    6                               ; destination array



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1         ; initialize the stack pointer

            CLI                     ; enable interrupts
            
; Stack usage
            
            OFFSET 0
arr_sP      DS.W        1           ; pointer to destination array            
arr_dP      DS.W        1           ; pointer to source array
            
mainLoop:           
            leas        -4,sp               ; allocate stack for pointers to arrays               
            ldx         #arr_source
            stx         arr_sP,sp           ; push pointer to source array on stack
            ldx         #arr_dest           
            stx         arr_dP,sp           ; push pointer to dest array on stack
            jsr         strcpy
            ldd         #$FF
            
; Subroutine: char* strcpy(char* destination, const char* source)
; Parameters:
;       destination - the destination array
;       source - the source array
; Local Variables: none
; Returns: pointer to destination array with contents of source array copied
; Description: copies the string from source to destination

; Stack usage
                OFFSET 0
scp_X           DS.W        1   ; X register
scp_Y           DS.W        1   ; Y register
scp_RA          DS.W        1   ; return address
scp_arr_sP      DS.W        1   ; pointer to source array
scp_arr_dP      DS.W        1   ; pointer to dest array

strcpy:         pshx                        ; preserve x                    
                pshy                        ; preserve y
                ldx     scp_arr_sP,sp
                ldy     scp_arr_dP,sp
scp_while:      
                tst     0,X                 ; reached nul?
                beq     scp_endwhile
                movb    0,X,0,Y             ; copy char from source to dest
                inx                         ; increment source pointer
                iny                         ; increment destination pointer
                bra     scp_while                
scp_endwhile:
                movb    0,X,0,Y             ; copy nul character
                puly                        ; restore y
                pulx                        ; restore x
                rts    
                     
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
