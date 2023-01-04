with Ada.Unchecked_Deallocation;
with Ada.Text_IO;                  use Ada.Text_IO;

package body Cache_L is

    procedure Free is
    new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Table_Routage);


    procedure Initialiser_L(Cache : out T_Cache_L) is
    begin
        Cache := null;
    end Initialiser_L;


    procedure Afficher_L(Cache : in T_Cache_L) is
    begin
        if Cache = Null then
            Null;
        else
            Afficher_IP(Cache.All.Destination);
            Put(" ");
            Afficher_IP(Cache.All.Masque);
            Put(" ");
            Put_Line(To_String(Cache.All.Interface_eth));
            Afficher(Cache.All.Suivante);
        end if;
    end Afficher_L;

