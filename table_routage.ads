with Adresse_IP;

package Table_Routage is

        type T_Table_Routage is limited private;
        type T_Politique is (FIFO, LRU, LFU);

        --Ajouter l'adresseIP, le masque et l'interface dans la table de routage
        procedure Ajouter(Table : T_Table_Routage ; Destination: T_Adresse_IP ; Masque: T_Adresse_IP ; Interface_eth: Unbounded_String);

        --Supprimer tous les éléments de la table
        procedure Vider(Table : T_Table_Routage);

        --Pointer la table de routage vers null
        procedure Initialiser(Table : T_Table_Routage);

        --Parcourir la liste chaînée jusqu'à trouver l'élément ayant cette adresseIP
        --Retouner l'interface de cet élément
        function Chercher_Element(Table : T_Table_Routage ; Destination: T_Adresse_IP) return Integer;

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
