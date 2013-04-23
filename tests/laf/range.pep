     DECI  in,d
     LDA   in,d
     CPA   10,i 
     BRGT  eq
neq: LDA   4,i
     BR    end
eq:  LDA	  16,i
end: STA	  aff,d
     DECO  aff,d
     STOP
in: .WORD  0
aff:.BLOCK 0
    .END
