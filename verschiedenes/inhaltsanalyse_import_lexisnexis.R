# Automatisierte Inhaltsanalyse mit R
#
# import_lexisnexis.R
#
# 

# Installation und Laden der notwendigen Bibliotheken
if(!require("tm")) install.packages("tm")
if(!require("tm.plugin.lexisnexis")) install.packages("tm.plugin.lexisnexis")


# Daten importieren und parsen (mittels tm und tm.plugin.lexisnexis)
lexisnexis.daten <- tm.plugin.lexisnexis::LexisNexisSource("daten/lexisnexis/Nachrichten2018-03-05_13-35.HTML")
lexisnexis.tmcorpus <- tm::Corpus(lexisnexis.daten, readerControl = list(language = NA))

# Daten in quanteda-Korpus umwandeln
library("quanteda")
korpus <- corpus(lexisnexis.tmcorpus)
korpus.stats <- summary(korpus, n = 100000)

korpus
head(korpus.stats)
