with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Adresse_IP;                   use Adresse_IP;

package Table_Routage is

        type T_Table_Routage is limited private;

        --Ajouter l'adresseIP, le masque et l'interface dans la table de routage
        procedure Ajouter(Table : in out T_Table_Routage ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String);

        --Supprimer tous les elements de la table
        procedure Vider(Table : in out T_Table_Routage);

        --Pointer la table de routage vers null
        procedure Initialiser(Table : out T_Table_Routage);

        -- Renvoie un masque qui permettra de respecter la cohérence du cache (masque le plus long parmis les routes qui correspondent à la route utilisée)
        function Gerer_Coherence_Cache(Table : in T_Table_Routage ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP) return T_Adresse_IP;

        -- Renvoie un masque qui permettra de respecter la cohérence du cache (masque le plus long parmis les routes qui correspondent à la route utilisée)
        function Gerer_Coherence_Cache_Opti(Table : in T_Table_Routage ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP) return T_Adresse_IP;

        --Trouver l'interface correspondant au paquet dans la table de routage (récupère le masque et la destination de la route utilisée)
        procedure Chercher_Interface(Table : in T_Table_Routage ; Paquet : in T_Adresse_IP ; Interface_eth : out Unbounded_String ; Masque_Max : out T_Adresse_IP ; Destination_correspondante : out T_Adresse_IP);

        --Afficher chaque ligne de la Table de Routage
        procedure Afficher(Table : in T_Table_Routage);

private

        type T_Cellule;

        type T_Table_Routage is access T_Cellule;

        type T_Cellule is
            record
                    Destination: T_Adresse_IP;
                    Masque: T_Adresse_IP;
                    Interface_eth: Unbounded_String;
                    Suivante: T_Table_Routage;
            end record;

end Table_Routage;
