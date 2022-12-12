package Routeur is
        type T_Tab_Routage is limited private;
        type T_Politique is (FIFO, LRU, LFU);
        type T_Adresse_IP is mod 2 ** 32;
        UN_OCTET: constant T_Adresse_IP := 2 ** 8;

        --Ajouter l'adresseIP, le masque et l'interface dans la table de routage
        procedure ajouter(Table : T_Tab_Routage ; Destination: T_Adresse_IP ; Masque: T_Adresse_IP ; Interface_eth: Integer);


        --Vider la table de routage
        procedure vider(Table : T_Tab_Routage);

        --
        procedure initialiser(Table : T_Tab_Routage ; Destination: T_Adresse_IP ; Masque: T_Adresse_IP ; Interface_eth: Integer);

        function chercher_element(Table : T_Tab_Routage ; Destination: T_Adresse_IP) return Integer;

        procedure afficher(Table : T_Tab_Routage);



private

        type T_Cellule;

        type T_Tab_Routage is access T_Cellule;

        type T_Cellule is
            record
                    Destination: T_Adresse_IP;
                    Masque: T_Adresse_IP;
                    Interface_eth: Integer;
                    Suivante: T_Tab_Routage;
            end record;

end Routeur;
