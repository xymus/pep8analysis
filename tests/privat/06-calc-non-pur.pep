; Semaine 6
; Programme non pur qui fait des op�rations multiples
; Jean Privat (C) 2010
         DECI    num,d       
         LDX     num,d       ; X = nombre op�ration = getNombre();
         CHARI   op,d        
         LDA     0,i         
         LDBYTEA op,d        ; A = op = getChar()
         CPA     '+',i       ; if (A == '+') ;
         BREQ    loop        
         CPA     '-',i       
         BRNE    error       ; else if (A == '-') {
         LDBYTEA subad,d     
         STBYTEA instr,d     ;   remplace l'instruction � instr par SUBA
         BR      loop        ; } else {
error:   STRO    errMsg,d    ;   print error;
         STOP                ;   exit; }
loop:    SUBX    1,i         ; while(--X >= 0) {
         BRLT    fin         
         DECI    num,d       
         LDA     num,d       
         DECI    num,d       
instr:   ADDA    num,d       ;   num = getInt() + getInt() // ou - si remplassage
         STA     num,d       
         DECO    num,d       
         CHARO   '\n',i      ;   print(num, "\n")
         BR      loop        ; } // fin while
fin:     STOP                
op:      .BLOCK  1           ; #1c symbole de l'op�ration
num:     .BLOCK  2           ; nombre entr�e, calcul� et affich�
errMsg:  .ASCII  "Attendu '+' ou '-'\x00"
subad:   SUBA    0,d         ; code op�ration instruction
         .END                  