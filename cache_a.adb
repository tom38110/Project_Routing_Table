with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Adresse_IP;                   use Adresse_IP;
with Ada.Unchecked_Deallocation;



package body Cache_A is

   procedure Free is
     new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Cache_A);

   procedure Initialiser_A(Cache: out T_Cache_A) is
   begin
      Cache:=null;
   end Initialiser_A;


   function Est_Vide (Cache: in T_Cache_A) return Boolean is
   begin
      return Cache=null;
   end Est_Vide;


   procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface_eth: in Unbounded_String; i:in out Integer) is --i: in out Integer
      Noeud_Copie : T_Cache_A;
   begin
      -- on vérifie si le cache est vide
      if Est_Vide(Cache) then
         Noeud_Copie := new T_Cellule'(Destination,Masque,Interface_eth,null,null);
         Cache := Noeud_Copie;
         -- Si on est sur une feuille et que la Destination correspond dans le cache
      elsif (Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) and (Destination = Cache.all.Destination) then
         Cache.all.Masque:=Masque;
         Cache.all.Interface_eth:=Interface_eth;
         -- Si on est sur une feuille et que la Destination ne correspond pas
      elsif (Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) and not(Destination = Cache.all.Destination) then

         Noeud_Copie:= new T_Cellule;
         -- On pousse la feuille à gauche.
         if not(Ie_Bit_A_1(Cache.all.Destination, i)) then
            Noeud_Copie.all.Suivant_G:=Cache;
            Noeud_Copie.all.Suivant_D:=null;
            -- On pousse la feuille à droite.
         else
            Noeud_Copie.all.Suivant_G:=null;
            Noeud_Copie.all.Suivant_D:=Cache;
         end if;
         -- on repointe sur la noeud créé.
         Cache:=Noeud_Copie;
         Ajouter_C(Cache,Destination,Masque,Interface_eth,i);
         -- on lance l'appelle recursif.
      elsif not(Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) and not (Ie_Bit_A_1(Destination, i)) then
         i:=i+1;
         Ajouter_C(Cache.all.Suivant_G,Destination,Masque,Interface_eth,i);

      else
         i:=i+1;
         Ajouter_C(Cache.all.Suivant_D,Destination,Masque,Interface_eth,i);
      end if;

   end Ajouter_C;


   function Nb_Element(Cache:in T_Cache_A) return Integer is
   begin
      if Cache = null then
         return 0;
      else
         return 1+ Nb_Element(Cache.all.Suivant_D) + Nb_Element(Cache.all.Suivant_G);
      end if;
   end Nb_Element;




   function IP_Presente(Cache:in T_Cache_A; paquet: in T_Adresse_IP) return Boolean is
   begin
      -- Cas d'arret si le cache est vide
      if Cache = null then
         return False;
      else
         -- Cas ou on a bien correspondance entre le paquet et la route
         if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
            return True;
            -- Appel récursif
         else
            return IP_Presente(Cache.all.Suivant_D,paquet) or IP_Presente(Cache.all.Suivant_G,paquet);
         end if;
      end if;
   end IP_Presente;


   procedure Supprimer(Cache:in out T_Cache_A; Destination: in T_Adresse_IP)is
      --C_Detruire:T_Cache_A;
   begin
      -- Cas où le cache est vide
      if Cache= null then
         null;
         -- Cas où on est sur feuille
      elsif (Cache.all.Suivant_G=null and Cache.all.Suivant_D=null)then
         -- Si la destinatiion correspond on supprime l'élément
         if Cache.all.Destination = Destination then
            Free(Cache);
         end if;
      else
         -- Appel récursif
         if not(Est_Vide(Cache.all.Suivant_G)) then
            Supprimer(Cache.all.Suivant_G,Destination);
         end if;
         if not(Est_Vide(Cache.all.Suivant_D)) then
            Supprimer(Cache.all.Suivant_D,Destination);
         end if;
      end if;

   end Supprimer;


   procedure Chercher_Interface_A(Cache: in out T_Cache_A; paquet: in T_Adresse_IP; Interface_eth: out Unbounded_String) is
      Maxi: T_Cache_A;

   begin
      -- si la route est bien presente on cherche la route correspondante avec le masque le plus grand
      if Route_Presente(Cache,paquet) then
         max_masque_correspondant(Cache,paquet,Maxi);
      else
         -- on lève un exception si on ne trouve pas
         raise Interface_Absente_Cache;
      end if;
      -- on modifie l'interface
      Interface_eth:=Maxi.all.Interface_eth;
   end Chercher_Interface_A;


   procedure max_masque_correspondant(Cache:in T_Cache_A;paquet: in T_Adresse_IP; Maxi: in out T_Cache_A)  is

   begin
      -- Cas où le cache est vide
      if Est_Vide(Cache) then
         Maxi:=null;
      else
         -- Cas où le masque du cache est plus grand que celui de Maxi
         if Cache.all.Masque > Maxi.all.Masque then
            -- mis à jour de Maxi
            Maxi.all.Destination:=Cache.all.Destination;
            Maxi.all.Masque:=Cache.all.Masque;
            Maxi.all.Interface_eth:=Cache.all.Interface_eth;
         end if;
         -- Appel récursif
         max_masque_correspondant(Cache.all.Suivant_D,paquet,Maxi);
         max_masque_correspondant(Cache.all.Suivant_G,paquet,Maxi);
      end if;
   end max_masque_correspondant;


   function Route_Presente(Cache:in T_Cache_A;paquet:in T_Adresse_IP) return Boolean is

   begin
      -- Cas où le cache est vide
      if Est_Vide(Cache) then
         return False;
         -- on est sur une feuille et paquet a bien une route compatible
      elsif (Cache.all.Suivant_D = null and Cache.all.Suivant_G = null) and then Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
         return True;
      else
         -- Appel récursif
         return Route_Presente(Cache.all.Suivant_G, paquet) or Route_Presente(Cache.all.Suivant_D, paquet);
      end if;


   end Route_Presente;



   function Cache_Plein(Cache:in T_Cache_A; Capacite_max:in Integer) return Boolean is
   begin
      --on vérifie sii le cache est plein
      return Nb_Element(Cache)=Capacite_max;
   end Cache_Plein;


   function Est_Feuille(Cellule:in T_Cache_A) return Boolean is
   begin
      return Cellule.all.Suivant_D = null and Cellule.all.Suivant_D = null;
   end Est_Feuille;


   function Nb_Fils(Pere: in T_Cache_A) return Integer is
      NbFils: Integer;
   begin
      NbFils:=0;
      -- si il a un fils droit
      if Pere.Suivant_D /=null then
         NbFils:=NbFils+1;
         -- si il a un fils gauche
      elsif Pere.Suivant_G /=null then
         NbFils:=NbFils+1;
      end if;
      return NbFils;
   end Nb_Fils;

   procedure Afficher_A(Cache : in T_Cache_A) is
   begin
      -- Cas où le cache est vide.
      if Cache = Null then
         Null;
      else
         -- si on est sur une feuille on l'affiche.
         if Cache.all.Suivant_D=null and Cache.all.Suivant_G=null then
            Afficher_IP(Cache.All.Destination);
            Put(" ");
            Afficher_IP(Cache.All.Masque);
            Put(" ");
            Put_Line(To_String(Cache.All.Interface_eth));
         else
            -- Appell récursif.
            Afficher_A(Cache.All.Suivant_G);
            Afficher_A(Cache.All.Suivant_D);
         end if;
      end if;
   end Afficher_A;

   procedure Afficher_B(Cache : in T_Cache_A) is
   begin
      -- Cas où le cache est vide
      if Cache = Null then
         Null;
         -- On affiche les statistiques
      else

         Afficher_IP(Cache.All.Destination);
         Put(" ");
         Afficher_IP(Cache.All.Masque);
         Put(" ");
         Put_Line(To_String(Cache.All.Interface_eth));
         Put_Line("<--");
         Afficher_A(Cache.All.Suivant_G);
         Put_Line("-->");
         Afficher_A(Cache.All.Suivant_D);


      end if;
   end Afficher_B;


   procedure Afficher_Stat_A(Cache: in T_Cache_A; Capacite_max:in Integer) is
      N: Integer;
   begin
      -- on affiche tout le cache noeud inclus
      N:= Nb_Element(Cache);
      Put_Line("La poltique est LRU.");
      Put("Il y a");
      Put(N,2);
      Put_Line(" élements dans le cache.");
      Put("La capacité maximale du cache est ");
      Put(Capacite_max,1);
      Put_Line(".");
   end Afficher_Stat_A;



   procedure Vider_A(Cache:in out T_Cache_A) is
   begin
      -- Cas où le cache est vide
      if Cache = null then
         null;
         --Appel récursif
      else
         Vider_A(Cache.all.Suivant_G);
         Vider_A(Cache.all.Suivant_D);
         Free(Cache);
      end if;
   end Vider_A;





end Cache_A;