with Ada.Unchecked_Deallocation;
with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;

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
        while Cache.Debut /= Null loop
            Detruire := Cache.Debut;
            Cache.Debut := Cache.Debut.All.Suivante;
            Free(Detruire);
        end loop;
        Cache.Fin := Null;
        Cache.Nb_elem := 0;
    end Vider_L;

    
    function Taille_L(Cache : in T_Cache_L) return Integer is
    begin
        return Cache.Nb_elem;
    end Taille_L;



    procedure Afficher_Stat_L(Cache : in T_Cache_L; Capacite_Max : in Integer; Politique : in T_Politique) is
    begin
        Put("Le cache est affiché ci-dessous : ");
        New_Line;
        Afficher_L(Cache);
        Put("La capacité maximale du cache est : ");
        Put(Capacite_Max, 1);
        New_Line;
        Put("La taille effective du cache est : ");
        Put(Cache.Nb_elem, 1);
        New_Line;
        Put("La Politique de gestion de Cache est : ");
        Put(T_Politique'Image(Politique));
        New_Line;
    end Afficher_Stat_L;



    function Cache_Plein_L(Cache : in T_Cache_L; Capacite_Max : in Integer) return Boolean is
    begin
        return Cache.Nb_elem = Capacite_Max; 
    end Cache_Plein_L;


    procedure Ajouter_C(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) is
    begin
        if Cache.Debut = Null then
            Cache.Debut := new T_Cellule'(Destination, Masque, Interface_eth, Null, 0);
            Cache.Fin := Cache.Debut;
        else
            Cache.Fin.All.Suivante := new T_Cellule'(Destination, Masque, Interface_eth, Null, 0);
            Cache.Fin := Cache.Fin.All.Suivante;
        end if;
        Cache.Nb_elem := Cache.Nb_elem + 1;
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

    
    procedure Maj_Cache(Cache : in out T_Cache_L; Masque_Coherent : in T_Adresse_IP; Interface_Coherente : in Unbounded_String; Paquet: in T_Adresse_IP; Capacite_Max : in Integer; Politique : in T_Politique) is
    begin
        if Cache_Plein_L(Cache, Capacite_Max) then
            Supprimer_ligne_L(Cache, Politique);
        else
            null;
        end if;   
        Ajouter_C(Cache, Paquet, Masque_Coherent, Interface_Coherente);
    end Maj_Cache;


    procedure Supprimer_ligne_L(Cache : in out T_Cache_L; Politique : in T_Politique) is
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
        Cache.Nb_elem := Cache.Nb_elem - 1;
    end Supprimer_ligne_L;


    function Cellule_Trouvee(Cellule : in T_Ptr_Cellule ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) return Boolean is
    begin 
        return Cellule.all.Destination = Destination and then Cellule.all.Masque = Masque and then Cellule.all.Interface_eth = Interface_eth;
    end Cellule_Trouvee;


    procedure Modif_Cache(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String ; Politique : in T_Politique) is
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
    begin
        if Politique = LRU then
            declare
                Detruire : T_Ptr_Cellule;
            begin
                Ajouter_C(Cache, Destination, Masque, Interface_eth);
                if Cellule_Trouvee(Cache_parcours, Destination, Masque, Interface_eth) then
                    Detruire := Cache.Debut;
                    Cache.Debut := Cache.Debut.all.Suivante;
                else 
                    while not Cellule_Trouvee(Cache_parcours.all.Suivante, Destination, Masque, Interface_eth) loop 
                        Cache_parcours := Cache_parcours.all.Suivante;
                    end loop;
                    Detruire := Cache_parcours.all.Suivante;
                    Cache_parcours.all.Suivante := Detruire.all.Suivante; 
                end if;
                Free(Detruire);
            end;
        elsif Politique = LFU then
            while not Cellule_Trouvee(Cache_parcours, Destination, Masque, Interface_eth) loop
                Cache_parcours := Cache_parcours.all.Suivante;
            end loop;
            Cache_parcours.all.Nb_utilisation := Cache_parcours.all.Nb_utilisation + 1;
        else
            Null;
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
            if Comp_Destination_Paquet(Cache_parcours.all.Destination, Cache_parcours.all.Masque, Paquet) and then Cache_parcours.all.Masque >= Masque_Max then
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