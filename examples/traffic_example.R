library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

#this is what the wizard gives you:
traffic <- read_delim("http://www.hel.fi/hel2/tietokeskus/data/helsinki/ksv/hki_liikennemaarat.csv",
                      ";", escape_double = FALSE, trim_ws = TRUE)
#which is nice, but encoding is wrong
guess_encoding("http://www.hel.fi/hel2/tietokeskus/data/helsinki/ksv/hki_liikennemaarat.csv")
#ISO-8859-1 is the one you want here
traffic <- read_delim("http://www.hel.fi/hel2/tietokeskus/data/helsinki/ksv/hki_liikennemaarat.csv",
                      ";", escape_double = FALSE, trim_ws = TRUE,
                      locale=locale(encoding="ISO-8859-1"))

#about locations, names, and directions:
locs <- select(traffic,piste:suunta) %>% distinct()
#the number is not even, so that alone tells me that
#not every place has 2 directions

tmp <- locs %>% group_by(nimi) %>% summarise(n=n()) 
#54 names in total, some have 4 rows in the locs data?? one has a single one

#so take only those with something else than two rows, and join them back with their
#other info
tmp <- tmp %>% filter(n!=2) %>% left_join(locs)

#it would appear some distinct locations share a name. So name is not a defining
#label here. How about location codes then, do they match a coordinate point exactly?

locs %>% select(piste,x_gk25,y_gk25) %>% distinct() %>% nrow()
locs %>% select(piste) %>% distinct() %>% nrow()

#ok, wonderful. 57 locations with a distinct location code , each with only one pair of
#coordinates

#about location codes
#First separate the letter code and the number code
loccodes <- traffic %>%
  select(piste,x_gk25,y_gk25) %>%
  distinct() %>%
  separate(piste,c("code","subcode"),1,remove=FALSE)
  
#Plot them
ggplot(loccodes,aes(x_gk25,y_gk25,col=code))+
  geom_text(aes(label=subcode))
#Whee! Suddenly I understand the description!

#are trams included in the "autot"? 
tmp <- traffic %>% select(piste,suunta,aika,vuosi,ha:rv) %>% 
  gather(key = vehicle,value=N,ha:rv) %>% 
  group_by(piste,suunta,aika,vuosi) %>%
  summarise(vehicleN=sum(N)) %>% 
  left_join(traffic %>% select(piste,suunta,aika,vuosi,autot) %>% 
              distinct()) %>% 
  filter(autot!=vehicleN)
  
#doesn't seem so. Is it then just the others? Easy to copy-paste the whole thing
#from above and re-run from start, just don't select the rv column... 
#or I could just add one filter in between. For clarity, I'll copy-paste anyway

tmp <- traffic %>% select(piste,suunta,aika,vuosi,ha:rv) %>% 
  gather(key = vehicle,value=N,ha:rv) %>% 
  group_by(piste,suunta,aika,vuosi) %>%
  #try1:
  #filter(vehicle!="rv") %>% 
  #try2:
  filter(!vehicle%in%c("rv","mp")) %>% 
  #try3:
  #filter(!vehicle%in%c("rv","mp"),piste!="C18") %>% 
  summarise(vehicleN=sum(N)) %>% 
  left_join(traffic %>% select(piste,suunta,aika,vuosi,autot) %>% 
              distinct()) %>% 
  filter(autot!=vehicleN)

#Ooops? I expected to get no rows! Ah. Motorcycles. After motorcycles... still no.
#What is going on in that weird place with only one direction? Will my idea work if
#I take it out? Yes, finally no rows.

#But now I have another question, what's the deal with C18?
C18 <- traffic %>% filter(piste=="C18")
#E.g. at time 000 in year 2011 there clearly were a total of 17 cars.. why am I getting
#33 then? That could happen if there were more than one observation matching to that time!

C18 %>% group_by(aika,vuosi) %>% summarise(timen=n())
#and there we have it. it's not that there's just one direction. The info about direction 
#is missing! Should have maybe realised this earlier

