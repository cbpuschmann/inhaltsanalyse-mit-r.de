# Automatisierte Inhaltsanalyse mit R
#
# import_ropensci.R
# 
# wissenschaftliche Artikel/Daten/Metadaten durch die Paket-Familie 'RopenSci' extrahieren (hier mit dem Paket 'fulltext')
# Details: https://github.com/ropensci/fulltext

# Installation und Laden der notwendigen Bibliotheken
if(!require("fulltext")) install.packages("fulltext")
library("fulltext")

# Volltextsuche in arXiv nach Papers mit dem Stichwort "Twitter"
twitterpapers <- ft_search(query = "twitter", from = "arxiv", limit = 1500)
#climatechange <- ft_search(query = "climate", from = "plos")

# Reformatierung der Daten
twitterabstracts <- data.frame(submitted = twitterpapers$arxiv$data$submitted, title = twitterpapers$arxiv$data$title, abstract = twitterpapers$arxiv$data$abstract)
head(twitterabstracts)


# Wie viele Artikel wurden zu Twitter auf arXiv veröffentlicht?
library("lubridate")
twitterabstracts$submitted <- ymd_hms(twitterabstracts$submitted)
twitterabstracts$title <- as.character(twitterabstracts$title)
twitterabstracts$abstract <- as.character(twitterabstracts$abstract)
plot(twitterabstracts$submitted, 1:nrow(twitterabstracts), xlab = "Jahr", ylab = "Artikel", main = "Artikel in arXiv zu Twitter")
