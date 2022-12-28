with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;

package Adresse_IP is

     type T_Adresse_IP is mod 2 ** 32;
     UN_OCTET: constant T_Adresse_IP := 2 ** 8;

     -- Affiche une Adresse IP sur le terminal au format "n1.n2.n3.n4"
     procedure Afficher_IP (Adresse_IP : in T_Adresse_IP);

     -- Convertir une Adresse IP (binaire) en ligne (string) au format "n1.n2.n3.n4"
     function Conv_IP_String (Adresse_IP : in T_Adresse_IP) return Unbounded_String;

     -- Converti une ligne au format "n1.n2.n3.n4" en une adresse IP
     function Conv_String_IP (ligne : in String) return T_Adresse_IP;
     
     -- Lit l'adresse IP dans le fichier et la renvoie
     function Lire_Adresse_IP (Entree : in File_Type) return T_Adresse_IP;

     -- Dis si un paquet correspond
     function Comp_Destination_Paquet(Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Paquet: in T_Adresse_IP) return Boolean;
     
end Adresse_IP;
