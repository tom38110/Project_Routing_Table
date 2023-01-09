with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Adresse_IP; use Adresse_IP;

generic
    
CAPACITE: Integer; 

package Cache_A is

    type T_Cache_A is private;
    Interface_Absente_Cache : exception;

    -- Initialisation du cache.
    procedure Initialiser(Cache: out T_Cache_A);
           
    -- VÃ©rifier si le cache est vide.
    function Est_Vide (Cache: T_Cache_A) return Boolean;

    -- Ajouter une cellule au cache.
    procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface: in Unbounded_String);

    -- Classer les prÃ©fixes selon leur poids.
    procedure Classer_Pre(T: in out T_tab);
    
    -- Donne la taille du cache.
    function Nb_Element(Cache:in T_Cache_A) return Integer;
    
    -- Savoir si l'Adresse IP est prÃ©sente dans un cache.
    function IP_Presente(Cache:in T_Cache_A; paquet: in T_Adresse_IP) return Boolean;
    
    -- Decrocher le plus petit Ã©lement du Cache
    procedure Decrocher_Min(Cache: in out T_Cache_A; Min: out T_Cache_A) with
        Pre => Cache /= null,
        Post => Min /= null
            and Nb_Element(Min) = 1
            and Nb_Element(Cache) = TNb_Element(Cache)'Old
            and not(Cache'Old.all.Destination<Min.all.Destination);

    -- Supprimer une ligne du cache en resectant la politique LRU.
    procedure Supprimer(Cache:in out T_Cache_A; Destination: in T_Adresse_IP);

    -- Chercher l'interface correspondant au paquet dans le cache et lÃ¨ve une exception si il n'a pas trouvÃ©.
    function Chercher_Interface_A(Cache: in T_Cache_A; paquet: in T_Adresse_IP) return Unbounded_String;

    -- Comparer le prÃ©fixe aux feuilles.
    function Comparer(prefixe:in T_Adresse_IP; feuille:in T_Adresse_IP) return Boolean;

    -- VÃ©rifier si le cache est plein.
    function Cache_Plein(Cache:in T_Cache_A; Capacite_max: in Integer) return Boolean;

    -- CrÃ©Ã© un noeud avec la destination, le masque et l'interface souhaitÃ©e.
    function Noeud( Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface: in Unbounded_String) return T_Cellule;

    -- VÃ©rifie si on se trouve sur une feuille.
    function Est_Feuille(Cellule :in T_Cache_A) return Boolean;

    -- Renvoie le pÃ¨re de la feuille souhaitÃ©.
    function Pere(Cache:in T_Cache_A; Feuille: in T_Adresse_IP) return T_Cellule;

    -- Renvoie le nombre de fils d'un PÃ¨re.
    function Nb_Fils(Pere: in T_Cellule) return Integer;


    ------------------------
    -- CohÃ©rence du cache --
    ------------------------
    
    -- Renvoie la destination du cache qui a Ã©tÃ© utilisÃ©e le moins rÃ©cemment.
    function Plus_Ancien(Tableau: in T_tab) return T_Adresse_IP;

    -- Renvoie l'indice de destination dont le masque est le plus grand.
    function Masque_Max(Tableau:in T_tab) return Integer;


    

private

    Type T_Cellule;
    Type T_Cache_A is access T_Cellule;
    Type T_Cellule is 
        record
            Destination: T_Adresse_IP;
            Masque: T_Adresse_IP;
            Interface: Unbounded_String;
            Suivant_G: T_Cache_A;
            Suivant_D: T_Cache_A;
        end record;


    Type T_tab is array[1..CAPACITE] of T_Route;
    Type T_Route is
        record
            Destination: T_Adresse_IP;
            Masque: T_Adresse_IP;
            Interface: Unbounded_String;

        end record;


end Cache_A;