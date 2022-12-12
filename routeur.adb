with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;               use Ada.Exceptions;
with Table_Routage;                use Table_Routage;
with Adresse_IP;                   use Adresse_IP;

-- mise en place d'un routeur avec cache.
procedure Routeur is
     -- Type énuméré de la politique du cache
     Type T_Politque is (FIFO, LRU, LFU);

     -- Affiche l'usage du programme
     procedure Afficher_Usage is
     begin
          New_Line;
          Put_Line("Usage : " & Command_Name & " option");
          New_Line;
          Put_Line("     Les options sont : ");
          Put_Line("          Pour définir la taille du cache (10 par défaut) : -c <taille>");
          Put_Line("          Pour définir la politique du cache : -P FIFO|LRU|LFU");
          Put_Line("          Pour afficher les stats du cache : -s ou ne pas les affichées : -S");
          Put_Line("          Pour définir le nom du fichier contenant la table de routage (table.txt par défaut) : -t <fichier>");
          Put_Line("          Pour définir le nom du fichier contenant les paquets (paquets.txt par défaut) : -p <fichier>");
          Put_Line("          Pour définir le nom du fichier contenant les résultats (resultats.txt par défaut) : -r <fichier>");
          New_Line;
     end Afficher_Usage;

     -- Traite les options du programme
     procedure Traiter_option(Taille_Cache : out Integer; Fich_Table : out String; Fich_Paquets : out String; Fich_Resultats : out String; Politique : out T_Politique; Stat : out Boolean) is
          i : Integer;
     begin
          -- Initialiser les options par défaut
          Taille_Cache := 10;
          Politique := FIFO;
          Stat := true;
          Fich_Table := To_Unbounded_String("table.txt");
          Fich_Paquets := To_Unbounded_String("paquets.txt");
          Fich_Resultats := To_Unbounded_String("resultats.txt");

          -- Modifier les options si nécessaire
          i := 1;
          while i <= Argument_Count loop
               
               if Argument(i) = "-c" then
                    i := i + 1;
                    Taille_Cache := Integer'Value(Argument(i));
               elsif Argument(i) = "-P" then
                    i := i + 1;
                    if Argument(i) = "FIFO" then
                         Politique := FIFO;
                    elsif Argument(i) = "LRU" then
                         Politique := LRU;
                    elsif Argument(i) = "LFU" then
                         Politique := LFU;
                    else
                         Afficher_Usage;
                    end if;
               elsif Argument(i) = "-p" then
                    Fich_Paquets := To_Unbounded_String(Argument(i));
               elsif Argument(i) = "-S" then
                    Stat := false;
               elsif Argument(i) = "-s" then
                    Stat := true;
               elsif Argument(i) = "-t" then
                    i := i + 1;
                    Fich_Table := To_Unbounded_String(Argument(i));
               elsif Argument(i) = "-r" then
                    i := i + 1;
                    Fich_Resultats := To_Unbounded_String(Argument(i));
               else
                    Afficher_Usage;
               end if;
               i := i + 1;
          end loop;
     end Traiter_Option;

     Fich_Table, Fich_Paquets, Fich_Resultats : Unbounded_String; -- Noms des fichiers à gérer
     Stat : Boolean; -- Afficher les stats du cache ou non
     Table_Routage : T_Table_Routage; -- Table de routage
     Politique : T_Politque; -- Politique du cache
     ligne : Unbounded_String; -- Ligne lu dans le fichier d'entrée
     AdresseIP, Masque : T_Adresse_IP;
     Interface : Unbounded_String;
     Entree : File_Type; -- Le descripteur du fichier d'entrée
     Sortie : File_Type; -- Le descripteur du fichier de sortie
begin 
     -- Traiter les options du programmes
     Traiter_Option(Fich_Table, Fich_Paquets, Fich_Resultats, Politique, Stat);

     -- Lire la table de routage dans le fichier
     Open(Entree, In_File, To_String(Fich_Table));
     Initialiser(Table_Routage);
     begin
          loop
               AdresseIP := Lire_Adresse_IP(Entree);
               Masque := Lire_Adresse_IP(Entree);
               Interface := Get_Line(Entree);
               Trim(Interface, Both);
               Ajouter(Table_Routage, AdresseIP, Masque, Interface);
               exit when End_Of_File (Entree);
          end loop;
     exception
          when End_Error =>
               Put("Blancs en surplus à la fin du fichier.");
               Null;
     end;
     Close(Entree);

end Routeur;
