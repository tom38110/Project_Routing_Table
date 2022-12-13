with Ada.Unchecked_Deallocation;
with Adresse_IP;

package body Table_Routage is


        procedure Free is
           new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table_Routage);


        procedure Ajouter(Table : T_Table_Routage ; Destination: T_Adresse_IP ; Masque: T_Adresse_IP ; Interface_eth: Unbounded_String) is
                Table_parcours : T_Table_Routage := Table;
        begin
                loop
                        Table_parcours := Table_parcours.all.Suivante;
                        exit when (Table_parcours = null);
                end loop;
                Table_parcours := new T_Cellule'(Destination, Masque, Interface_eth, null);
        end Ajouter;


        procedure Vider(Table : T_Table_Routage) is
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



        procedure Initialiser(Table : T_Table_Routage) is
        begin
                Table := null;
        end Initialiser;


        function Chercher_Element(Table : T_Table_Routage ; Paquet: T_Adresse_IP) return Unbounded_String is
                Table_parcours : T_Table_Routage := Table;
        begin
                while (Comp_Destination_Paquet(Table_parcours.all.Destination; Table_parcours.all.Masque; Paquet) = False) loop
                        Table_parcours := Table_parcours.all.Suivante;
                end loop;
                return Table_parcours.all.Interface_eth;
        end Chercher_Element;



        procedure Afficher(Table : T_Table_Routage) is
                Table_parcours : T_Table_Routage := Table;
        begin
                while (Table_parcours /= null) loop
                        Put(Conv_IP_ligne(Table_parcours.all.Destination));
                        Put(" ");
                        Put(Conv_IP_ligne(Table_parcours.all.Masque));
                        Put(" ");
                        Put(Table_parcours.all.Interface_eth);
                        New_Line;
                        Table_parcours := Table_parcours.all.Suivante;
                end loop;
        end Afficher;

end Table_Routage;

