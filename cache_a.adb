with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Integer_Text_IO;     use Ada.Integer_Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;

package body Cache_A is

    -- Initialisation du cache.
    procedure Initialiser(Cache: out T_Cache_A) is
    begin
        Cache:=null;
    end Initialiser;
            
    -- Vérifier si le cache est vide.
    function Est_Vide (Cache: in T_Cache_A) return Boolean is
    begin
        return Cache=null;
    end Est_Vide;

    -- Ajouter une cellule au cache. ## (Ã  tester pour voir si ca fonctionne + amÃ©liorer afin de gerer jusqu'Ã  la premiÃ¨re diffÃ©rence pour les prÃ©fixes).
    procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface: in Unbounded_String) is
        Dest_Copie: T_Adresse_IP;
    begin
        Dest_Copie:=Destination;
        if Est_Vide(Cache) then
            Cache:= new T_Cellule'(Destination,Masque,Interface,null,null);
        else
            if (Dest_Copie and POIDS_FORT) /=0 then
                if not(Est_Feuille(Cache)) then
                    Ajouter_C(cache.all.Suivant_D,null,null,null);
                    Dest_Copie := Dest_Copie*2;
                else

                    --cache.all.Suivant_D:=Noeud(null,null,null);
                    --Ajouter_C(cache.all.Suivant_D,Destination,Masque,Interface);                 
                end if;        
            else
                if not(Est_Feuille(Cache)) then
                    Ajouter_C(cache.all.Suivant_G,null,null,null);
                    Dest_Copie := Dest_Copie*2;
                else
                    cache.all.Suivant_G:=Noeud(null,null,null);
                    Ajouter_C(cache.all.Suivant_G,Destination,Masque,Interface);
                end if;
            end if;

                            -- SUREMENT RAJOUTER QQCHOSE
        end if;
    end Ajouter_C;

    -- Classer les prÃ©fixes selon leur poids.
    procedure Classer_Pre(Tableau: in out T_tab) is
        Temp : constant Integer;
    begin
        for i in 1..CAPACITE loop
            for j in 1..CAPACITE loop
                if (Tableau(i) < Tableau(j)) then
                    Temp := Tableau(i);
                    Tableau(i) := Tableau(j);
                    Tableau(j) := Temp;
                end if;
            end loop;
        end loop;
    end Classer_Pre;    

    -- Donne la taille du cache. (Attention condition feuille)
    function Nb_Element(Cache:in T_Cache_A) return Integer is
    begin
        if Cache = null then
            return 0;
        else 
            return 1+ Nb_Element(Cache.all.Suivant_D) + Nb_Element(Cache.all.Suivant_G);
        end if;
    end Nb_Element;

    -- Savoir si l'Adresse IP est prÃ©sente dans un cache.
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
    procedure Supprimer(Cache:in out T_Cache_A; Destination: in T_Adresse_IP) is
        Paternel: T_Cellule;
    begin
        Paternel:=Pere(Cache,Destination);
        if Est_Vide(Cache) then
            Null;
        else
            if Nb_Fils(Paternel)=1 then
                if Cache.all.Destination = Destination then
                    Free (Cache);
                    Free(Paternel);
                else
                    Supprimer(Cache.all.Suivant_D,Destination);
                    Supprimer(Cache.all.Suivant_G,Destination);
                end if;
            elsif Nb_Fils(Paternel)=2 then
                if Cache.all.Destination = Destination then
                    Free (Cache);
                else
                    Supprimer(Cache.all.Suivant_D,Destination);
                    Supprimer(Cache.all.Suivant_G,Destination);
                end if;
            end if;
        end if;
    end Supprimer;

    -- Chercher l'interface correspondant au paquet dans le cache et lÃ¨ve une exception si il n'a pas trouvÃ©. ## (Ã  corriger pas ok pour la recursivitÃ©)
    function Chercher_Interface_A(Cache: in T_Cache_A; paquet: in T_Adresse_IP) return Unbounded_String is
    begin
        if IP_Presente(Cache,paquet) then
            if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
                return Cache.all.Interface;
            else
                return Chercher(Cache.all.Suivant_D,paquet) or Chercher(Cache.all.Suivant_G,paquet);
            end if;
        end if;
    end Chercher;

    -- Comparer le prÃ©fixe aux feuilles.
    function Comparer(prefixe:in T_Adresse_IP; feuille:in T_Cache_A) return Boolean is
    begin 
        return prefixe = feuille.all.Destination ;
    end Comparer;


    -- VÃ©rifier si le cache est plein.
    function Cache_Plein(Cache:in T_Cache_A; Capacite_max:in Integer) return Boolean is
    begin
        return Nb_Element(Cache)=Capacite_max;
    end Cache_Plein;

    -- crÃ©er un noeud avec la destination, le masque et l'interface souhaitÃ©e.
    function Noeud(Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface: in Unbounded_String) return T_Cellule is
        Noeud_v: T_Cellule;
    begin 
        Noeud_v:= new T_Cellule'(Destination,Masque,Interface,null,null);
        return Noeud_v;
    end Noeud;

    -- VÃ©rifie si on se trouve sur une feuille.
    function Est_Feuille(Cellule :in T_Cache_A) return Boolean is
    begin
        return Cellule.all.Suivant_D = null and Celulle.all.Suivant_D = null;
    end Est_Feuille;

    -- Renvoie le pÃ¨re de la feuille souhaitÃ©. (gérer si le cache est nul)
    function Pere(Cache:in T_Cache_A; Feuille: in T_Adresse_IP) return T_Cellule is
        Sous_Cache_D : T_Cache_A;
        Sous_Cache_G : T_Cache_A;
    begin
        Sous_Cache_D:=Cache.all.Suivant_D;
        Sous_Cache_G:=Cache.all.Suivant_G;
        if Est_Vide(Cache) then
            null;
        else
            if (Sous_Cache_D.all.Destination or Sous_Cache_G.all.Destination ) = Feuille then
                return Cache;
            else 
                return (Pere(Cache.all.Suivant_D,Feuille) or Pere(Cache.all.Suivant_G,Feuille));
            end if;
        end if;
    end Pere;

    -- Renvoie le nombre de fils d'un PÃ¨re.
    function Nb_Fils(Pere: in T_Cellule) return Integer is
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
                Afficher_IP(Cache.All.Destination);
                Put(" ");
                Afficher_IP(Cache.All.Masque);
                Put(" ");
                Put_Line(To_String(Cache.All.Interface));
                Afficher_A(Cache.All.Suivant_D);
                Afficher_A(Cache.All.Suivant_G);
        end if;
    end Afficher_A;

    -- Affiche les différentes statistiques du cache.
    procedure Afficher_Stat_A(Cache: in T_Cache_A; Capacite_max:in Integer) is 
        N: Integer;
    begin
        N:= Nb_Element(Cache);
        Put_Line("La poltique est LRU.");
        Put("Il y a ");
        Put(N,1)
        Put_Line("élements dans le cache.");
        Put("La Capacité maximale du cache est ");
        Put(Capacite_max);
        Put_Line(".");
    end Afficher_Stat_A;

    -- Renvoie la destination du cache qui a Ã©tÃ© utilisÃ©e le moins rÃ©cemment.
    function Plus_Ancien(Tableau: in T_tab) return T_Adresse_IP is
        i:Integer;
    begin
        i:=0;
        if Tableau(i+1).Destination /= null then
            i:=i+1;
        else
            return Tableau(i).Destination;
        end if;

    end Plus_Ancien;

    -- Renvoie l'indice de destination dont le masque est le plus grand.
    function Masque_Max(Tableau:in T_tab) return Integer is
        max:T_Adresse_IP;
        i:Integer;
        ind:Integer;
    begin 
        ind:=1;
        i:=1;
        max:= Tableau(1).Masque;
        while Tableau(i+1).Destination /= null loop
            i:=i+1;
            if Tableau(i).Masque > max then
                max:=Tableau(i).Masque;
                ind:=i;
            end if;
        end loop;
    return ind;

end Masque_Max;

-- Vide totalement le cache.
-- copier le code supprimer du TD oklmus bingus

procedure MAJ_Cache(Cache: in out T_Cache_A; Capacite_max : in Integer; Politique: in T_Politique; Destination: in T_Adresse_IP,Masque: in T_Adresse_IP,Interface: in Unbounded_String; paquet: in T_Adresse_IP) is
begin 
end MAJ_Cache;

-- faire une procÃ©dure MAJ_Cache(Cache: in out T_Cache_A; Capacite_max : in Integer; Politique: in T_Politique; 
-- Destination: in T_Adresse_IP,Masque: in T_Adresse_IP,Interface: in Unbounded_String; paquet: in T_Adresse_IP)
-- Afficher_A
-- Afficher_Stat_A
-- Vider_A