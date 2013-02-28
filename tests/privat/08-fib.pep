; Programme qui affiche un nombre dans la s�quence de Fibonacci
         DECI    num,d       
         LDA     num,d       
         CALL    fib         
         STA     num,d       
         DECO    num,d       
         STOP                
num:     .BLOCK  2           
;
;fib: calcule le ni�me nombre de la s�quence de Fibonacci de fa�on r�cursive
;     Hint: fib(0) = 0; fib(1) = 1; fib(n) = fib(n-1) + fib(n-2)
;IN:  A=rang dans la s�quence
;OUT: A=nombre de fibonacci
fib:     SUBSP   4,i         ; reserve #fibN #fibTmp
         CPA     1,i         
         BRLE    fib_fin     ; if (A<=1) return A;
         STA     fibN,s      ; fibN = A;
         SUBA    1,i         
         CALL    fib         
         STA     fibTmp,s    ; fibTmp = fib(fibN-1);
         LDA     fibN,s      
         SUBA    2,i         
         CALL    fib         
         ADDA    fibTmp,s    ; A = fib(fibN-2) + fibTmp;
fib_fin: RET4                ; lib�re #fibN #fibTmp
fibN:    .EQUATE 0           ; variable locale: le param�tre de la fonction #2d
fibTmp:  .EQUATE 2           ; variable locale: le r�sultat du premier appel r�cursif #2d
         .END                  