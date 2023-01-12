with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings;                  use Ada.Strings;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;     use Ada.Text_IO.Unbounded_IO;
with Adresse_IP;                   use Adresse_IP;
with Ada.Unchecked_Deallocation;



package body Cache_A is

     procedure Free is
       new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_Cache_A);

     -- Initialisation du cache.
     procedure Initialiser_A(Cache: out T_Cache_A) is
     begin
          Cache:=null;
     end Initialiser_A;

     -- Vérifier si le cache est vide.
     function Est_Vide (Cache: in T_Cache_A) return Boolean is
     begin
          return Cache=null;
     end Est_Vide;


     procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface_eth: in Unbounded_String; i:in out Integer) is --i: in out Integer
          Noeud_Copie : T_Cache_A;
     begin
          if Est_Vide(Cache) then
               Noeud_Copie := new T_Cellule'(Destination,Masque,Interface_eth,null,null);
               Cache := Noeud_Copie;
          elsif (Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) and (Destination = Cache.all.Destination) then
               Cache.all.Masque:=Masque;
               Cache.all.Interface_eth:=Interface_eth;

          elsif (Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) and not(Destination = Cache.all.Destination) then

               Noeud_Copie:= new T_Cellule;
               if not(Ie_Bit_A_1(Cache.all.Destination, i)) then
                    Noeud_Copie.all.Suivant_G:=Cache;
                    Noeud_Copie.all.Suivant_D:=null;
               else
                    Noeud_Copie.all.Suivant_G:=null;
                    Noeud_Copie.all.Suivant_D:=Cache;
               end if;
               Cache:=Noeud_Copie;
               Ajouter_C(Cache,Destination,Masque,Interface_eth,i);
          elsif not(Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) and not (Ie_Bit_A_1(Destination, i)) then
               i:=i+1;
               Ajouter_C(Cache.all.Suivant_G,Destination,Masque,Interface_eth,i);

          else
               i:=i+1;
               Ajouter_C(Cache.all.Suivant_D,Destination,Masque,Interface_eth,i);
          end if;

     end Ajouter_C;


     -- Donne la taille du cache. (Attention condition feuille)
     function Nb_Element(Cache:in T_Cache_A) return Integer is
     begin
          if Cache = null then
               return 0;
          else
               return 1+ Nb_Element(Cache.all.Suivant_D) + Nb_Element(Cache.all.Suivant_G);
          end if;
     end Nb_Element;

     -- Savoir si l'Adresse IP est prÃ©sente dans un cache.(MODIFIER POUR VÉRIFIER QUE LA ROUTE EST BIEN PRÉSENTE)

     function IP_Presente(Cache:in T_Cache_A; paquet: in T_Adresse_IP) return Boolean is
     begin
          if Cache = null then
               return False;
          else
               if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
                    return True;
               else
                    return IP_Presente(Cache.all.Suivant_D,paquet) or IP_Presente(Cache.all.Suivant_G,paquet);
               end if;
          end if;
     end IP_Presente;

     -- Decrocher le plus petit Ã©lement du Cache. (inutile)
     procedure Decrocher_Min(Cache: in out T_Cache_A; Min: out T_Cache_A) is
     begin
          if Cache.all.Suivant_G= null then
               Min:=Cache;
               Cache:=Cache.all.Suivant_D;
               Min.all.Suivant_D:= null;
          else
               Decrocher_Min(Cache.all.Suivant_G,Min);
          end if;
     end Decrocher_Min;

     -- Supprimer une ligne du cache en resectant la politique LRU. ## (A vÃ©rifier)
     --procedure Supprimer(Cache:in out T_Cache_A; Destination: in T_Adresse_IP) is
     --   Paternel: T_Cache_A;
     --begin
     --   Paternel:=Pere(Cache,Destination);
     --   if Est_Vide(Cache) then
     --      Null;
     --   else
     --     if Nb_Fils(Paternel)=1 then
     --      if Cache.all.Destination = Destination then
     --          Free(Cache);
     --         Free(Paternel);
     --      else
     --        Supprimer(Cache.all.Suivant_D,Destination);
     --        Supprimer(Cache.all.Suivant_G,Destination);
     --     end if;
     --   elsif Nb_Fils(Paternel)=2 then
     --     if Cache.all.Destination = Destination then
     ---       Free (Cache);
     --     else
     --       Supprimer(Cache.all.Suivant_D,Destination);
     --       Supprimer(Cache.all.Suivant_G,Destination);
     --     end if;
     --   end if;
     -- end if;
     --end Supprimer;
     procedure Supprimer(Cache:in out T_Cache_A; Destination: in T_Adresse_IP)is
          --C_Detruire:T_Cache_A;
     begin
         if Cache= null then
               null;
          elsif not (Cache.all.Destination=0)then
               if Cache.all.Destination = Destination then
                    Free(Cache);
               end if;
          else
               if not(Est_Vide(Cache.all.Suivant_G)) then
                    Supprimer(Cache.all.Suivant_G,Destination);
               end if;
               if not(Est_Vide(Cache.all.Suivant_D)) then
                    Supprimer(Cache.all.Suivant_D,Destination);
               end if;
          end if;


          --elsif Cache.all.Destination < Destination then
         --      Supprimer(Cache.all.Suivant_D, Destination);
        ---  elsif Cache.all.Destination > Destination then
        --       Supprimer(Cache.all.Suivant_G,Destination);
        --  else
          --     C_Detruire:=Cache;
           --    if Cache.all.Suivant_G=null then
             --       Cache:= Cache.all.Suivant_D;
            --   elsif Cache.all.Suivant_D=null then
              --      Cache:= Cache.all.Suivant_G;
          --     else
               --     declare
               --          Min:T_Cache_A ;
               --     begin
                  --       Decrocher_Min(Cache.all.Suivant_D,Min);
                 --        Min.all.Suivant_G := Cache.all.Suivant_G;
                   --      Min.all.Suivant_D := Cache.all.Suivant_D;
                   --      Cache := Min;
                 --   end;

             --  end if;

           --    Free(C_Detruire);

         -- end if;
     end Supprimer;

     -- Chercher l'interface correspondant au paquet dans le cache et lève une exception si il n'a pas trouvé. ## A corriger certaines fonctions buguent.
     procedure Chercher_Interface_A(Cache: in out T_Cache_A; paquet: in T_Adresse_IP; Interface_eth: out Unbounded_String) is
          Maxi: T_Cache_A;

     begin

          if Route_Presente(Cache,paquet) then
               Maxi:=max_masque_correspondant(Cache,paquet,Maxi);
          else
               raise Interface_Absente_Cache;
          end if;
          Interface_eth:=Maxi.all.Interface_eth;
     end Chercher_Interface_A;


     function max_masque_correspondant(Cache:in T_Cache_A;paquet: in T_Adresse_IP; Maxi: in T_Cache_A) return T_Cache_A is

     begin

          if Est_Vide(Cache) then
               return Maxi;
          elsif (Cache.all.Suivant_G=null and Cache.all.Suivant_D=null) then
               if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
                    if Cache.all.Masque > Maxi.all.Masque then
                         Maxi.all.Destination:=Cache.all.Destination;
                         Maxi.all.Masque:=Cache.all.Masque;
                         Maxi.all.Interface_eth:=Cache.all.Interface_eth;
                         if Route_Presente(Cache.all.Suivant_G,paquet)then
                              return max_masque_correspondant(Cache.all.Suivant_G,paquet,Maxi);
                         else
                              return max_masque_correspondant(Cache.all.Suivant_D,paquet,Maxi);
                         end if;

                    else
                         if Route_Presente(Cache.all.Suivant_G,paquet)then
                              return max_masque_correspondant(Cache.all.Suivant_G,paquet,Maxi);
                         else
                              return max_masque_correspondant(Cache.all.Suivant_D,paquet,Maxi);
                         end if;
                    end if;

               end if;
              return Maxi;
          end if;


end max_masque_correspondant;


     function Route_Presente(Cache:in T_Cache_A;paquet:in T_Adresse_IP) return Boolean is

     begin
          if Est_Vide(Cache) then
               return False;
          elsif (Cache.all.Suivant_D = null and Cache.all.Suivant_G = null) and then Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
               return True;
          else
               return Route_Presente(Cache.all.Suivant_G, paquet) or Route_Presente(Cache.all.Suivant_D, paquet);
          end if;


     end Route_Presente;



               --if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
               --     return Cache.all.Interface_eth;
               --else
              --      if IP_Presente(Cache.all.Suivant_G,paquet) then
              --           return Chercher_Interface_A(Cache.all.Suivant_G,paquet);
              --      else
              --           return Chercher_Interface_A(Cache.all.Suivant_D,paquet);
              --      end if;
              -- end if;
         -- else
          --     raise Interface_Absente_Cache;
         -- end if;
    -- end Chercher_Interface_A;

     -- VÃ©rifier si le cache est plein.
     function Cache_Plein(Cache:in T_Cache_A; Capacite_max:in Integer) return Boolean is
     begin
          return Nb_Element(Cache)=Capacite_max;
     end Cache_Plein;

     -- VÃ©rifie si on se trouve sur une feuille.
     function Est_Feuille(Cellule:in T_Cache_A) return Boolean is
     begin
          return Cellule.all.Suivant_D = null and Cellule.all.Suivant_D = null;
     end Est_Feuille;


     function Pere(Cache:in T_Cache_A; Feuille: in T_Adresse_IP) return T_Cache_A is
          Sous_Cache_D : T_Cache_A;
          Sous_Cache_G : T_Cache_A;
     begin
          Sous_Cache_D:=Cache.all.Suivant_D;
          Sous_Cache_G:=Cache.all.Suivant_G;
          if Est_Vide(Cache) then
               return null;
          else
               if (Sous_Cache_D.all.Destination or Sous_Cache_G.all.Destination ) = Feuille then
                    return Cache;
               else
                    if not(Est_Vide(Cache.all.Suivant_G)) then
                         return Pere(Cache.all.Suivant_G,Feuille);
                    else
                         return Pere(Cache.all.Suivant_D,Feuille);
                    end if;
               end if;
          end if;
     end Pere;


     function Nb_Fils(Pere: in T_Cache_A) return Integer is
          NbFils: Integer;
     begin

          NbFils:=0;
          if Pere.Suivant_D /=null then
               NbFils:=NbFils+1;
          elsif Pere.Suivant_G /=null then
               NbFils:=NbFils+1;
          end if;
          return NbFils;
     end Nb_Fils;

     procedure Afficher_A(Cache : in T_Cache_A) is
     begin
          if Cache = Null then
               Null;
          else
               if Cache.all.Suivant_D=null and Cache.all.Suivant_G=null then
                    Afficher_IP(Cache.All.Destination);
                    Put(" ");
                    Afficher_IP(Cache.All.Masque);
                    Put(" ");
                    Put_Line(To_String(Cache.All.Interface_eth));
               else
                    Afficher_A(Cache.All.Suivant_G);
                    Afficher_A(Cache.All.Suivant_D);
               end if;
          end if;
     end Afficher_A;

     procedure Afficher_B(Cache : in T_Cache_A) is
     begin
          if Cache = Null then
               Null;
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

     -- Affiche les différentes statistiques du cache.
     procedure Afficher_Stat_A(Cache: in T_Cache_A; Capacite_max:in Integer) is
          N: Integer;
     begin
          N:= Nb_Element(Cache);
          Put_Line("La poltique est LRU.");
          Put("Il y a");
          Put(N,2);
          Put_Line(" élements dans le cache.");
          Put("La capacité maximale du cache est ");
          Put(Capacite_max,1);
          Put_Line(".");
     end Afficher_Stat_A;


     -- Vide le cache.
     procedure Vider_A(Cache:in out T_Cache_A) is
     begin
          if Cache = null then
               null;
          else
               Vider_A(Cache.all.Suivant_G);
               Vider_A(Cache.all.Suivant_D);
               Free(Cache);
          end if;
     end Vider_A;


     --procedure MAJ_Cache(Cache: in out T_Cache_A; Capacite_max : in Integer; Politique: in T_Politique; Destination: in T_Adresse_IP;Masque: in T_Adresse_IP;Interface_eth: in Unbounded_String; paquet: in T_Adresse_IP) is
     --begin
     --   null;

     --end MAJ_Cache;


end Cache_A;