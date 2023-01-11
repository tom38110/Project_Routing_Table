with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Adresse_IP;                   use Adresse_IP;
with Cache_A;                      use Cache_A;





procedure cache_arbre is


   C:T_Cache_A;
   ligne:String :="147.128.12.0";
   ligne2:String :="255.255.255.0";
   ligne3:String :="147.127.12.0";
   ligne4:String :="255.255.0.0";
   ligne5:String :="146.128.12.0";
   ligne6:String :="255.255.18.0";
   D: T_Adresse_IP:=Conv_String_IP (ligne);
   M: T_Adresse_IP:=Conv_String_IP (ligne2);
   D2: T_Adresse_IP:=Conv_String_IP (ligne3);
   M2: T_Adresse_IP:=Conv_String_IP (ligne4);
   D3: T_Adresse_IP:=Conv_String_IP (ligne5);
   M3: T_Adresse_IP:=Conv_String_IP (ligne6);
   I: Unbounded_String;
   l:Integer;
   e: String(1..4);
   a: Unbounded_String;
   v:Integer;
begin
   v:=1;
   Get(e);
   I:=To_Unbounded_String(e);
   l:=1;
   Initialiser_A(C);
   Put_Line("Ajout dans le cache");
   Ajouter_C(C,D,M,I,v);
   Ajouter_C(C,D2,M2,I,v);
   Ajouter_C(C,D3,M3,I,v);
   Afficher_A(C);
   Put_Line("on commence supprimer de 147.128.12.0 ");
   Supprimer(C,D);
   Afficher_A(C);
  -- Put_Line("on commence à chercher l'interface de 147.127.12.0");
  -- a:=Chercher_Interface_A(C,D2);
   --Put_Line(a);
end cache_arbre;