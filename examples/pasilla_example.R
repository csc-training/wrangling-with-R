## Pasilla RNA-seq -data example
# Modified 19.1.2018 ML

# In this example we are dealing with RNA-sequencing data. 
# We have two datasets: 
# 1) pasilla_counts.tsv = A huge table of RNA-molecule counts for different genes, for 7 samples
# 2) pasilla_phenodata.tsv = File explaining the experiment (how the samples were treated)

# We want to import this data to R, tidy it, and count some things: 
# 1) Total number of zero counts (in any sample, any gene)
# 2) Total number of counts for each sample (=the library size)
# 3) The (DESeq2) normalisation factor for each sample
#     (= geometric mean of gene’s counts across all samples, 
#     divide gene’s counts in a sample by the geometric mean,
#     take median of these ratios in the sample)

# Stepwise instructions:
# 1) Import the files (data/pasilla_phenodata.tsv and data/pasilla_counts.tsv)
# 2) Tidy the data:
#       -drop the excess columns of phenodata (you only need sample, group and readtype)
#       -get rid of rownames in the count file, add a column called "gene" to store this information
#       -make a "tidy" object of the counts, so that you have one row for each observation (hint: gather)
# 3) Count all the "zero" observations (=in how many cases there was no counts for a gene in a sample?) (hint: filter)
# 4) Count the total number of molecules counted per each sample (i.e. figure out the "library size" for each sample) (hint: group_by, summarise)
# 5) Combine all the information in one table (hint: left_join)
# 6) Count the normalisation factors for each sample (like they do in DESeq2 package):
#       -add new column with the geometric mean of genes counts in a sample 
#         (hint: organise the data by gene first, group_by) 
#         (hint2: there's no function for geometric mean, use for example this: exp(mean(log(count))))
#       -add new column with the gene's count divided by the geometric mean
#       -add one more column testing if the count column is NaN and filter the data based on that (hint: all(is.finite(countd))))
#       -take median of these ratios (hint: sort the data by sample first)


library(dplyr)
library(tidyr)
library(ggplot2)

# Importing:
# The phenodata is nice, i.e. can be imported with the wizard
# but the counts data has row names
# Phenodata file:
# Import using wizard, or:
pasilla_phenodata <- read_delim("data/pasilla_phenodata.tsv",
    "\t", escape_double = FALSE, trim_ws = TRUE)
# dropping unneeded columns from phenodata:
pheno <- select(pasilla_phenodata,sample,group,readtype)

# Count table:
pasilla <- read.table("data/pasilla_counts.tsv",header = TRUE,sep = "\t",
                      row.names=1)
# getting rid of row names:
pasilla <- mutate(pasilla,gene=row.names(pasilla))
row.names(pasilla) <- NULL
# tidying to 3 variables:
pasillat <- gather(pasilla,key = sample,value = count,
                  treated1fb:untreated4fb)

# How many zero counts?
zerocounts <- filter(pasillat,count==0)
dim(zerocounts)
# that would have been annoying to figure out in the original format


# How many counts in total for each sample?
# example of summarising by group
pasilla_g <- group_by(pasillat,sample)
summarise(pasilla_g,size=sum(count))

# Gather all the information in one table
# to combine the info about treated / untreated and read type:
pasillat <- left_join(pasillat, pheno)


# DESeq2 normalization:
# Take geometric mean of gene’s counts across all samples
# Divide gene’s counts in a sample by the geometric mean

pasilla_g <- group_by(pasillat,gene)
pasilla_g <- mutate(pasilla_g,geomm=exp(mean(log(count))),
                    countd=count/geomm,
                    is.ok=all(is.finite(countd)))
pasilla_g <- filter(pasilla_g,is.ok)

# Take median of these ratios -> 
# sample’s normalization factor (applied to read counts)
pasilla_g <- group_by(pasilla_g,sample)
pasilla_g <- mutate(pasilla_g,normfactor=median(countd))

tmp <- select(pasilla_g,normfactor,sample)
tmp <- ungroup(tmp)
tmp <- distinct(tmp)

