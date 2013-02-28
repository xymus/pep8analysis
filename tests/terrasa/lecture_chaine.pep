; Programme qui lit une chaine caract�re par caract�re
; et s'arr�te au premier caract�re nul trouv�
;
; Alexandre Terrasa (c) 2012

         ldx     0,i          ; X = 0

rep:     ldbytea chaine, x    ; do { A = chaine[X] // if chaine[X] == null then Z = 1
         breq    fin          ;   if( A != null ) {
         charo   chaine,x     ;       print(chaine[X])
         charo   "\n",i       ;       print("\n")
         addx    1,i          ;       X++
                              ;   } else { break }
         br      rep          ; }

fin:     stop

chaine:  .ASCII  "Bonjour\x00" ; La chaine � lire en ASCII (1 caract�re = 1 octet)

         .END