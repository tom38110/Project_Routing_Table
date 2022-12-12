with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with Ada.Command_Line;     use Ada.Command_Line;
with SDA_Exceptions;       use SDA_Exceptions;
with Alea;

-- mise en place d'un routeur avec cache.
procedure Routeur is

     -- Initialise les options du programme par défaut
     procedure Traiter_option(Fich_Table : out String; Fich_Paquets : out String; Fich_Resultats : out String; Politique : out T_Politique; Stat : out Boolean) is
     i:Integer;
     
     begin
          Politique := FIFO;
          Stat := true;
          Fich_Table := "table.txt";
          Fich_Paquets := "paquets.txt";
          Fich_Resultats := "resultats.txt";
          
          i:=1;
          while i <= Argument_Count loop
               
               if Argument(i) = "-c" then
                    i:=i+1;
                    Taille_Cache:= Argument(i);
               elsif Argument(i)= "-P" then
                    i:= i+1;
                    
                    if Argument(i) = "FIFO" then
                         Politique := FIFO;
                    elsif Argument(i) = "LRU" then
                         Politique := LRU;
                    elsif Argument(i) = "LFU" then
                         Politique := LFU;
                    else
                         Put("hh");
                    end if;
               elsif Argument(i)= "-p" then
                    Fich_Paquets:= Argument(i);
               elsif Argument(i)= "-S" then
                    Stat:= True;
               elsif Argument(i)= "-s" then
                    Stat:= False;
               elsif Argument(i)= "-t" then
                    i:=i+1;
                    Fich_Tabl:=Argument(i);
               elsif Argument(i)= "-r" then
                    i:=i+1;
                    Fich_Resultats := Argument(i);
               else
                    Put("hh");
               end if;     
               
               
               i:= i+1;
          end loop;
               
               
     end Traiter_Option;
     
     Fich_Table, Fich_Paquets, Fich_Resultats : String;
     Stat : Boolean;
     i : Integer;
begin 
     -- Traiter les options du programmes
     Traiter_Option(Fich_Table, Fich_Paquets, Fich_Resultats, Politique, Stat);
     i := 1;
end Routeur;
