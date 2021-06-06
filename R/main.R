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
View(svi_proracuni)
