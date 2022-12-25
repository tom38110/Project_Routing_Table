with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;

package Adresse_IP is

     type T_Adresse_IP is mod 2 ** 32;
     UN_OCTET: constant T_Adresse_IP := 2 ** 8;

     -- Convertir une Adresse IP (binaire) en ligne (string)
     function Conv_IP_String (Adresse_IP : in T_Adresse_IP) return Unbounded_String;
     
     -- Lit l'adresse IP dans le fichier et la renvoie
     function Lire_Adresse_IP (Entree : in File_Type) return T_Adresse_IP;

     -- Dis si un paquet correspond
     function Comp_Destination_Paquet(Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Paquet: in T_Adresse_IP) return Boolean;
     
end Adresse_IP;
