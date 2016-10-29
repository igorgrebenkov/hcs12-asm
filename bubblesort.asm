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
arr_n       dc.b        5, 2, 9, 7, 6, 1, 4, 3, 11, 8       ; integer array to sort


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
; Stack usage
            OFFSET 0
arr_ptr     ds.w        1           ; pointer to integer array
arr_len     ds.b        1           ; length of the array


mainLoop:
            leas        -3,sp               ; allocate 2 bytes for arr_ptr
            ldx         #arr_n              ; get pointer to array
            stx         arr_ptr,sp          ; push array pointer to stack
            ldaa        #10                 ; length of test array is 10
            staa        arr_len,sp          ; push length to stack
            clra
            clrb                           
            jsr         bubblesort
                  
; Subroutine: void bubblesort(int* n, int len)
; Parameters:
;       n - an array of integers
;       len - the length of the array
; Local Variables: (all on the stack)
;       upper - pointer with address forupper bound when iterating 
;               through the array (= n + len - 1)
;       curr  - pointer to the current element we are comparing with the next
;       next  - pointer to the element after current that we must compare
;       sorting - boolean that indicates if a swap has been performed (0 if no swaps)
;       sorted  - boolean that indicates if sorting is complete (0 if not complete)
; Returns: void
; Description: sorts an array using the bubblesort algorithm

; Stack Usage
                OFFSET 0
bs_upper        ds.w            1           ; pointer to second last elem of int array
bs_sorting      ds.b            1           ; boolean flag for if a swap has been performed
bs_sorted       ds.b            1           ; boolean flag for if we are still sorting   
bs_x            ds.w            1           ; x register
bs_ra           ds.w            1           ; return address
bs_arr_ptr      ds.w            1           ; pointer to int array
bs_arr_len      ds.b            1           ; pointer to array length

bubblesort:     pshx                            ; preserve x
                leas        -4,sp               ; allocate space on stack for local variables
                ldab        bs_arr_len,sp       ; *** initializing bs_upper ***
                addd        bs_arr_ptr,sp        
                sbcb        #1
                std         bs_upper,sp                   
                movb        #0,bs_sorting,sp    ; *** initializing bs_sorting ***
                movb        #0,bs_sorted,sp     ; *** initializing bs_sorted ***
                clra
                clrb 
bs_while:
                tst         bs_sorted,sp        ; while (!sorted) {
                bne         bs_endwhile
                ldx         bs_arr_ptr,sp       ;            
bs_for:                                         ;   for(curr = n; curr < upper; curr++) {                 
                cpx         bs_upper,sp
                beq         bs_ifsorting        ;       // curr == upper, for loop is done
                tfr         X,Y                 ;       next = curr + 1;
                iny                
bs_ifswap:            
                ldd         0,X                 ;       if (*curr > *next) {
                cpd         0,Y
                bgt         bs_swapnums
                bra         bs_endif
bs_swapnums:    
                ldaa        0,X                 ;           int tmp = *curr
                ldab        0,Y         
                stab        0,X                 ;           *curr = *next;
                staa        0,Y                 ;           *next = temp;
                movb        #1,bs_sorting,sp                            
bs_endif:
                inx                             ;           // curr++
                bra         bs_for    
bs_endfor:                                                        
bs_ifsorting:   
                tst         bs_sorting,sp       ;           if (!sorting) {
                bne         bs_elseifsorting
                movb        #1,bs_sorted,sp     ;               sorted = 1;
                bra         bs_endifsorting                
bs_elseifsorting:                               ;           else {
                movb        #0,bs_sorting,sp    ;               sorting = 0
                                                ;           }
bs_endifsorting:                                ;       }
                bra         bs_while            ;    }
bs_endwhile:                                    ; }
                leas        4,sp                ; free stack
                pulx                            ; restore x
                rts
  
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
