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


        function Chercher_Element(Table : in T_Table_Routage ; Paquet : in T_Adresse_IP) return Unbounded_String is
                Table_parcours : T_Table_Routage := Table;
        begin
                while not(Comp_Destination_Paquet(Table_parcours.all.Destination, Table_parcours.all.Masque, Paquet)) loop
                        Table_parcours := Table_parcours.all.Suivante;
                end loop;
                return Table_parcours.all.Interface_eth;
        end Chercher_Element;



        procedure Afficher(Table : in out T_Table_Routage) is
                package AIP_IO is new
                        Ada.Text_IO.Modular_IO(T_Adresse_IP);
                use AIP_IO;
        begin
                while (Table /= null) loop
                        Put("check");
                        New_Line;
                        Put(Table.all.Destination);
                        Put(" ");
                        Put(Table.all.Masque);
                        Put(" ");
                        Put(To_String(Table.all.Interface_eth));
                        New_Line;
                        Table := Table.all.Suivante;
                end loop;
        end Afficher;

end Table_Routage;
