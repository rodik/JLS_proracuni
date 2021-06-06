# plot 
ggthemr('pale')

svi_proracuni %>% 
    filter(vrsta_jedinice == 'zup') %>% 
    mutate(godina = as.character(godina)) %>% 
    ggplot(aes(x = godina, y = ukupni_proracun_za_godinu))  +
    geom_bar(stat = 'identity', position = position_dodge()) +
    scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6), name = 'Ukupni proračun za godinu') +
    facet_wrap(vars(naziv_jls), scales = 'free_x', ncol = 3) +
    coord_flip()
    

