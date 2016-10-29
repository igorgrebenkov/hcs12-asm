;**************************************************************
;* This stationery serves as the framework for a              *
;* user application. For a more comprehensive program that    *
;* demonstrates the more advanced functionality of this       *
;* processor, please see the demonstration applications       *
;* located in the examples subdirectory of the                *
;* Freescale CodeWarrior for the HC12 Program directory       *
;**************************************************************
; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

; export symbols
            XDEF Entry, _Startup, main
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack




; variable/data section
MY_EXTENDED_RAM: SECTION
; Insert here your data definition.

NewSection:     SECTION
startNew:   ldx     #$1111


; code section
MyCode:     SECTION
main:
_Startup:
Entry:

            LDS     #__SEG_END_SSTACK     ; initialize the stack pointer
            CLI            
                                         
; Stack Usage
    OFFSET 0
num1    DC.W    1   ; the first number we add to
num2    DC.w    1   ; the number we add to num2
varsize EQU     2   ; numer of bytes to reserve for local vars

start:
        leas    -varsize,SP     ; allocate stack space
        ldd     #$1
        pshd                    ; push num1 to stack
        ldd     #$2
        pshd                    ; push num2 to stack
        jsr     add             ; add num1 and num2; result in num 2
        ldx     #$FF
        
; Subroutine: int* add(int* a, int* b)
; Parameters:
;       a - pointer to first integer (in stack)
;       b - pointer to second integer (in stack)
; Returns:
;       a - pointer to sum of a and b, on stack
; Local Variables: 
          

	OFFSET 0 ; to setup offsets into stack
ADD_X       DS.W    1   ; preserve X
ADD_D       DS.W    1   ; preserve D
ADD_RA      DS.W    1   ; return address
ADD_NUM1    DS.W    1   ; first number
ADD_NUM2    DS.W    1   ; second number to add to first

add:    pshx                    ; preserve x
        pshd                    ; preserve d
        ldd     ADD_NUM1,SP     ; load d with the first number
        addd    ADD_NUM2,SP     ; add num2 to d
        std     ADD_NUM1,SP     ; store back in num1
        puld                    ; restore d
        pulx                    ; restore x
        rts
                     




   


        