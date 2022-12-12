with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Ada.Command_Line;     use Ada.Command_Line;
with SDA_Exceptions;       use SDA_Exceptions;
with Alea;

-- mise en place d'un routeur avec cache.
procedure Routeur is

     -- Traiter les options du programme
     procedure Traiter_Option is
     begin
     end Traiter_Option;

     -- lire la table de routage dans le fichier table
     procedure Lecture_Table () is
     begin
     end Lecture_Table;

     -- on répète jusqu'à tomber sur la fin du fichier
     loop
          -- lire une ligne
          procedure Lecture_Ligne () is
          begin
          end Lecture_Ligne;

          -- traiter une ligne
          procedure Traiter_Ligne () is
          begin
          end Traiter_Ligne;

          exit when ligne = "fin";
     end loop;

     -- fermeture du fichier
     procedure Fermer_Fichier is
     begin
     end Fermer_Fichier;
end Routeur;
