# Automatisierte Inhaltsanalyse mit R
#
# inhaltsanalyse_import_cosmas.R
# 
# Zeitungsartikel aus COSMAS (IDS Mannheim) einlesen, parsen und Korpus anlegen
# Korpus-Tool: https://cosmas2.ids-mannheim.de/cosmas2-web/
# (kostelose) Registrierung: https://www.ids-mannheim.de/cosmas2/projekt/registrierung/

# DATEN EINLESEN OHNE LOOP, METADATEN PARSEN MIT LOOP!

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
    if (verbose) message("Reading in file ", dateien[i])
    daten <- scan(paste0(path, "/", dateien[i]), what = "char", sep = "\n", encoding = "latin1", blank.lines.skip = F, quiet = T)
    daten <- daten[last(str_which(daten, fixed("________________________________________________________________________________")))+2:length(daten)] # header entfernen
    leerzeilen <- which(str_length(daten) == 0)
    beitrag.anfang <- 1
    beitrag.ende <- leerzeilen[1]
    beitraege <- rep("", times = length(leerzeilen))
    metadaten <- rep("", times = length(leerzeilen))
    if (verbose) message("Done.")
    for (j in seq_along(beitraege)) {
      if (verbose) message("Extracting news item # ", j)
      beitraege[j] <- str_flatten(daten[beitrag.anfang:beitrag.ende], " ")
      metadaten[j] <- last(unlist(str_extract_all(beitraege[j], "\\([^()]*\\)")))
      beitrag.anfang <- leerzeilen[j]+1
      beitrag.ende <- leerzeilen[j+1] # ist NA ein problem?
      if (verbose) message("Done.")
    }
    beitraege <- str_remove_all(beitraege, fixed(metadaten))
    alle.beitraege <- c(alle.beitraege, beitraege)
    alle.metadaten <- c(alle.metadaten, metadaten)
  }
  
  # Metadaten parsen und splitten
  lmeta <- length(alle.metadaten)
  id <- rep("", lmeta)
  quelle <- rep("", lmeta)
  datum <- rep(dmy("01.01.1900"), lmeta)
  titel <- rep("", lmeta)
  ressort <- rep("", lmeta)
  seite <- rep("", lmeta)
  monat <- rep("", lmeta)
  jahr <- rep("", lmeta)
  laenge <- rep("", lmeta)
  for (k in seq_along(alle.metadaten)) {
    if (verbose) message("Extracting metadata for news item # ", k)
    metadaten <- str_remove_all(alle.metadaten[k], "[\\(\\)]") %>% str_replace_all("&amp;", "&")
    split1 <- str_split(metadaten, " ", n = 2, simplify = T)
    split2 <- str_split(split1[,2], "[,;] ", n = 3, simplify = T)
    if (str_detect(split2[,3], pattern = "\\[S\\. [0-9]+\\]$")) {
      alternative.notation <- TRUE
      if (str_detect(split2[,3], pattern = fixed("Ressort:"))) {
        hat.ressort <- TRUE
        split3 <- str_split(split2[,3], "; ", n = 2, simplify = T)
      } else { hat.ressort <- FALSE }
    } else {
      alternative.notation <- FALSE
      split3 <- str_split(split2[,3], "; ", n = 2, simplify = T)
      split4 <- str_split(split3[,1], ", ", n = 2, simplify = T)
    }
  
    # Felder zuweisen
    id[k] <- split1[,1]
    quelle[k] <- split2[,1]
    datum[k] <- dmy(str_sub(split2[,2], start = 1, end = 10), quiet = T)
    if (alternative.notation) {
      if (hat.ressort) {
        titel[k] <- str_remove(split3[,2], pattern = "\\[(S\\. [0-9]+)\\]$") %>% str_trim()
        ressort[k] <- split3[,1]
      } else {
        titel[k] <- str_remove(split2[,3], pattern = "\\[(S\\. [0-9]+)\\]$") %>% str_trim()
      }
    seite[k] <- str_extract(split2[,3], pattern = "S\\. [0-9]+")
    } else {
      titel[k] <- split3[,2]
      ressort[k] <- split4[,2]
      seite[k] <- split4[,1]
    }
    monat[k] <- str_sub(datum[k], start = 6, end = 7)
    jahr[k] <- str_sub(datum[k], start = 1, end = 4)
    laenge[k] <- str_count(alle.beitraege[k])
    
    if (verbose) message("Done.")
  }
  
  # Daten zusammenfassen und zurückgeben
  daten.df <- data.frame(text = alle.beitraege, id, quelle, datum, monat, jahr, seite, ressort, titel, laenge, stringsAsFactors = F) %>% 
    filter(str_length(id) == 13) %>% 
    unique()
  if (verbose) message("All done.")
  return(daten.df)
}

# Creat a quanteda corpus
#korpus <- corpus(daten, docid_field = "id", text_field = "text")
#korpus.stats <- summary(korpus, n = 100000)
#save(korpus, korpus.stats, file = "spiegel-zeit-korpus.RData")


