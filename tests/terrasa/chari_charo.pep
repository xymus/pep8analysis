; Introduction � PEP8
; Programme qui affiche le caract�re saisi par l'utilisateur
;
; Alexandre Terrasa (c) 2013     

         stro    msg1, d     ; print(msg1)
         chari   char, d     ; char = chari()
         stro    msg2, d     ; print(msg2)
         charo   char, d     ; print(char)
         stop

char:    .BYTE   0           ; on r�serve un octet (initialis� � 0) pour stocker le caract�re

msg1:    .ASCII  "Veuillez saisir un caract�re: \x00"
msg2:    .ASCII  "\nLe caract�re saisi est: \"\x00"

         .END