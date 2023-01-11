with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Adresse_IP;                   use Adresse_IP;


package Cache_L is
    type T_Cache_L is limited private;

    type T_File is limited private;

    Interface_Absente_Cache : exception;
    Ligne_Presente_Cache : exception;

    -- Type énuméré de la politique du cache
    type T_Politique is (FIFO, LRU, LFU);

    --Ajouter à la fin du Cache l'adresseIP, le masque et l'interface dans le cache
    procedure Ajouter_C(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String);

    --Pointer le cache vers null
    procedure Initialiser_L(Cache : out T_Cache_L);

    -- Chercher une interface correspondant au paquet dans le cache, lève une exception Interface_Absente_Cache si pas trouvé
    function Chercher_Interface_L(Cache : in T_Cache_L ; Paquet: in T_Adresse_IP) return Unbounded_String;

    --Afficher chaque ligne de la Table de Routage
    procedure Afficher_L(Cache : in T_Cache_L);

    --Afficher la statistique du cache
    procedure Afficher_Stat_L(Cache : in T_Cache_L; Capacite_Max : in Integer; Politique : in T_Politique);

    --Voir si le cache est plein
    function Cache_Plein_L(Cache : in T_Cache_L; Capacite_Max : in Integer) return Boolean;

    --Renvoie la taille du cache
    function Taille_L(Cache : in T_Cache_L) return Integer;

    --Mettre à jour le Cache : ajoute les données correctes dans le Cache (Paquet  Masque_Coherent  Interface_Coherente) selon la Politique et supprime un element selon la Politique
    function Maj_Cache(Cache : in out T_Cache_L; Masque_Coherent : in T_Adresse_IP; Interface_Coherente : in Unbounded_String; Paquet: in T_Adresse_IP; Capacite_Max : in Integer; Politique : in T_Politique) return T_Cache_L
    with Pre => not(Ligne_Presente_L(Cache));


    -- Supprime une ligne du cache suivant la politique
    function Supprimer_ligne_L(Cache : in out T_Cache_L; Politique : in T_Politique) return T_Cache_L
    with Pre => Cache_Plein_L(Cache, Capacite_Max);

    -- Vide le cache
    procedure Vider_L(Cache : in out T_Cache_L);

private

    type T_Cellule;

    type T_Ptr_Cellule is access T_Cellule;

    type T_Cellule is
        record
            Destination: T_Adresse_IP;
            Masque: T_Adresse_IP;
            Interface_eth: Unbounded_String;
            Nb_utilisation: Integer;            
            Suivante: T_Ptr_Cellule;
        end record;

    type T_Cache_L is      
        record
            Debut: T_Ptr_Cellule;
            Fin: T_Ptr_Cellule;
        end record;

end Cache_L;