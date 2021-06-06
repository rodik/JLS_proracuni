# main

# folder s proracunima po godinama - standardizirani nazivi fajlova
file_root <- "data/modified_xlsx/"
# izvuci sve godine za koje su dostupni podaci
godine <- list.files(file_root) %>% str_extract("\\d+") %>% unique() %>% sort() %>% as.integer()
# prikazi dostupne godine    
print(godine)

# procitaj sve
data_2016 <- procitaj_proracune_za_godinu(godina = 2016, prva_kolona = 2, broj_kolona = 16, prvi_red = 4, file_root)
data_2017 <- procitaj_proracune_za_godinu(godina = 2017, prva_kolona = 2, broj_kolona = 16, prvi_red = 4, file_root)
data_2018 <- procitaj_proracune_za_godinu(godina = 2018, prva_kolona = 2, broj_kolona = 15, prvi_red = 4, file_root)
data_2019 <- procitaj_proracune_za_godinu(godina = 2019, prva_kolona = 2, broj_kolona = 15, prvi_red = 4, file_root)
data_2020 <- procitaj_proracune_za_godinu(godina = 2020, prva_kolona = 2, broj_kolona = 15, prvi_red = 4, file_root)

# spoji sve
svi_proracuni <- rbind(
    data_2016,
    data_2017,
    data_2018,
    data_2019,
    data_2020
)

# baci oko
# View(svi_proracuni)s

# ucitaj sifrant
sifrant_grop <- ucitaj_sifrant_gradova_i_opcina()

# provjeri koje gradove i opcine ne mozemo spojiti prema nazivu
# svi_proracuni %>% anti_join(
#     sifrant_grop, by = c('zupanija_id'='zupanija_id', 'naziv_jls'='naziv')
# ) %>%
#     filter(vrsta_jedinice == 'grop') %>% select(zupanija_id, naziv_jls) %>% unique() %>% View()

# standardiziraj nazive da mozes spojiti na sifrant i povuci maticni broj (sifra_grop) gradova i opcina
svi_proracuni <- svi_proracuni %>% mutate(
    naziv_jls = case_when(
        naziv_jls == 'SVETA NEDJELJA' ~ "SVETA NEDELJA", 
        naziv_jls == 'NOVIGRAD.' ~ "NOVIGRAD", 
        naziv_jls == 'MURTER-KORNATI' ~ "MURTER - KORNATI", 
        naziv_jls == 'OTOK.' ~ "OTOK", 
        naziv_jls == 'PRIVLAKA.' ~ "PRIVLAKA", 
        naziv_jls == 'PRIVLAKA.' ~ "PRIVLAKA", 
        naziv_jls == 'BUJE' ~ "BUJE - BUIE", 
        naziv_jls == 'POREČ' ~ "POREČ - PARENZO", 
        naziv_jls == 'BALE' ~ "BALE - VALLE", 
        naziv_jls == 'UMAG' ~ "UMAG - UMAGO", 
        naziv_jls == 'VODNJAN' ~ "VODNJAN - DIGNANO", 
        naziv_jls == 'BRTONIGLA' ~ "BRTONIGLA - VERTENEGLIO", 
        naziv_jls == 'FAŽANA' ~ "FAŽANA - FASANA", 
        naziv_jls == 'FUNTANA' ~ "FUNTANA - FONTANE", 
        naziv_jls == 'GROŽNJAN' ~ "GROŽNJAN - GRISIGNANA", 
        naziv_jls == 'PULA' ~ "PULA - POLA", 
        naziv_jls == 'TAR-VABRIGA' ~ "TAR-VABRIGA - TORRE-ABREGA", 
        naziv_jls == 'ROVINJ' ~ "ROVINJ - ROVIGNO", 
        naziv_jls == 'OPRTALJ' ~ "OPRTALJ - PORTOLE", 
        naziv_jls == 'KAŠTELIR-LABINCI' ~ "KAŠTELIR-LABINCI - CASTELLIERE-S. DOMENICA", 
        naziv_jls == 'LIŽNJAN' ~ "LIŽNJAN - LISIGNANO", 
        naziv_jls == 'MOTOVUN' ~ "MOTOVUN - MONTONA", 
        naziv_jls == 'VIŠNJAN' ~ "VIŠNJAN - VISIGNANO", 
        naziv_jls == 'VRSAR' ~ "VRSAR - ORSERA", 
        naziv_jls == 'VIŽINADA' ~ "VIŽINADA - VISINADA", 
        naziv_jls == 'LJUBEŠČICA' ~ "LJUBEŠĆICA", 
        TRUE ~ naziv_jls # default
    )
)

# ispravi greske izvornim podacima 
svi_proracuni <- svi_proracuni %>% mutate(
    zupanija_id = if_else(zupanija_id == 5 & naziv_jls == 'BEDENICA', 1, zupanija_id)
)
svi_proracuni <- svi_proracuni %>% mutate(
    naziv_jls  = if_else(zupanija_id == 18 & naziv_jls == 'NOVIGRAD', 'NOVIGRAD - CITTANOVA', naziv_jls)
)

# spoji proracunske podatke na sifrant gradova i opcina
svi_proracuni <- svi_proracuni %>% left_join(
    sifrant_grop, 
    by = c('zupanija_id'='zupanija_id', 'naziv_jls'='naziv')
) 

# zupanije nije bilo moguce spojiti na sifrant gradova i opcina pa rucno doradi atribute za te zapise
svi_proracuni <- svi_proracuni %>% mutate(
    zupanija = if_else(is.na(rbr), naziv_jls, zupanija)
)

# dodatno uredi naziv zupanije
svi_proracuni <- svi_proracuni %>% mutate(
    zupanija = str_replace(zupanija, ' ŽUPANIJA', '')
) %>% mutate(
    zupanija = if_else(zupanija == 'ZAGREB', 'GRAD ZAGREB', zupanija)
) 

# jedinice je sada moguce spajati prema zupanija_id i maticni_broj atributima
svi_proracuni <- svi_proracuni %>% rename(maticni_broj = sifra_grop)

# pretvori maticni broj u string od 5 znakova s vodecim nulama
svi_proracuni <- svi_proracuni %>% mutate(
    maticni_broj = str_pad(maticni_broj, width = 5, side = 'left', pad = '0')
)

# pretvori proracunske iznose u numeric type
svi_proracuni$ukupni_proracun_za_godinu <- as.numeric(svi_proracuni$ukupni_proracun_za_godinu) 
svi_proracuni$ukupni_proracun_umanjen_za_decentralizaciju_vlastite_i_namjenske_prihode_te_primitke_od_zaduzivanja <- as.numeric(svi_proracuni$ukupni_proracun_umanjen_za_decentralizaciju_vlastite_i_namjenske_prihode_te_primitke_od_zaduzivanja) 

# provjeri
View(svi_proracuni)

# spremi kao RDS
svi_proracuni %>% saveRDS('export/proracuni_jls.RDS')
# spremi kao CSV
svi_proracuni %>% write.csv2('export/proracuni_jls.CSV', fileEncoding = 'windows-1250')
