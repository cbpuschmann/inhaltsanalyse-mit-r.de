# Automatisierte Inhaltsanalyse mit R
#
# inhaltsanalyse_import_cosmas.R
# 
# Zeitungsartikel aus COSMAS (IDS Mannheim) einlesen, parsen und Korpus anlegen
# Korpus-Tool: https://cosmas2.ids-mannheim.de/cosmas2-web/
# (kostelose) Registrierung: https://www.ids-mannheim.de/cosmas2/projekt/registrierung/


# Installation und Laden der benötigten R-Bibliotheken
if(!require("quanteda")) {install.packages("quanteda"); library("quanteda")}
if(!require("tidyverse")) {install.packages("tidyverse"); library("tidyverse")}
if(!require("lubridate")) {install.packages("lubridate"); library("lubridate")}

import_cosmas <- function(path = "", pattern = "", verbose = FALSE)
{
  # Einlesen der Textdateien
  dateien <- dir(path = path, pattern = pattern)
  alle.beitraege <- character(0)
  alle.metadaten <- character(0)
  for (i in seq_along(dateien)) {
    if (verbose) print(dateien[i])
    daten <- scan(paste0(path, "/", dateien[i]), what = "char", sep = "\n", encoding = "latin1", blank.lines.skip = F, quiet = T)
    daten <- daten[last(str_which(daten, fixed("________________________________________________________________________________")))+2:length(daten)] # header entfernen
    leerzeilen <- which(str_length(daten) == 0)
    beitrag.anfang <- 1
    beitrag.ende <- leerzeilen[1]
    beitraege <- rep("", times = length(leerzeilen))
    metadaten <- rep("", times = length(leerzeilen))
    for (j in seq_along(beitraege)) {
      beitraege[j] <- str_flatten(daten[beitrag.anfang:beitrag.ende], " ")
      metadaten[j] <- last(unlist(str_extract_all(beitraege[j], "\\([^()]*\\)")))
      beitrag.anfang <- leerzeilen[j]+1
      beitrag.ende <- leerzeilen[j+1] # ist NA ein problem?
      if (verbose) print(j)
    }
    beitraege <- str_remove_all(beitraege, fixed(metadaten))
    alle.beitraege <- c(alle.beitraege, beitraege)
    alle.metadaten <- c(alle.metadaten, metadaten)
  }
  
  # Metadaten parsen und splitten
  alle.metadaten <- str_remove_all(alle.metadaten, "[\\(\\)]")
  alle.metadaten <- str_replace_all(alle.metadaten, "&amp;", "&")
  split1 <- str_split(alle.metadaten, " ", n = 2, simplify = T)
  split2 <- str_split(split1[,2], "[,;] ", n = 3, simplify = T)
  split3 <- str_split(split2[,3], "; ", n = 2, simplify = T)
  split4 <- str_split(split3[,1], ", ", n = 2, simplify = T)

  # Felder zuweisen
  id <- split1[,1]
  quelle <- split2[,1]
  datum <- dmy(str_sub(split2[,2], start = 1, end = 10), quiet = T)
  titel <- split3[,2]
  ressort <- split4[,2]
  seite <- split4[,1]
  monat <- str_sub(datum, start = 6, end = 7)
  jahr <- str_sub(datum, start = 1, end = 4)
  laenge <- str_count(alle.beitraege)
  
  # Korrekturen
  ohne.seitenzahl <- !str_detect(split3[,1], fixed("S. ")) & split3[,2] == ""
  titel[ohne.seitenzahl] <- split3[ohne.seitenzahl,1]
  ressort[ohne.seitenzahl] <- ""
  seite[ohne.seitenzahl] <- ""
  
  # Daten zusammenfassen und zurückgeben
  daten.df <- data.frame(text = alle.beitraege, id, quelle, datum, monat, jahr, seite, ressort, titel, laenge, stringsAsFactors = F)
  return(daten.df)
}