with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Ada.Command_Line;     use Ada.Command_Line;
with SDA_Exceptions;       use SDA_Exceptions;
with Alea;

-- mise en place d'un routeur avec cache.
procedure Routeur is

     -- Initialise les options du programme par défaut
     procedure Traiter_option(Fich_Table : out String; Fich_Paquets : out String; Fich_Resultats : out String; Politique : out T_Politique; Stat : out Boolean) is
     begin
          Politique := FIFO;
          Stat := true;
          Fich_Table := "table.txt";
          Fich_Paquets := "paquets.txt";
          Fich_Resultats := "resultats.txt";
     end Initialiser_option;
     
     Fich_Table, Fich_Paquets, Fich_Resultats : String;
     Stat : Boolean;

begin 
     -- Traiter les options du programmes
     Traiter_Option(Fich_Table, Fich_Paquets, Fich_Resultats, Politique, Stat);

end Routeur;
