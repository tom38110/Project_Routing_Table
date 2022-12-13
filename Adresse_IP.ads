with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;

package Adresse_IP is

     type T_Adresse_IP is mod 2 ** 32;

     UN_OCTET: constant T_Adresse_IP := 2 ** 8;

     -- Convertir une ligne (string) en Adresse IP (binaire)
     function Conv_Ligne_IP (ligne: in string) return T_Adresse_IP;

     -- Convertir une Adresse IP (binaire) en ligne (string)
     function Conv_IP_ligne (IP: in T_Adresse_IP) return String;

     -- Lit l'adresse IP dans le fichier et la renvoie
     function Lire_Adresse_IP (Entree : File_Type) return T_Adresse_IP;

     -- Dis si un paquet correspond
     function Comp_Destination_Paquet(Destination:T_Adresse_IP; Masque: T_Adresse_IP; Paquet:T_Adresse_IP) return Boolean;


     

end Adresse_IP;
