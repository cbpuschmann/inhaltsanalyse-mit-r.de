# Automatisierte Inhaltsanalyse mit R
#
# import_ropensci.R
# 
# wissenschaftliche Artikel/Daten/Metadaten durch die Paket-Familie 'RopenSci' extrahieren (hier mit dem Paket 'fulltext')
# Details: https://cran.rstudio.com/web/packages/GuardianR/index.html
# API: http://open-platform.theguardian.com/access/

# Installation und Laden der notwendigen Bibliotheken
if(!require("GuardianR")) install.packages("GuardianR")
library("GuardianR")

# Daten von der The Guardian API abrufen (hier Beiträge zum IS aus 2014)
guardian.daten <- get_guardian("islamic+state", section = "world", from.date = "2014-09-16", to.date = "2014-09-16", api.key = "3xzg2fk53jcdgaj5tbwqqhcz")