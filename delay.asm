;----------------------------------------------------------------------
;   Elf-OS delay routine using brute force hard loop method. The timing
;   is not exact but close enough for most purposes. A maximum of 65,536
;   millisecond delay (65.5) seconds can be specified. Values above
;   65,536 milliseconds as not supported and will not give the desired 
;   result. 
;
;   Copyright (c) 2023 Bernard Murphy
;
;----------------------------------------------------------------------

#include ops.inc
#include bios.inc
#include kernel.inc

            org     2000h-6 
            dw      2000h                    ; header, where program loads
            dw      endrom-2000h              ; length of program to load
            dw      2000h                    ; exec address
            
            org     2000h

          
start:      br    main      
            ever
            db    'See github.com/BernieMurphy/Elfos-delay for more info',0

            ; Main code starts here, check provided argument
main:       mov   rf, ra                     ; copy input pointer to rf
            call  f_ltrim                    ; rf will have pointer to non blank 
            call  f_atoi                     ; rd will have converted number 
            bdf   usage                      ; df = 1 means invalid number
            ldn   rf                         ; look at first non numeric character
            bnz   usage                      ; no null, so error out 
            ghi   rd                         ; get converted number msb
            bnz   delay0                     ; is msb byte zero?
            glo   rd                         ; get converted number lsb
            bnz   delay0                     ; is lsb byte zero?
            ldi   0                          ; set good return code 
            rtn                              ; exit now as delay was zero
            



delay0:     equ    $
            ldi    83                        ; delay 1 ms (for 4 MHz clock)
            plo    rc

delay1:     dec    rc
            glo    rc
            bnz     delay1
            dec     rd                       ; countdown millisecond value
            ghi      rd
            bnz     delay0
            glo      rd
            bnz     delay0                    ; delay will not be exact 
            ldi        0                      ; success return code
            rtn

usage:      call  o_inmsg
            db    'Usage: delay  <milliseconds>',10,13,0
            ldi   $0c                         ; error return code                      
            rtn

endrom:     equ   $
padding:    db    0                           ; keep asm02 happy
         
            end    main