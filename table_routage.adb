with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;               use Ada.Exceptions;
with Adresse_IP;                   use Adresse_IP;

package body Table_Routage is


        procedure Free is
           new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table_Routage);

        --Ajoute le paquet (Destination, Masque, Interface_eth) à la table de routage
        --Paramètres:
        --      Destination  : l'adresse_IP du paquet
        --      Masque       : le masque du paquet
        --      Interface_eth: l'interface du paquet
        --
        --Précondition: aucune
        --Postcondition: l'élément (Destination,Masque,Interface_eth) est le dernier élément de Table
        procedure Ajouter(Table : T_Table_Routage ; Destination: T_Adresse_IP ; Masque: T_Adresse_IP ; Interface_eth: Unbounded_String) is
                Table_parcours : T_Table_Routage := Table;
        begin
                loop
                        Table_parcours := Table_parcours.all.Suivante;           --Pour acceder au dernier element de la liste chainee,
                        exit when (Table_parcours = null);                       --il faut la parcourir jusqu'a l'element qui pointe vers null.
                end loop;                                                        --on fait pointer ce dernier élément vers la cellule souhaitee
                Table_parcours := new T_Cellule'(Destination, Masque, Interface_eth, null);    
        end Ajouter;

        --Vide la table de routage
        --Paramètres:
        --      Table : La table de routage à vider
        --
        --Précondition: aucune
        --Postcondition: Table est vide
        procedure Vider(Table : T_Table_Routage) is
                Detruire : T_Table_Routage ;
        begin                                               --On procede recursivement: a chaque appelle de la procedure,
                if Table = null then                        --on libere un element de la liste chainee jusqu'a ce qu'elle soit vide
                        null;
                else
                        Detruire := Table;
                        Table := Table.all.Suivante;
                        Free(Detruire);
                        Vider (Table);
                end if;
        end Vider;


        --Initialise la table de routage
        --Paramètres:
        --      Table : La table de routage à initialiser
        --
        --Précondition: aucune
        --Postcondition: Table est initialisée à null
        procedure Initialiser(Table : T_Table_Routage) is
        begin
                Table := null;
        end Initialiser;

        --Retourne l'interface correspondant au paquet à l'aide de Table
        --Paramètres:
        --      Table  : La table de routage contenant l'interface
        --      Paquet : Le paquet à router avec l'interface que retourne cette fonction
        --
        --Précondition: aucune
        --Postcondition: L'interface doit correspondre au paquet
        function Chercher_Element(Table : T_Table_Routage ; Paquet: T_Adresse_IP) return Unbounded_String is
                Table_parcours : T_Table_Routage := Table;
        begin
                while (Comp_Destination_Paquet(Table_parcours.all.Destination; Table_parcours.all.Masque; Paquet) = False) loop
                        Table_parcours := Table_parcours.all.Suivante;
                end loop;
                return Table_parcours.all.Interface_eth;
        end Chercher_Element;


        --Affiche la table de routage
        --Paramètres:
        --      Table : La table de routage à afficher
        --
        --Précondition: aucune
        --Postcondition: Table a entièrement été affiché
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


