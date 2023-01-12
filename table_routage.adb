with Ada.Unchecked_Deallocation;
with Ada.Text_IO;                  use Ada.Text_IO;


package body Table_Routage is


procedure Free is
new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table_Routage);


        procedure Ajouter(Table : in out T_Table_Routage ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP ; Interface_eth : in Unbounded_String) is
        begin
                if Table = Null then
                        Table := new T_Cellule'(Destination, Masque, Interface_eth, Null);
                else
                        Ajouter(Table.All.Suivante, Destination, Masque, Interface_eth);
                end if;
        end Ajouter;


        procedure Vider(Table : in out T_Table_Routage) is
                        Detruire : T_Table_Routage ;
                begin
                        if Table = null then
                                Null;
                        else
                                Detruire := Table;
                                Table := Table.all.Suivante;
                                Free(Detruire);
                                Vider(Table);
                        end if;
                end Vider;


        procedure Initialiser(Table : out T_Table_Routage) is
        begin
                Table := null;
        end Initialiser;


        function Gerer_Coherence_Cache(Table : in T_Table_Routage ; Destination : in T_Adresse_IP ; Masque : in T_Adresse_IP) return T_Adresse_IP is
                Masque_coherent : T_Adresse_IP := Masque; -- Masque qui respecte la cohérence du cache
                Table_Parcours : T_Table_Routage := Table; -- Curseur qui parcours la table
        begin
                while Table_Parcours /= Null loop
                        if Comp_Destination_Paquet(Destination, Masque, Table_Parcours.all.Destination) and then Masque_coherent < Table_Parcours.all.Masque then
                                Masque_coherent := Table_Parcours.all.Masque;
                        else
                                Null;
                        end if;
                        Table_Parcours := Table_Parcours.all.Suivante;
                end loop;
                return Masque_coherent;
        end Gerer_Coherence_Cache;


        procedure Chercher_Interface(Table : in T_Table_Routage ; Paquet : in T_Adresse_IP ; Interface_eth : out Unbounded_String ; Masque_Max : out T_Adresse_IP ; Destination_correspondante : out T_Adresse_IP) is
                Table_parcours : T_Table_Routage := Table;
        begin
                Masque_Max := 0;
                Destination_correspondante := 0;
                Interface_eth := To_Unbounded_String("");
                -- Trouver l'interface correspondant au paquet
                while Table_parcours /= Null loop
                        if Comp_Destination_Paquet(Table_parcours.all.Destination, Table_parcours.all.Masque, Paquet) and then Masque_Max < Table_parcours.all.Masque then
                                Interface_eth := Table_parcours.all.Interface_eth;
                                Masque_Max := Table_parcours.all.Masque;
                                Destination_correspondante := Table_parcours.all.Destination;
                        else
                                null;
                        end if;
                        Table_parcours := Table_parcours.all.Suivante;
                end loop;
        end Chercher_Interface;


        procedure Afficher(Table : in T_Table_Routage) is
        begin
                if Table = Null then
                        Null;
                else
                        Afficher_IP(Table.All.Destination);
                        Put(" ");
                        Afficher_IP(Table.All.Masque);
                        Put(" ");
                        Put_Line(To_String(Table.All.Interface_eth));
                        Afficher(Table.All.Suivante);
                end if;
        end Afficher;

end Table_Routage;
