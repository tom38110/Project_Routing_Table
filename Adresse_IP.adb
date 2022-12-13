with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Integer_Text_IO;    use Ada.Integer_Text_IO;


package body Adresse_IP is

     

     function Conv_Ligne_IP (ligne: in string) return T_Adresse_IP is

          Taille_Ligne: Integer;      -- la taille de la ligne
          T1: Integer;
          T2: Integer;
          Valeur: constant Integer;   -- espace allou� � la conversion en entier

     begin
          T1:=1;

          Taille_Ligne := lenght(ligne);  -- on compte le nombre de caract�re dans le cha�ne

          for elm in (1..Taille_Ligne) loop   -- on parcours la cha�ne
               if ligne(elm) = '.' then       -- si on tombe sur un . on le remplace par un espace

                    T2:=elm-1;
                    Valeur:= Integer'Valeur(ligne(T1..T2));
                    T1:=T2;

               end if;
          end loop;

          Valeur:= Integer'Valeur(ligne);   -- conversion en entier





     end Conv_Ligne_IP;


     function Lire_Adresse_IP (Entree : File_Type) return T_Adresse_IP is 
          c: character;
          val:Integer;
          ad_ip:T_Adresse_IP;
     begin
          
          for i in 1..4 loop
               Get(Entree,val);
               Get(Entree,c);
               ad_ip := ad_ip*UN_OCTET + val;
          end loop;

     end Lire_Adresse_IP;


     function Comp_Destination_Paquet(Destination:T_Adresse_IP; Masque: T_Adresse_IP; Paquet:T_Adresse_IP) return Boolean is 
          val2:T_Adresse_IP;
          T:Boolean;
          M:T_Adresse_IP;
          i:Integer;
     begin
          T:=True;
          val2 := Paquet;
          M := Masque;
          i:=0;
          while T=True and then i < 4 loop
               if (val2 mod UN_OCTET) = (Destination mod UN_OCTET) then
                    null;
               else
                    if (masque mod UN_OCTET) = 0 then
                         val2:= val2 / UN_OCTET;
                         Destination := Destination / UN_OCTET;
                         M:= M / UN_OCTET;
                    else
                         T:=False;
                    end if;
               end if ;
               i:=i+1;
          end loop;
     end Comp_Destination_Paquet;