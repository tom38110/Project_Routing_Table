package body Adresse_IP is

     -- Fonction qui a pour but de convertir une adresse IP (binaire) en une chaine de caractère composée de quatre 
     -- entiers de la forme "n1.n2.n3.n4".
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


     -- Fonction qui permet de lire une adresse IP dans un fichier Entree et la convertir en un type T_Adresse_IP
    
     function Lire_Adresse_IP (Entree : in File_Type) return T_Adresse_IP is 
         
          c: character;                     -- permet de traiter le "."
          val:Integer;                      -- la valeur (ni) qui va etre convertie en binaire
          ad_ip:T_Adresse_IP;               -- l'adresse IP convertie en binaire
     
     begin
          
          for i in 1..4 loop                -- pour chaque ni de l'adresse IP
               Get(Entree,val);             -- on récupère la valeur de ni
               Get(Entree,c);               -- on lit le "." pour éviter de stopper l'algorithme
               ad_ip := ad_ip*UN_OCTET + Integer'Image (val);       -- on construit l'adresse_IP à l'aide du schéma de Horner
          end loop;
          return ad_ip;                     -- on renvoie l'adresse IP convertie en binaire
     
     end Lire_Adresse_IP;    

     -- Fonction qui renvoie un booléen qui confirme ou non la compatibilité entre une Destination et un Paquet.

     function Comp_Destination_Paquet(Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Paquet: in T_Adresse_IP) return Boolean is 
          
          val2:T_Adresse_IP;
          T:Boolean;
          M:T_Adresse_IP;
          i:Integer;
          
     begin
     
          T:=True;                          -- on initialise notre T à True 
          val2 := Paquet;                   -- on créé une copie du paquet
          M := Masque;                      -- on créé une copie du masque 
          i:=0;
          while T and then i < 4 loop                      -- tant qu'on a bien égalité entre les valeurs de destination et de paquet et que l'on n'est pas arrivé à la fin
               if (val2 mod UN_OCTET) = (Destination mod UN_OCTET) then -- si on a egalité entre les 2 ni on ne fait rien
                    null;
               else                                                 
                    if (masque mod UN_OCTET) = 0 then               -- sinon on observe la valeur du masque associée, si elle est égale à 0 on ne fait rien
                         val2:= val2 / UN_OCTET;                    -- on modifie les valeurs des copies afin de passer aux ni suivants
                         Destination := Destination / UN_OCTET;
                         M:= M / UN_OCTET;
                    else
                         T:=False;                                  -- on change T en False car on ne respecte pas la cohérence du cache.
                    end if;
               end if ;
               i:=i+1;                      -- permet d'assurer la bonne terminaison de la boucle while à la fin de la comparaison
          end loop;
          return T;
          
     end Comp_Destination_Paquet;
          
end Adresse_IP;
