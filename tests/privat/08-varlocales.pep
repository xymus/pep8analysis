; Programme qui r�serve des variables locales
; Jean Privat (c) 2010
         LDA     1,i         
         LDX     2,i         
         CALL    fun         
         STOP                
;
fun:     SUBSP   4,i         ; r�server #funVar1 #funVar2
         STA     funVar1,s   ; funVar1 = A
         STX     funVar2,s   ; funVar2 = X
;        ...
         ADDSP   4,i         ; r�r�server #funVar1 #funVar2
         RET0                
funVar1: .EQUATE 2           ; variable locale #2d
funVar2: .EQUATE 0           ; variable locale #2d
         .END                  