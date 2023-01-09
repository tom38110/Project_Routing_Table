with Ada.Unchecked_Deallocation;
with Ada.Text_IO;                  use Ada.Text_IO;

package body Cache_L is

    procedure Free is
    new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table_Routage);


    procedure Initialiser_L(Cache : out T_Cache_L) is
    begin
        Cache.Debut := null;
        Cache.Fin := null;
    end Initialiser_L;

    procedure Ajouter_C(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) is
    begin
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


    function Supprimer_ligne_L(Cache : in T_Cache_L; Politique : in T_Politique) return T_Cache_L is
        Detruire : T_Ptr_Cellule;
    begin
        -- La donnee la plus ancienne ou la moins récemment utilisée est au debut du cache
        if Politique = FIFO or Politique = LRU then                 
            Detruire := Cache.Debut;
            Cache.Debut := Cache.Debut.All.Suivante;
            Free(Detruire); 
        -- Le cas LFU
        else
            Null;

        end if;
    end Supprimer_ligne_L;


    function Chercher_Interface_L(Cache : in out T_Cache_L ; Paquet: in T_Adresse_IP) return Unbounded_String is
        Cache_parcours : T_Ptr_Cellule := Cache.Debut;
        Masque_Max : T_Adresse_IP := 0;
        Interface_eth : Unbounded_String := " ";
    begin
        -- Recherche d'une interface correspondante
        while Cache_parcours /= Null loop
            if Comp_Destination_Paquet(Cache_parcours.all.Destination, Cache_parcours.all.Masque, Paquet) and then Cache_parcours.all.Masque > Masque_Max then
                Interface_eth := Cache_parcours.all.Interface_eth;
                Masque_Max := Cache_parcours.all.Masque;
            else 
                Null;
            end if;
            Cache_parcours := Cache_parcours.all.Suivante;
        end loop;
        -- Exception si aucune interface trouvée
        if Interface_eth = " " then
            raise Interface_Absente_Cache;
        else 
            Null;
        end if;
        return Interface_eth;
    end Chercher_Interface_L;


    function Ligne_Presente_L(Cache : in T_Cache_L; Ligne : in String) return Boolean is
     
          return (Paquet and Masque) = Destination;
          
     end Ligne_Presente_L;
 
 --si la ligne valide de la table est déjà dans le cache ET ALORS le cache est plein.
        --car si le cache n'est pas plein on a pas besoin de supprimer
        if not(Ligne_Presente_L(Cache, Ligne)) and Cache_Plein_L(Cache, Taille_Max) then
            Supprimer_ligne_L(Cache, Politique);
            Ajouter_C(Cache, ad_courant, masque_courant, eth_courant); 
        elsif not(Ligne_Presente_L(Cache, Ligne)) and not(Cache_Plein_L(Cache, Taille_Max)) then
            Ajouter_C(Cache, ad_courant, masque_courant, eth_courant);
        else
            null;
        end if;