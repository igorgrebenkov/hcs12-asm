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
str1        DC.B    $01,$02,$03,$04,$0
str2        DC.B    $05,$06,$07,$08,$0


; code section
            ORG   ROMStart

Entry:
_Startup:
            LDS   #RAMEnd+1         ; initialize the stack pointer

            CLI
            
                                    ; enable interrupts
                                    
; Subroutine: main()
; Parameters: none
; Returns: nothing
; Local Variables:
;       str1 - char array of size 5
;       str2 - char array of size 5
; Description: The main function.
        OFFSET 0
MAIN_STR1       DS.W    1
MAIN_STR2       DS.W    1
MAIN_VARSIZE  EQU       4
 
main:
            leas    -MAIN_VARSIZE,SP    ; allocate space on stack for str pointers
            ldx     #str2
            pshx                        ; push pointer to str1 to stack
            ldx     #str1
            pshx                        ; push pointer to str2 to stack
            jsr     strcat            


; Subroutine: char* strcat(char* str1, char* str2)
; Parameters:
;       str1 - the first string
;       str2 - the string to concatenate to string 2
; Local Variables:
;       p - pointer used to concatenate to str1
; Returns:
;       str1 - pointer to the now concatenated string
; Description:
;       Concatenates str2 to str1

; Stack usage
                    OFFSET 0
STRCAT_X            DS.W    1   ; preserve x
STRCAT_Y            DS.W    1   ; preserve y
STRCAT_VARSIZE: 
STRCAT_RA           DS.W    1   ; return address
STRCAT_STR1         DS.W    1   ; first string
STRCAT_STR2         DS.W    1   ; second string

strcat:             pshx                        ; preserve x
                    pshy                        ; preserve y
                    ldx     STRCAT_STR1,SP
                    jsr     findEnd
                    ldy     STRCAT_STR2,SP

STRCAT_while:
                    tst     0,Y                 ; is current char in str2 nul?
                    beq     STRCAT_endWhile
                    movb    0,Y,0,X             ; add chars, one by one
                    inx                         ; increment x
                    iny                         ; increment y
                    bra     STRCAT_while                    
STRCAT_endWhile
                    movb    0,Y,0,X             ; terminate with null
                    puly                        ; restore x
                    pulx                        ; restore y
            
            
; Subroutine: char* findend(char* str)
; Parameters:
;       str - pointer to first char in string
; Local Variables: 
; Returns:
;       str - pointer to the end of the string
; Description:
;       Returns a pointer to the nul char of the input string

; Stack usage
FEND_RA     DS.W    1   ; return address

findEnd:
FEND_while: 
            tst     0,X             ; check if value pointed by X is 0
            beq     FEND_endWhile
            inx                     ; increment x
            bra     FEND_while
FEND_endWhile:
            RTS
            


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
