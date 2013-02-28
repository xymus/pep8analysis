; Sous-programme qui incr�mente un mot pass� par r�f�rence
; Jean Privat (c) 2010
         LDA     5,i         
         STA     mot,d       ; mot = 5;
         DECO    mot,d       ; print(mot);
         SUBSP   2,i         ; r�serve #incrVar
         LDA     mot,i       
         STA     0,s         ; incrVar = &mot
         CALL    incr        
         ADDSP   2,i         ; lib�re #incrVar
         CHARO   ' ',i       
         DECO    mot,d       ; print(' '+mot);
         STOP                
mot:     .BLOCK  2           ; #2d un mot
;
; incr: incr�mente un mot pass� par r�f�rence
; IN : PP+0=l'adresse du mot � incr�menter (#2h)
incrVar: .EQUATE 4           ; #2h le param�tre
incrA:   .EQUATE 0           ; #2d variable locale : sauvegarde de A
incr:    SUBSP   2,i         ; r�serve #incrA
         STA     incrA,s     ; sauve A
;                            ; // incr�mentation : (*incrVar)++
         LDA     incrVar,sf  ; A = *incrVar
         ADDA    1,i         ; A++
         STA     incrVar,sf  ; *incrVar = A
;                            ; // fin sous-programme
         LDA     incrA,s     ; restaure A
         RET2                ; lib�re #incrA
         .END                  