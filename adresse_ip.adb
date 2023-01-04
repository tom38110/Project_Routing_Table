with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
package body Adresse_IP is


     procedure Afficher_IP (Adresse_IP : in T_Adresse_IP) is
     
          package AIP_IO is new
               Ada.Text_IO.Modular_IO(T_Adresse_IP);
          use AIP_IO;

     begin

          Put ((Adresse_IP / UN_OCTET ** 3) mod UN_OCTET, 1); Put (".");
	     Put ((Adresse_IP / UN_OCTET ** 2) mod UN_OCTET, 1); Put (".");
	     Put ((Adresse_IP / UN_OCTET ** 1) mod UN_OCTET, 1); Put (".");
	     Put (Adresse_IP mod UN_OCTET, 1);

     end Afficher_IP;


     function Conv_IP_String (Adresse_IP: in T_Adresse_IP) return Unbounded_String is

          IP: T_Adresse_IP;                                -- Adresse IP copie qui permet d'afficher l'adresse IP sans modifier l'origiinale
          Str: unbounded_string;                           -- Adresse IP convertie sous forme de chaine de caractère

     begin
     
          IP := Adresse_IP + 2 ** 8;

          for i in 1..4 loop                                                          -- on boucle 4 fois pour afficher toutes les valeurs dans une adresse IP
               Str:= Str &  Integer'Image (Natural(((IP / UN_OCTET ** (4-i)) mod UN_OCTET)));
               while i/=4 loop                                                             -- permet d'afficher les "." juste après les 3 premières valeurs
                    Str:= Str & ".";
               end loop;
          end loop;
          return Str;                                                                  -- on renvoie l'adresse IP convertie sous forme de chaine de caractère
     end Conv_IP_String;


     function Conv_String_IP (ligne : in String) return T_Adresse_IP is

          ad_ip : T_Adresse_IP;    -- Adresse IP correspondant à la ligne
          ind_ligne_deb : Integer; -- Indice de la ligne qui correspond au début d'un entier
          ind_ligne_fin : Integer; -- Indice de la ligne qui correspond à la fin d'un entier
          val : Integer;           -- Entier lu dans la ligne

     begin
          
          ind_ligne_deb := 1;
          ind_ligne_fin := 1;
          for i in 1..4 loop
               -- on cherche la fin de l'entier dans la ligne
               while ind_ligne_fin < length(To_Unbounded_String(ligne)) + 1 and then ligne(ind_ligne_fin) /= '.' loop
                    ind_ligne_fin := ind_ligne_fin + 1;
               end loop;
               -- On récupère l'entier qu'on importe dans l'adresse IP
               val := Integer'Value(ligne(ind_ligne_deb..ind_ligne_fin-1));
               if i = 1 then
                    ad_ip := T_Adresse_IP(val);
               else
                    ad_ip := ad_ip * UN_OCTET + T_Adresse_IP(val);
               end if;
               -- On avance dans la ligne pour traiter l'entier suivant
               ind_ligne_fin := ind_ligne_fin + 1;
               ind_ligne_deb := ind_ligne_fin;
          end loop;
          return ad_ip;
     
     end Conv_String_IP;
                    

     function Lire_Adresse_IP (Entree : in File_Type) return T_Adresse_IP is 

          c : character;                     -- permet de traiter le "."
          val : Integer;                      -- la valeur (ni) qui va etre convertie en binaire
          ad_ip : T_Adresse_IP;               -- l'adresse IP convertie en binaire

     begin

          Get(Entree, val);
          ad_ip := T_Adresse_IP(val);
          for i in 1..3 loop
               Get(Entree, c);
               Get(Entree, val);
               ad_ip := ad_ip * UN_OCTET + T_Adresse_IP(val);
          end loop;
          return ad_ip;                     -- on renvoie l'adresse IP convertie en binaire

     end Lire_Adresse_IP;      


     function Comp_Destination_Paquet(Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Paquet: in T_Adresse_IP) return Boolean is 
     begin
     
          return (Paquet and Masque) = Destination;
          
     end Comp_Destination_Paquet;
          
end Adresse_IP;
