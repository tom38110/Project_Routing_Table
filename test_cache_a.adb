with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Adresse_IP;                   use Adresse_IP;
with Cache_A;                      use Cache_A;
with Ada.Unchecked_Deallocation;






procedure cache_arbre is
   -- On Initialise les données dont on aura besoin pour tester les sous programmes du cache A
   C:T_Cache_A;
   C2:T_Cache_A;

   ligne:String :="147.128.12.0"; --D
   ligne2:String :="255.255.255.0";
   ligne3:String :="147.127.12.0"; --D2
   ligne4:String :="255.255.0.0";
   ligne5:String :="146.128.12.0"; --D3
   ligne6:String :="255.255.18.0";
   ligne7:String :="141.123.11.0"; --D4
   ligne8:String :="255.0.0.0";
   D: T_Adresse_IP:=Conv_String_IP (ligne);
   M: T_Adresse_IP:=Conv_String_IP (ligne2);
   D2: T_Adresse_IP:=Conv_String_IP (ligne3);
   M2: T_Adresse_IP:=Conv_String_IP (ligne4);
   D3: T_Adresse_IP:=Conv_String_IP (ligne5);
   M3: T_Adresse_IP:=Conv_String_IP (ligne6);
   D4: T_Adresse_IP:=Conv_String_IP (ligne7);
   I: Unbounded_String;
   J: Unbounded_String;
   Z: Unbounded_String;
   l:Integer;
   e: String(1..4);
   f: String(1..4);
   a: Unbounded_String;
   v:Integer;
   K:Boolean;


begin



   Put_Line("Début de la campagne de test du cache A...");
   Initialiser_A(C2);
   v:=1;
   Put_Line("Entrez une première interface");
   Get(e);
   Put_Line("Entrez une seconde interface");
   Get(f);
   J:=To_Unbounded_String(f);
   I:=To_Unbounded_String(e);
   l:=1;

   Put_Line("On initialise le cache ...");
   Initialiser_A(C);
   Put_Line("Ajout dans le cache");
   Ajouter_C(C,D,M,I,v);
   Ajouter_C(C,D2,M2,J,v);
   Ajouter_C(C,D3,M3,I,v);
   Afficher_A(C);
   -- On vérifie que les éléments ont bien été ajouté.
   Put_Line(" ");
   Afficher_B(C);
   -- On vérifie qu'il y'a bien les noeuds
   Put_Line("on commence supprimer de 147.128.12.0 ");
   Supprimer(C,D);
   Afficher_A(C);
   -- On vérifie que 147.128.12.0 a bien été supprimée
   -- vérifie que la route de 147.127.12.0 est bien présente
   Put_Line("on vérifie que la route de 147.127.12.0 est bien présente");
   K:=Route_Presente(C,D2);
   if K then
      Put_Line("Vraie");
   elsif not(K) then
      Put_Line("Faux");
   else
      Put_Line("Erreur autre");
   end if;
   max_masque_correspondant(C,D2,C2);
   Afficher_A(C2);
   Put("fin");

end cache_arbre;