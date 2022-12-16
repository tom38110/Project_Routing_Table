with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;               use Ada.Exceptions;
with Adresse_IP;                   use Adresse_IP;

package Table_Routage is

        type T_Table_Routage is limited private;

        -- Type énuméré de la politique du cache
        type T_Politique is (FIFO, LRU, LFU);

        --Ajouter l'adresseIP, le masque et l'interface dans la table de routage
        procedure Ajouter(Table : T_Table_Routage ; Destination: T_Adresse_IP ; Masque: T_Adresse_IP ; Interface_eth: Unbounded_String);

        --Supprimer tous les elements de la table
        procedure Vider(Table : T_Table_Routage);

        --Pointer la table de routage vers null
        procedure Initialiser(Table : T_Table_Routage);

        --Parcourir la liste chainee jusqu'a trouver l'element ayant cette adresseIP avec un masque valide
        --Retouner l'interface de cet element
        function Chercher_Element(Table : T_Table_Routage ; Paquet: T_Adresse_IP) return Unbounded_String;

        --Afficher chaque ligne de la Table de Routage
        procedure Afficher(Table : T_Table_Routage);

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
