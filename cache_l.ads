with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Boolean_Text_IO;          use Ada.Boolean_Text_IO;
with Adresse_IP;                   use Adresse_IP;


package Cache_L is
    type T_Cache_L is limited private;

    type T_File is limited private;

    -- Type énuméré de la politique du cache
    type T_Politique is (FIFO, LRU, LFU);

    --Ajouter l'adresseIP, le masque et l'interface dans le cache
    procedure Ajouter_C(Cache : in out T_Cache_L ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String);

    --Pointer le cache vers null
    procedure Initialiser_L(Cache : out T_Cache_L);

    --Parcourir la file jusqu'a trouver l'element ayant cette adresseIP avec un masque valide
    --Ajouter l'element au Cache en appelant la procedure Ajouter_L
    --Creer l'interface de cet element dans le Cache
    procedure Chercher_Interface_L(Cache : in out T_Cache_L ; Paquet: in T_Adresse_IP ; Interface_eth : out Unbounded_String);

    --Afficher chaque ligne de la Table de Routage
    procedure Afficher_L(Cache : in T_Cache_L);

    --Afficher la statistique du cache
    procedure Afficher_Stat_L(Cache : in T_Cache_L);

    --Voir si le cache est plein
    function Cache_Plein_L(Cache : in T_Cache_L; Taille_Max : in Integer) return Boolean;

    --Renvoie la taille du cache
    function Taille_L(Cache : in T_Cache_L) return Integer;

    --Savoir si la ligne est présente dans le cache
    function Ligne_Presente_L(Cache : in T_Cache_L; Ligne : in String) return Boolean;

    --Vide le cache suivant la politique
    function Supprimer_ligne_L(Cache : in T_Cache_L; Politique : in T_Politique) return T_Cache_L;


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