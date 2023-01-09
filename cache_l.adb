with Ada.Unchecked_Deallocation;
with Ada.Text_IO;                  use Ada.Text_IO;

package body Cache_L is

    procedure Free is
    new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table_Routage);


    procedure Initialiser_L(Cache : out T_Cache_L) is
    begin
        Cache.Debut := null;
    end Initialiser_L;

    procedure Ajouter_C(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) is
    begin
    end Ajouter_C;


    procedure Afficher_L(Cache : in T_Cache_L) is
    begin
        if Cache.Debut = Null then
            Null;
        else
            Afficher_IP(Cache.Debut.All.Destination);
            Put(" ");
            Afficher_IP(Cache.Debut.All.Masque);
            Put(" ");
            Put_Line(To_String(Cache.Debut.All.Interface_eth));
            Afficher(Cache.Debut.All.Suivante);
        end if;
    end Afficher_L;


    function Supprimer_ligne_L(Cache : in T_Cache_L; Politique : in T_Politique) return T_Cache_L is
        Detruire : T_Ptr_Cellule;
    begin
        if Politique = FIFO then                 --La donnee la plus ancienne est au debut du cache
            Detruire := Cache.Debut;
            Cache.Debut := Cache.Debut.All.Suivante;
            Free(Detruire);

        elsif Politique = LRU then 


        else
            Null;

        end if;
    end Supprimer_ligne_L;


    procedure Chercher_Element_L(Table : in T_Table_Routage; Cache : in out T_Cache_L ; Paquet: in T_Adresse_IP ; Interface_eth : out Unbounded_String ; Politique : T_Politique);
        Table_parcours : T_Table_Routage := Table;
        ad_courant : String;
        --On initialise le masque pour pouvoir être comparé dans la suite
        masque_courant : T_Adresse_IP := 0;
        --Cette interface correspondra à celle de la ligne de la Table qui vérifie la cohérence du cache.
        --On peut enlever l'Interface_eth des arguments ducoup?
        eth_courant : Unbounded_String;
    begin
        while (Table_parcours.all.Suivante /= null) loop
            if (Comp_Destination_Paquet(Table_parcours.all.Destination, Table_parcours.all.Masque, Paquet)) and then masque_courant<Table_parcours.all.Masque then
                masque_courant := Table_parcours.all.Masque;
                ad_courant := Table_parcours.all.Destination;
                eth_courant := Table_parcours.all.Interface_eth;
            else
                null;
            end if;
        end loop;
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
    end Chercher_Element_L;


    function Ligne_Presente_L(Cache : in T_Cache_L; Ligne : in String) return Boolean is
     
          return (Paquet and Masque) = Destination;
          
     end Ligne_Presente_L;
 
