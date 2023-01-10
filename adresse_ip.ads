with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;

package Adresse_IP is

     type T_Adresse_IP is mod 2 ** 32;
     UN_OCTET: constant T_Adresse_IP := 2 ** 8;
     POIDS_FORT : constant T_Adresse_IP  := 2 ** 31;	 -- 10000000.00000000.00000000.00000000

     -- Affiche une Adresse IP sur le terminal au format "n1.n2.n3.n4"
     procedure Afficher_IP (Adresse_IP : in T_Adresse_IP);

     -- Converti une ligne au format "n1.n2.n3.n4" en une adresse IP
     function Conv_String_IP (ligne : in String) return T_Adresse_IP;
     
     -- Lit l'adresse IP dans le fichier et la renvoie
     function Lire_Adresse_IP (Entree : in File_Type) return T_Adresse_IP;

     -- Dis si un paquet correspond à une route
     function Comp_Destination_Paquet(Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Paquet: in T_Adresse_IP) return Boolean;

     -- Renvoie vrai si le ieme bit de Adresse_IP vaut 1
     function Ie_Bit_A_1(Adresse_IP : in T_Adresse_IP; i : in Integer) return Boolean;
     
     -- Trouve l'indice du premier bit différent entre les 2 adresses IP en partant de la gauche
     function Trouver_Ie_Bit_Diff(IP1 : in T_Adresse_IP; IP2 : in T_Adresse_IP) return Integer;

     -- Met les n bits en partant de la gauche à 1
     procedure Mise_A_1(Adresse_IP : in out T_Adresse_IP; n : in Integer);
end Adresse_IP;
