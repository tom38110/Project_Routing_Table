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
function Est_Vide (Cache: T_Cache_A) return Boolean is
begin
    return Cache:=null;
end Est_Vide;

-- Ajouter une cellule au cache.
procedure Ajouter_C(Cache: in out T_Cache_A; Destination: in T_Adresse_IP; Masque: in T_Adresse_IP; Interface: in Unbounded_String) is
begin
    if Est_Vide(Cache) then
        Cache:= new T_Cellule'(Destination,Masque,Interface,null,null);
    elsif Cache.all.Destination < Destination then
        Ajouter_C(Cache.all.Suivant_D,Destination,Masque,Interface);
    elsif Cache.all.Destination > Destination then
        Ajouter_C(Cache.all.Suivant_G,Destination,Masque,Interface);
    else
        Cache.all.Destination:=Destination;
        Cache.all.Masque:=Masque;
        Cache.all.Interface:=Interface;
    end if;
end Ajouter_C;

-- Classer les préfixes selon leur poids.
procedure Classer_Pre(T: in out T_tab) is
    Temp : constant Integer;
begin
    for i in 1..CAPACITE loop
        for j in 1..CAPACITE loop
            if (T(i) < T(j)) then
                Temp := T(i);
                T(i) := T(j);
                T(j) := Temp;
            end if;
        end loop;
    end loop;
end Classer_Pre;    

-- Donne la taille du cache.
function Nb_Element(Cache:in T_Cache_A) return Integer is
begin
    if Cache = null then
        return 0;
    else 
        return 1+ Nb_Element(Cache.all.Suivant_D) + Nb_Element(Cache.all.Suivant_G);
    end if;
end Nb_Element;

-- Savoir si l'Adresse IP est présente dans un cache.
function IP_Presente(Cache:in T_Cache_A; paquet: in T_Adresse_IP) return Boolean is
begin
    if Cache = null;
        return False;
    else
        if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
            return True;
        else
            return IP_Presente(Cache.all.Suivant_D,paquet) or IP_Presente(Cache.all.Suivant_G,paquet);
        end if;
    end if;
end IP_Presente;

-- Decrocher le plus petit élement du Cache.
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

-- Supprimer une ligne du cache en resectant la politique LRU.
procedure Supprimer(Cache:in out T_Cache_A,Destination: in T_Adresse_IP);
    C_Detruire:T_Cache_A;
begin
    if Cache= null then
        raise Exception_ERROR;
    elsif Cache.all.Destination < Destination then
        Supprimer(Cache.all.Suivant_D, Destination);
    elsif Cache.all.Destination > Destination then
        Supprimer(Cache.all.Suivant_G,Destination);
    else
        C_Detruire:=Cache;
        if Cache.all.Suivant_G=null then
            Cache:= Cache.all.Suivant_D;
        elsif Cache.all.Suivant_D=null then
            Cache:= Cache.all.Suivant_G;
        else
            declare
                Min:T_Cache_A ;
            begin
                Decrocher_Min(Cache.all.Suivant_D,Min);
                Min.all.Suivant_G := Cache.all.Suivant_G;
                Min.all.Suivant_D := Cache.all.Suivant_D;
                Cache := Min;
            end;
        
        end if;
    
    Free(C_Detruire);
    
    end if;
end Supprimer;

-- Chercher l'interface correspondant au paquet dans le cache et lève une exception si il n'a pas trouvé.(à corriger pas ok pour la recursivité)
function Chercher(Cache: in T_Cache_A; paquet: in T_Adresse_IP) return Unbounded_String is
begin
    if IP_Presente(Cache,paquet) then
        if Comp_Destination_Paquet(Cache.all.Destination, Cache.all.Masque, paquet) then
            return Cache.all.Interface;
        else
            return Chercher(Cache.all.Suivant_D,paquet) or IP_Presente(Cache.all.Suivant_G,paquet);
        end if;
    end if;
end Chercher;

-- Comparer le préfixe aux feuilles.
function Comparer(prefixe:in T_Adresse_IP; feuille:in T_Adresse_IP) return Boolean;
begin 
    return prefixe = feuille.all.Destination ;
end Comparer;


-- Vérifier si le cache est plein.
function Cache_Plein(Cache:in T_Cache_A; Capacite_max:in Integer) return Boolean;
begin
    return Nb_Element(Cache)=Capacite_max;
end Cache_Plein;

-- faire une procédure MAJ_Cache(Cache: in out T_Cache_A; Capacite_max : in Integer; Politique: in T_Politique;
-- Destination: in T_Adresse_IP,Masque: in T_Adresse_IP,Interface: in Unbounded_String; paquet: in T_Adresse_IP)

