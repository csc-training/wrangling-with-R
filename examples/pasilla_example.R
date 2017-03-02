library(dplyr)
library(tidyr)
library(ggplot2)

#importing:

#the phenodata is nice, i.e. can be imported with the wizard
#but the counts data has row names

pasilla <- read.table("data/pasilla_counts.tsv",header = TRUE,sep = "\t",
                      row.names=1)

#getting rid of row names:
pasilla <- mutate(pasilla,gene=row.names(pasilla))
row.names(pasilla) <- NULL

#tidying to 3 variables:
pasillat <- gather(pasilla,key = sample,value = count,
                  treated1fb:untreated4fb)

#how many zero counts?
zerocounts <- filter(pasillat,count==0)
#would have been annoying to figure out in the original format

#dropping unneeded columns from phenodata:
pheno <- select(pasilla_phenodata,sample,group,readtype)

#example of summarising by group
pasilla_g <- group_by(pasillat,sample)
summarise(pasilla_g,size=sum(count))

#to combine the info about treated / untreated and read type
pasillat <- left_join(pasillat,pheno)


# DESeq2 normalization:
# Take geometric mean of gene’s counts across all samples
# Divide gene’s counts in a sample by the geometric mean

pasilla_g <- group_by(pasillat,gene)
pasilla_g <- mutate(pasilla_g,geomm=exp(mean(log(count))),
                    countd=count/geomm,
                    is.ok=all(is.finite(countd)))
pasilla_g <- filter(pasilla_g,is.ok)

#Take median of these ratios -> 
#sample’s normalization factor (applied to read counts)
pasilla_g <- group_by(pasilla_g,sample)
pasilla_g <- mutate(pasilla_g,normfactor=median(countd))
