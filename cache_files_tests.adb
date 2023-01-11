with Cache_L;           use Cache_L;


    procedure Cache_files_tests is

        package Cache_L is 
            new Cache(T_Cache => T_Cache_L);
        use Cache_L;

        Capacite_Max : constant Integer := 10;
        Politique : T_Politique := FIFO;
        Cache : T_Cache_L := cache.txt;
        Cache_parcours : T_Ptr_Cellule;
        Paquet : Adresse_IP := Conv_String_IP("147.127.25.12");
        Destination : Adresse_IP := Conv_String_IP("147.127.25.0");
        Masque : Adresse_IP := Conv_String_IP("255.255.255.0");
        Interface_eth : Unbounded_String := "eth1";



        function Ligne_Presente_L(Cache : in T_Cache_L;  Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) return Boolean is
                Cache_parcours : T_Ptr_Cellule := Cache.Debut;
        begin
            while Cache_parcours /= Null loop
                if (Cache_parcours.All.Suivante.Destination = Destination) and then (Cache_parcours.All.Suivante.Masque = Masque) and then (Cache_parcours.All.Suivante.Interface_eth = Interface_eth) then
                    return True;
                else
                    Cache_parcours := Cache_parcours.All.Suivante;
                end if;
            end loop;
            return False;
        end Ligne_Presente_L;



        function Taille_L(Cache : in T_Cache_L) return Integer is
            Cache_parcours : T_Ptr_Cellule := Cache.Debut;
            compteur : Integer := 0;
        begin
            while Cache_parcours /= Null loop
                compteur := compteur +1;
                Cache_parcours := Cache_parcours.All.Suivante;
            end loop;
            return compteur;
        end Taille_L;


        function Chercher_Compteur_Min(Cache : in T_Cache_L) return Integer is
            Cache_parcours : T_Ptr_Cellule := Cache.Debut;
            compteur_min : Integer := cache.Debut.All.Nb_utilisation;
        begin
            while Cache_parcours /= Null loop
                if compteur_min > cache.Debut.All.Nb_utilisation then
                    compteur_min := cache.Debut.All.Nb_utilisation;
                else
                    Null;
                end if;
                Cache_parcours := Cache_parcours.All.Suivante;
            end loop;
            return compteur_min;
        end Chercher_Compteur_Min;






    begin
        Put_Line("On initialise un Cache: ");
        Initialiser_L(Cache);
        Afficher_L(Cache);
        New_Line;

        Put_Line("On affiche un Cache préalablement vidé: ");
        Vider_L(Cache);
        Afficher_L(Cache);
        New_Line;

        Put_Line("Le Cache est affiché ci-dessous: ");
        Afficher_L(Cache);
        New_Line;

        Put_Line("On ajoute la ligne 147.127.25.0 255.255.255.0 eth1 dans le Cache et on l'affiche: ");
        Ajouter_C(Cache, Destination, Masque, Interface_eth);
        Afficher_L(Cache);
        New_Line;

        Put_Line("On affiche le Cache et on vérifie que la ligne 147.127.25.0 255.255.255.0 eth1 est dans le Cache: ");
        Afficher_L(Cache);
        Put(Ligne_Presente_L(Cache, Destination, Masque, Interface_eth));
        New_Line;

        Put_Line("On affiche le Cache et on vérifie qu'il est plein: ");
        Afficher_L(Cache);
        Put(Cache_Plein_L(Cache, Capacite_Max));
        New_Line;

        Put_Line("On affiche le Cache et sa taille effective: ");
        Afficher_L(Cache);
        Put(Taille_L(Cache));
        New_Line;

        Put_Line("On affiche le Cache, on supprime une ligne suivant la Politique choisi puis on reaffiche le Cache: ");
        Afficher_L(Cache);
        Supprimer_ligne_L(Cache, Politique);
        Afficher_L(Cache);
        New_Line;

        Put_Line("On affiche le Cache, on effectue sa mise à jour avec l'ajout de 147.127.25.0 255.255.255.0 eth1 puis on reaffiche le Cache: ");
        Afficher_L(Cache);
        Afficher_L(Maj_Cache(Cache, Masque, Interface_eth, Destination, Capacite_Max, Politique));
        New_Line;

        Put_Line("On affiche le Cache, on cherche puis on affiche l'interface du Cache correspondant au Paquet si elle existe: ");
        Afficher_L(Cache);
        Put(Chercher_Interface_L(Cache, Paquet));
        New_Line;

        Put_Line("On affiche le Cache, le nombre d'utilisation de chaque donnée du Cache et le nombre minimal d'utilisation");
        Afficher_L(Cache);
        Cache_parcours := Cache.Debut;
        while Cache_parcours /= Null loop
            Put(Cache_parcours.All.Nb_utilisation);
            Cache_parcours := Cache_parcours.All.Suivante;
        end loop;
        Put(Chercher_Compteur_Min(Cache));
        New_Line;




    end Cache_files_tests;