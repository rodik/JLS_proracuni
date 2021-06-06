# funkcije

procitaj_proracune_za_godinu <- function(godina, prva_kolona = 2, broj_kolona, prvi_red = 4, file_root = "data/modified_xlsx/") {

    # konstruiraj ime fjala
    file_name <- paste0(file_root, "jls_", as.character(godina), ".xlsx")
    # procitaj podatke za godinu
    proracuni <- read.xlsx(file_name, startRow = prvi_red, cols = c(prva_kolona:(broj_kolona+1))) %>% as_tibble() 
    # stariji fajlovi imaju kolonu viska, dodaj ju u nove fajlove
    if (broj_kolona == 15 && godina >= 2018) {
        proracuni <- proracuni %>% add_column(zajednicki_kapit_proj_otoci = as.double(NA), .before = 15)
    }
    # standardiziraj nazive kolona
    colnames(proracuni) <- c(
        'zupanija_id',
        'rbr',
        'naziv_jls',
        'ukupni_prihodi_i_primici',
        'visak_prihoda_i_primitaka_preneseni',
        'manjak_prihoda_i_primitaka_preneseni',
        'ukupni_proracun_za_godinu',
        'porez_na_dobitke_od_igara_na_srecu',
        'pomoci_iz_inozemstva_i_od_subjekata_unutar_opce_drzave',
        'prihodi_od_imovine',
        'prihodi_od_administrativnih_pristojbi_i_po_posebnim_propisima',
        'ostali_prihodi',
        'primici_od_financijske_imovine_i_zaduzivanja',
        'decentralizacija',
        'zajednicki_kapit_proj_otoci',
        'ukupni_proracun_umanjen_za_decentralizaciju_vlastite_i_namjenske_prihode_te_primitke_od_zaduzivanja'
    )
    # dodaj godinu kao kolonu
    proracuni <- proracuni %>% mutate(godina = godina)
    # makni prvi red ispod headera
    proracuni <- proracuni[2:nrow(proracuni),]
    # makni totale po zupanijama (ali zadrzi Zagreb jer je iznimka)
    proracuni <- proracuni %>% filter(!is.na(rbr) | zupanija_id == 21)
    # rangiraj zapise unutar zupanije kao grupe
    proracuni <- proracuni %>% 
        group_by(zupanija_id) %>%
        mutate(obrnuti_redoslijed = rank(desc(rbr))) %>%
        ungroup() 
    # izdvoji zupanije
    proracuni_zupanija <- proracuni %>% 
        filter(obrnuti_redoslijed == 1) %>% 
        select(-obrnuti_redoslijed) %>%
        mutate(vrsta_jedinice = "zup") %>%
        mutate(rbr = NA)
    # izdvoji gradove i opcine
    proracuni_grop <- proracuni %>% 
        filter(obrnuti_redoslijed > 1) %>% 
        select(-obrnuti_redoslijed) %>%
        mutate(vrsta_jedinice = "grop") 
    
    # vrati kao jedan dataset
    rbind(
        proracuni_grop,
        proracuni_zupanija
    )
}



