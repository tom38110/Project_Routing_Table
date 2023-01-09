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
                                null;
                        else
                                Detruire := Table;
                                Table := Table.all.Suivante;
                                Free(Detruire);
                                Vider (Table);
                        end if;
                end Vider;


        procedure Initialiser(Table : out T_Table_Routage) is
        begin
                Table := null;
        end Initialiser;


        procedure Chercher_Interface(Table : in T_Table_Routage ; Paquet: in T_Adresse_IP ; Interface_eth : out Unbounded_String ; Cache : in out T_Cache ; Capacite_Cache : in Integer ; Politique : in T_Politique) is
                Table_parcours : T_Table_Routage := Table;
                Masque_Max : T_Adresse_IP := 0;
        begin
                Initialiser(Sous_Table);
                while Table_parcours /= Null loop
                        if Comp_Destination_Paquet(Table_parcours.all.Destination, Table_parcours.all.Masque, Paquet) and then Masque_Max <= Table_parcours.all.Masque then
                                Interface_eth := Table_parcours.all.Interface_eth;
                                Masque_Max := Table_parcours.all.Masque;
                        end if;
                        Table_parcours := Table_parcours.all.Suivante;
                end loop;
                Maj_Cache(Cache, Capacite_Cache, Politique, Table, Masque_Max, Interface_eth, Paquet);
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
