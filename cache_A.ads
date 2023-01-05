with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Adresse_IP; use Adreesse_IP;

generic
    
CAPACITE: Integer; 

package Cache_A is

    type T_Cache_A is private;

    -- Initialisation du cache.
    procedure Initialiser(Cache: out T_Cache_A);
           
    -- Vérifier si le cache est vide.
    function Est_Vide (Cache: T_Cache_A) return Boolean;

    -- Ajouter une cellule au cache.
    procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface: in Unbounded_String);

    -- Classer les préfixes selon leur poids.
    procedure Classer_Pre(T: in out T_tab);
    
    -- Donne la taille du cache.
    function Nb_Element(Cache:in T_Cache_A) return Integer;
    
    -- Savoir si l'Adresse IP est présente dans un cache.
    function IP_Presente(Cache:in T_Cache_A; paquet: in T_Adresse_IP) return Boolean;
    
    -- Decrocher le plus petit élement du Cache
    procedure Decrocher_Min(Cache: in out T_Cache_A; Min: out T_Cache_A) with
        Pre => Cache /= null,
        Post => Min /= null
            and Nb_Element(Min) = 1
            and Nb_Element(Cache) = TNb_Element(Cache)'Old
            and not(Cache'Old.all.Destination<Min.all.Destination);

    -- Supprimer une ligne du cache en resectant la politique LRU.
    procedure Supprimer(Cache:in out T_Cache_A,Destination: in T_Adresse_IP);

    -- Chercher l'interface correspondant au paquet dans le cache et lève une exception si il n'a pas trouvé.
    function Chercher(Cache: in T_Cache_A; paquet: in T_Adresse_IP) return Unbounded_String;

    -- Comparer le préfixe aux feuilles.
    function Comparer(prefixe:in T_Adresse_IP; feuille:in T_Adresse_IP) return Boolean;

    -- Vérifier si le cache est plein.
    function Cache_Plein(Cache:in T_Cache_A;Capacite_max) return Boolean;

    ------------------------
    -- Cohérence du cache --
    ------------------------


private

    type T_Cellule;
    type T_Cache_A is access T_Cellule;
    type T_Cellule is 
        record
            Destination: T_Adresse_IP;
            Masque: T_Adresse_IP;
            Interface: Unbounded_String;
            Suivant_G: T_Cache_A;
            Suivant_D: T_Cache_A;
        end record;


    type T_tab is array[1..CAPACITE] T_Route;
    type T_Route is
        record
            Destination: T_Adresse_IP;
            Masque: T_Adresse_IP;
            Interface: Unbounded_String;
        end record;


end Cache_A;
    








