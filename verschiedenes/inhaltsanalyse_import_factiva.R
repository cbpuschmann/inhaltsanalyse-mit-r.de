# Automatisierte Inhaltsanalyse mit R
#
# import_factiva.R

# Installation und Laden der notwendigen Bibliotheken
if(!require("tm")) install.packages("tm")
if(!require("tm.plugin.factiva")) install.packages("tm.plugin.factiva")
library("quanteda")


# Daten importieren und parsen (mittels tm und tm.plugin.lexisnexis)
factiva.daten <- tm.plugin.factiva::FactivaSource("daten/factiva/Factiva01.htm", format = "HTML")
factiva.tmcorpus <- tm::Corpus(factiva.daten, readerControl = list(language = NA))

# ...funktioniert leider derzeit nicht
