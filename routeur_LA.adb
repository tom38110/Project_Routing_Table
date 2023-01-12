with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Adresse_IP;                   use Adresse_IP;
with Cache_A;                      use Cache_A;
with Table_Routage;


-- mise en place d'un routeur avec cache.
procedure Routeur_LA is

    package Table_Routage_A is 
        new Table_Routage(T_Cache => T_Cache_A);
    use Table_Routage_A;

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
    procedure Traiter_option(Capacite_Cache : out Integer; Fich_Table : out Unbounded_String; Fich_Paquets : out Unbounded_String; Fich_Resultats : out Unbounded_String; Politique : out T_Politique; Stat : out Boolean) is
        i : Integer;
    begin
        -- Initialiser les options par défaut
        Capacite_Cache := 10;
        Politique := LRU;
        Stat := true;
        Fich_Table := To_Unbounded_String("table.txt");
        Fich_Paquets := To_Unbounded_String("paquets.txt");
        Fich_Resultats := To_Unbounded_String("resultats.txt");

        -- Modifier les options si nécessaire
        i := 1;
        while i <= Argument_Count loop
            if Argument(i) = "-c" then
                i := i + 1;
                Capacite_Cache := Integer'Value(Argument(i));
            elsif Argument(i) = "-P" then
                i := i + 2;
                Put_Line("La politique du cache version Arbre préfixe est LRU");
            elsif Argument(i) = "-p" then
                i := i + 1;
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

    procedure Afficher_Stats(Nb_defaut_cache : in Integer ; Nb_demande_route : in Integer) is
    begin
        Put("Nombre de défauts de cache : ");
        Put(Nb_defaut_cache, 1);
        New_Line;
        Put("Nombre de demandes de route : ");
        Put(Nb_demande_route, 1);
        New_Line;
        if Nb_demande_route > 0 then
            Put("Taux de défaut de cache : ");
            Put(Float(Nb_defaut_cache)/Float(Nb_demande_route));
            New_Line;
        else
            Put_Line("Impossible de calculer le taux car il n'y a pas eu de demande de route");
        end if;
    end Afficher_Stats;

    Capacite_Cache : Integer; -- Capacité maximale du cache
    Fich_Table, Fich_Paquets, Fich_Resultats : Unbounded_String; -- Noms des fichiers à gérer
    Stat : Boolean; -- Afficher les stats du cache ou non
    Table_Routage : T_Table_Routage; -- Table de routage
    Cache : T_Cache_A; -- Cache sous forme d'une liste chaînée
    Politique : T_Politique; -- Politique du cache
    i : Integer; -- Compteur de ligne dans le fichier des paquets
    Nb_defaut_cache : Integer; -- Nombre de défauts de cache
    Nb_demande_route : Integer; -- Nombre de demandes de routes
    ligne : Unbounded_String; -- Ligne lu dans le fichier des paquets
    AdresseIP, Masque : T_Adresse_IP; -- Adresse IP et Masque à gérer
    Interface_eth : Unbounded_String; -- Interface correspondante à l'adresse IP
    Entree : File_Type; -- Le descripteur du fichier d'entrée
    Sortie : File_Type; -- Le descripteur du fichier de sortie

begin 
    -- Traiter les options du programmes
    Traiter_Option(Capacite_Cache, Fich_Table, Fich_Paquets, Fich_Resultats, Politique, Stat);

    -- Lire la table de routage dans le fichier
    Open(Entree, In_File, To_String(Fich_Table));
    Initialiser(Table_Routage);
    begin
    loop
        AdresseIP := Lire_Adresse_IP(Entree);
        Masque := Lire_Adresse_IP(Entree);
        Interface_eth := Get_Line(Entree);
        Trim(Interface_eth, Both);
        Ajouter(Table_Routage, AdresseIP, Masque, Interface_eth);
    exit when End_Of_File (Entree);
    end loop;
    exception
    when End_Error =>
        Put("Blancs en surplus à la fin du fichier.");
        Null;
    end;
    Close(Entree);

    -- Traiter les lignes du fichier paquets
    Initialiser_A(Cache);
    Open(Entree, In_File, To_String(Fich_Paquets));
    Create(Sortie, Out_File, To_String(Fich_Resultats));
    Nb_defaut_cache := 0;
    Nb_demande_route := 0;
    i := 1;
    loop
    ligne := Get_Line(Entree);
    Trim(ligne, Both);
    if '0' <= To_String(ligne)(1) and then To_String(ligne)(1) <= '9' then
        AdresseIP := Conv_String_IP(To_String(ligne));
        begin
            Interface_eth := Chercher_Interface_A(Cache, AdresseIP);
        exception
            when Interface_Absente_Cache =>
                Nb_defaut_cache := Nb_defaut_cache + 1;
                Chercher_Interface(Table_Routage, AdresseIP, Interface_eth, Cache, Capacite_Cache, Politique);
        end;
        Put_Line(Sortie, ligne & " " & Interface_eth);
        Nb_demande_route := Nb_demande_route + 1;
    elsif To_String(ligne) = "table" then
        Put(To_String(ligne) & " (ligne");
        Put(i, 2);
        Put(")");
        New_Line;
        Afficher(Table_Routage);
    elsif To_String(ligne) = "cache" then
        Put(To_String(ligne) & " (ligne");
        Put(i, 2);
        Put(")");
        New_Line;
        Afficher_A(Cache);
    elsif To_String(ligne) = "stat" then
        if Stat then
            Put(To_String(ligne) & " (ligne");
            Put(i, 2);
            Put(")");
            New_Line;
            Afficher_Stats(Nb_defaut_cache, Nb_demande_route);
            Afficher_Stat_A(Cache);
        else
            Null;
        end if;
    elsif To_String(ligne) = "fin" then
        Put(To_String(ligne) & " (ligne");
        Put(i, 2);
        Put(")");
        New_Line;
    else
        Put_Line("Erreur de lecture dans le fichier paquets");
    end if; 
    i := i + 1;
    exit when End_Of_File (Entree) or To_String(ligne) = "fin";
    end loop;

    --Fermeture des fichiers et vider la table de routage
    Close(Entree);
    Close(Sortie);
    Vider(Table_Routage);
    Vider_A(Cache);
exception
    when others =>
        Put_Line("Erreur dans le routage (vérifier fichier table et paquet)");
        Null;
end Routeur_LA;