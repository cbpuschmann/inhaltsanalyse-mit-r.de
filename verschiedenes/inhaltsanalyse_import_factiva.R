# Automatisierte Inhaltsanalyse mit R
#
# import_factiva.R

# Installation und Laden der notwendigen Bibliotheken
if(!require("tm")) install.packages("tm")
if(!require("tm.plugin.factiva")) install.packages("tm.plugin.factiva")
library("quanteda")


# Daten importieren und parsen (mittels tm und tm.plugin.lexisnexis)
factiva.daten <- FactivaSource("daten/factiva/Factiva.html", format = "HTML")
factiva.tmcorpus <- Corpus(factiva.daten, readerControl = list(language = NA))

# ...funktioniert leider derzeit nicht
korpus.lexisnexis <- corpus(factiva.tmcorpus)
korpus.lexisnexis.stats <- summary(korpus.lexisnexis, n = 1000000)
korpus.lexisnexis
head(korpus.lexisnexis.stats)