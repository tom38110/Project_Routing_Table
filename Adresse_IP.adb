with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Integer_Text_IO;    use Ada.Integer_Text_IO;

package body Adresse_IP is

     function Conv_Ligne_IP (ligne: in string) return T_Adresse_IP is

          Taille_Ligne: Integer;      -- la taille de la ligne
          T1: Integer;
          T2: Integer;
          Valeur: constant Integer;   -- espace alloué à la conversion en entier

     begin
          T1:=1;

          Taille_Ligne := lenght(ligne);  -- on compte le nombre de caractère dans le chaîne

          for elm in (1..Taille_Ligne) loop   -- on parcours la chaîne
               if ligne(elm) = '.' then       -- si on tombe sur un . on le remplace par un espace

                    T2:=elm-1;
                    Valeur:= Integer'Valeur(ligne(T1..T2));
                    T1:=T2;

               end if;
          end loop;

          Valeur:= Integer'Valeur(ligne);   -- conversion en entier





     end Conv_Ligne_IP;
