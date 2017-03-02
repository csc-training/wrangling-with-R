library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

#this is what the wizard gives you:
traffic <- read_delim("data/hki_liikennemaarat.csv",
                      ";", escape_double = FALSE, trim_ws = TRUE)
#which is nice, but encoding is wrong
guess_encoding("data/hki_liikennemaarat.csv")
#ISO-8859-1 is the one you want here
traffic <- read_delim("data/hki_liikennemaarat.csv",
                      ";", escape_double = FALSE, trim_ws = TRUE,
                      locale=locale(encoding="ISO-8859-1"))

#about locations, names, and directions
locs <- select(traffic,piste:suunta) %>% unique()
tmp <- summarise(group_by(locs,nimi),n=n())
tmp <- locs %>% group_by(nimi) %>% summarise(n=n()) 
tmp <- tmp %>% filter(n!=2) %>% left_join(locs)

#about location codes
loccodes <- traffic %>%
  select(piste,x_gk25,y_gk25) %>%
  distinct() %>%
  separate(piste,c("code","subcode"),1,remove=FALSE)
  
ggplot(loccodes,aes(x_gk25,y_gk25,col=code))+
  geom_text(aes(label=subcode))

ttraffic <- select(traffic,piste,suunta,aika,vuosi,ha:rv) %>% 
  gather(key = vtype,value=N,ha:rv) %>%
  separate(piste,c("code","subcode"),1,remove=FALSE)

tmp <- ttraffic %>% 
  filter(vtype%in%c("ha","la"),code=="F") %>% 
  select(subcode,vuosi,vtype,N) %>%
  group_by(subcode,vuosi,vtype) %>%
  summarise_all(sum) %>%
  spread(vtype,N) %>%
  mutate(pubratio=ha/la)

  ggplot(tmp,aes(vuosi,pubratio,col=subcode))+geom_line()
