with Ada.Unchecked_Deallocation;
with Ada.Text_IO;                  use Ada.Text_IO;

package body Cache_L is

    procedure Free is
    new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Ptr_Cellule);


    procedure Initialiser_L(Cache : out T_Cache_L) is
    begin
        Cache.Debut := Null;
        Cache.Fin := Null;
        Cache.Nb_elem := 0;
    end Initialiser_L;


    procedure Vider_L(Cache : in out T_Cache_L) is
        Detruire : T_Ptr_Cellule;
    begin
        while Cache.Debut.All.Suivante /= Null loop
            Detruire := Cache.Debut;
            Cache.Debut := Cache.Debut.All.Suivante;
            Free(Detruire);
        end loop;
        Cache.Fin := Null;
        Cache.Nb_elem := 0;
    end Vider_L;

    
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



    procedure Afficher_Stat_L(Cache : in T_Cache_L; Capacite_Max : in Integer; Politique : in T_Politique) is
    begin
        Put("Le Cache est affiché ci-dessous: ");
        New_Line;
        Afficher_L(Cache);
        New_Line;
        Put("La capacité maximale du Cache est: ");
        Put(Capacite_Max, 1);
        New_Line;
        Put("La taille effective du Cache est: ");
        Put(Cache.Nb_elem, 1);
        New_Line;
        Put("La Politique de gestion de Cache est: ");
        Put(Politique);
        New_Line;
    end Afficher_Stat_L;



    function Cache_Plein_L(Cache : in T_Cache_L; Capacite_Max : in Integer) return Boolean is
        --On l'initialise à 1 comme la dernière cellule du Cache ne sera pas comptée dans la boucle
        compteur : Integer := 1;
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
    begin
        return Cache.Nb_elem = Capacite_Max; 
    end Cache_Plein_L;


    procedure Ajouter_C(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) is
    begin
        if Cache.Debut = Null then
            Cache.Debut := new T_Cellule'(Destination, Masque, Interface_eth, Null);
            Cache.Fin := Cache.Debut;
        else
            Cache.Fin.All.Suivante := new T_Cellule'(Destination, Masque, Interface_eth, Null);
            Cache.Fin := Cache.Fin.All.Suivante;
        end if;        
    end Ajouter_C;


    procedure Afficher_L(Cache : in T_Cache_L) is
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
    begin
        while Cache_parcours /= Null loop
            Afficher_IP(Cache_parcours.All.Destination);
            Put(" ");
            Afficher_IP(Cache_parcours.All.Masque);
            Put(" ");
            Put_Line(To_String(Cache_parcours.All.Interface_eth));
            Cache_parcours := Cache_parcours.all.Suivante;
        end loop;
    end Afficher_L;


    -- nom          : Chercher_Compteur_Min
    -- but          : retourne le nombre d'utilisation minimal de la donnée la moins utilisée du Cache
    -- paramètres   : Cache -> le cache à parcourir
    -- précondition : Aucune, la fonction sera appelée qu'avec la politique LFU
    -- postcondition: Aucune
    function Chercher_Compteur_Min(Cache : in T_Cache_L) return Integer is
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
        compteur_min : Integer;
    begin
        if Cache_parcours = Null then
            return 0;
        else
            compteur_min := Cache_parcours.All.Nb_utilisation;
            Cache_parcours := Cache_parcours.All.Suivante; 
            while Cache_parcours /= Null loop
                    if compteur_min > cache.Debut.All.Nb_utilisation then
                        compteur_min := cache.Debut.All.Nb_utilisation;
                    else
                        Null;
                    end if;
                    Cache_parcours := Cache_parcours.All.Suivante;
            end loop;
        end if;
        return compteur_min;
    end Chercher_Compteur_Min;


    --nom: Ligne_Presente_L
    --but: retourne True si la ligne (Destination  Masque  Interface_eth) est présente dans le cache
    --paramètres: - Cache         -> le Cache a parcourir
    --            - Destination   -> la destination de la donnée que l'on recherche
    --            - Masque        -> le Masque de la donnée que l'on recherche
    --            - Interface_eth -> l'Interface de la donnée que l'on recherche
    --Aucune condition
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

    
    procedure Maj_Cache(Cache : in out T_Cache_L; Masque_Coherent : in T_Adresse_IP; Interface_Coherente : in Unbounded_String; Paquet: in T_Adresse_IP; Capacite_Max : in Integer; Politique : in T_Politique) is
        Detruire : T_Ptr_Cellule;
    begin

        if Cache_Plein_L(Cache, Capacite_Max) then
            Supprimer_ligne_L(Cache, Politique);
        else
            null;
        end if;
            
        if Politique = FIFO and then not(Ligne_Presente_L(Cache, Paquet, Masque_Coherent, Interface_Coherente)) then
            Ajouter_C(Cache, Paquet, Masque_Coherent, Interface_Coherente);

        elsif Politique = LRU then
            if not(Ligne_Presente_L(Cache, Paquet, Masque_Coherent, Interface_Coherente)) then
                Ajouter_C(Cache, Paquet, Masque_Coherent, Interface_Coherente);
            else
                --Si la ligne est deja dans le cache, on la supprime pour la mettre a la fin de la file
                while (not(Cache.Debut.All.Suivante.Destination = Paquet) and then not(Cache.Debut.All.Suivante.Masque = Masque_Coherent) and then not(Cache.Debut.All.Suivante.Interface_eth = Interface_Coherente)) loop
                    Cache.Debut := Cache.Debut.All.Suivante;
                end loop;
                Detruire := Cache.Debut.All.Suivante;
                Cache.Debut.All.Suivante := Detruire.All.Suivante;
                Ajouter_C(Cache, Paquet, Masque_Coherent, Interface_Coherente);
                Free(Detruire);
            end if;

        -- Politique = LFU
        else
            if not(Ligne_Presente_L(Cache, Paquet, Masque_Coherent, Interface_Coherente)) then
                Ajouter_C(Cache, Paquet, Masque_Coherent, Interface_Coherente);
                --On initialise son nombre d'utilisation à 1
                Cache.Fin.All.Suivante.Nb_utilisation := 0;
            else
                --Si la ligne est deja dans le cache, on la cherche pour lui incrementer son nombre d'utilisations de 1
                while (not(Cache.Debut.All.Suivante.Destination = Paquet) and then not(Cache.Debut.All.Suivante.Masque = Masque_Coherent) and then not(Cache.Debut.All.Suivante.Interface_eth = Interface_Coherente)) loop
                    Cache.Debut := Cache.Debut.All.Suivante;
                end loop;
                Cache.Debut.All.Suivante.Nb_utilisation := Cache.Debut.All.Suivante.Nb_utilisation + 1;
            end if;
        end if;

    end Maj_Cache;


    function Supprimer_ligne_L(Cache : in out T_Cache_L; Politique : in T_Politique) return T_Cache_L is
        Detruire : T_Ptr_Cellule;
        compteur_min : Integer;
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
    begin
        -- La donnee la plus ancienne ou la moins récemment utilisée est au debut du cache
        if Politique = FIFO or Politique = LRU then                 
            Detruire := Cache.Debut;
            Cache.Debut := Cache.Debut.All.Suivante;
            Free(Detruire); 
        -- Le cas LFU
        else
            compteur_min := Chercher_Compteur_Min(Cache);
            --Si la donnée la moins utilisée est au Début du Cache
            if Cache.Debut.All.Nb_utilisation = compteur_min then
                Detruire := Cache.Debut;
                Cache.Debut := Cache.Debut.All.Suivante;
                Free(Detruire); 
            else
                --Si la donnée la moins utilisée est au milieu du Cache 
                Cache_parcours := Cache.Debut;
                while Cache_parcours.All.Suivante.Nb_utilisation/=compteur_min loop
                    Cache_parcours := Cache_parcours.All.Suivante;
                end loop;
                Detruire := Cache_parcours.All.Suivante;
                Cache_parcours.All.Suivante := Detruire.All.Suivante;
                --Si la donnée la moins utilisée est à la fin du Cache
                if Detruire.All.Suivante = Null then
                    Cache.Fin := Cache_parcours;
                else
                    Null;
                end if;
                Free(Detruire);
            end if;
        end if;
        return Cache;
    end Supprimer_ligne_L;


    procedure Modif_Cache(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String ; Politique : in T_Politique) is
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
        Detruire : T_Ptr_Cellule;
    begin
        if Cache_parcours = Null or else (Cache_parcours.all.Destination = Destination and then Cache_parcours.all.Masque = Masque and then Cache_parcours.all.Interface_eth = Interface_eth and then Cache_parcours.all.Suivante = Null) then
            raise Interface_Absente_Cache;
        elsif Cache_parcours.all.Destination = Destination and then Cache_parcours.all.Masque = Masque and then Cache_parcours.all.Interface_eth = Interface_eth then
            Null;
        else 
            while Cache_parcours.all.Suivante /= Null and then Cache_parcours.all.Suivante.all.Destination /= Destination and then Cache_parcours.all.Suivante.all.Masque and then Cache_parcours.all.Suivante.all.Interface_eth /= Interface_eth loop 
                Cache_parcours := Cache_parcours.all.Suivante;
            end loop;
        end if;
        if Cache_parcours = Null or else Cache_parcours.all.Suivante = Null then
            raise Interface_Absente_Cache;
        else 
            if Politique = LFU then
                if Cache_parcours = Cache.debut then
                    Cache.debut.all.Nb_utilisation := Cache.debut.all.Nb_utilisation + 1;
                else
                    Cache_parcours := Cache_parcours.all.Suivante;
                    Cache_parcours.all.Nb_utilisation := Cache_parcours.all.Nb_utilisation + 1;
                end if;
            elsif Politique = LRU then
                Ajouter_C(Cache, Destination, Masque, Interface_eth);
                if Cache_parcours = Cache.Debut then
                    Detruire := Cache.Debut;
                    Cache.Debut := Cache.Debut.all.Suivante;
                else
                    Detruire := Cache_parcours.all.Suivante;
                    Cache_parcours.all.Suivante := Detruire.all.Suivante;
                    
                end if;
                Free(Detruire);
            else 
                Null;
            end if;
        end if;      
    end Modif_Cache;

    procedure Chercher_Interface_L(Cache : in out T_Cache_L ; Paquet : in T_Adresse_IP ; Politique : in T_Politique ; Interface_eth : in out Unbounded_String) is
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
        Interface_Trouvee : Boolean := False;
        Masque_Max : T_Adresse_IP := 0;
        Destination_correspondante : T_Adresse_IP;
    begin
        -- Recherche des routes correspondantes
        while Cache_parcours /= Null loop
            if Comp_Destination_Paquet(Cache_parcours.all.Destination, Cache_parcours.all.Masque, Paquet) and then Cache_parcours.all.Masque > Masque_Max then
                Interface_eth := Cache_parcours.all.Interface_eth;
                Masque_Max := Cache_parcours.all.Masque;
                Destination_correspondante := Cache_parcours.all.Destination;
                if not Interface_Trouvee then
                    Interface_Trouvee := True;
                else
                    Null;
                end if;
            else 
                Null;
            end if;
            Cache_parcours := Cache_parcours.all.Suivante;
        end loop;
        -- Exception si aucune interface trouvée
        if not Interface_Trouvee then
            raise Interface_Absente_Cache;
        else 
            Modif_Cache(Cache, Destination_correspondante, Masque_Max, Interface_eth, Politique);
        end if;
    end Chercher_Interface_L;

    

end Cache_L;