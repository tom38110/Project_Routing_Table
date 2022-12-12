generic



package Adresse_IP is

     type T_Adresse_IP is limited private;

     -- Convertir une ligne (string) en Adresse IP (binaire)
     function Conv_Ligne_IP (ligne: in string) return T_Adresse_IP;

     -- Convertir une Adresse IP (binaire) en ligne (string)
     function Conv_IP_ligne (IP: in T_Adresse_IP) return String;

end Adresse_IP;
