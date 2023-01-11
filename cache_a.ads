with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Adresse_IP; use Adresse_IP;


package Cache_A is

   type T_Cache_A is private;

   Interface_Absente_Cache : exception;

   -- Initialisation du cache.
   procedure Initialiser_A(Cache: out T_Cache_A);

   -- VÃ©rifier si le cache est vide.
   function Est_Vide (Cache: T_Cache_A) return Boolean;

   -- Ajouter une cellule au cache.
   procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface_eth: in Unbounded_String; i :in out Integer);

   -- Donne la taille du cache.
   function Nb_Element(Cache:in T_Cache_A) return Integer;

   -- Savoir si l'Adresse IP est prÃ©sente dans un cache.
   function IP_Presente(Cache:in T_Cache_A; paquet: in T_Adresse_IP) return Boolean;

   -- Decrocher le plus petit Ã©lement du Cache
   procedure Decrocher_Min(Cache: in out T_Cache_A; Min: out T_Cache_A);

   -- Supprimer une ligne du cache en resectant la politique LRU.
   procedure Supprimer(Cache:in out T_Cache_A; Destination: in T_Adresse_IP);

   -- Chercher l'interface correspondant au paquet dans le cache et lÃ¨ve une exception si il n'a pas trouvÃ©.
   function Chercher_Interface_A(Cache: in T_Cache_A; paquet: in T_Adresse_IP) return Unbounded_String;

   -- VÃ©rifier si le cache est plein.
   function Cache_Plein(Cache:in T_Cache_A; Capacite_max: in Integer) return Boolean;

   -- VÃ©rifie si on se trouve sur une feuille.
   function Est_Feuille(Cellule :in T_Cache_A) return Boolean;

   -- Renvoie le pÃ¨re de la feuille souhaitÃ©.
   function Pere(Cache:in T_Cache_A; Feuille: in T_Adresse_IP) return T_Cache_A;

   -- Renvoie le nombre de fils d'un PÃ¨re.
   function Nb_Fils(Pere: in T_Cache_A) return Integer;

   -- Affiche le cache sous la forme "Destination  Masque  Interface".
   procedure Afficher_A(Cache : in T_Cache_A);

   -- Affiche les différentes statistiques du cache.
   procedure Afficher_Stat_A(Cache: in T_Cache_A; Capacite_max:in Integer);

   -- Vide le cache.
   procedure Vider_A(Cache:in out T_Cache_A);



private

   Type T_Cellule;
   Type T_Cellule is
      record
         Destination: T_Adresse_IP;
         Masque: T_Adresse_IP;
         Interface_eth: Unbounded_String;
         Suivant_G: T_Cache_A;
         Suivant_D: T_Cache_A;
      end record;
   Type T_Cache_A is access T_Cellule;


end Cache_A;