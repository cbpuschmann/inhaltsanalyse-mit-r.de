# Automatisierte Inhaltsanalyse mit R
#
# import_cosmas.R
# 
# Zeitungsartikel aus COSMAS (IDS Mannheim) einlesen und parsen
# Korpus-Tool: https://cosmas2.ids-mannheim.de/cosmas2-web/
# (kostelose) Registierung: https://www.ids-mannheim.de/cosmas2/projekt/registrierung/

# Installation und Laden der notwendigen Bibliotheken
if(!require("stringr")) install.packages("stringr")
if(!require("lubridate")) install.packages("lubridate")
if(!require("dplyr")) install.packages("dplyr")
if(!require("ggplot2")) install.packages("ggplot2")
if(!require("quanteda")) install.packages("quanteda")


# Daten aus dem COSMAS-Export einlesen
# Anmerkungen: ersten 20 Zeilen sind Metadaten, Beiträge werden durch Leerzeilen getrennt, Encoding ist ASCII (latin1) 
dateien <- dir("daten/cosmas/", pattern = ".TXT")
daten <- character(0)
for (i in seq_along(dateien))
  daten <- c(daten, scan(file = paste("daten/cosmas/", dateien[i], sep = ""), what = "char", sep = "\n", encoding = "latin1", skip = 20, blank.lines.skip = F))
# seitenzahlen werden u.U. nicht richtig erkannt -- ggf lieber bei semikolon trennen 
muster <- "(\\((BAZ|BEZ|BUN|A97|NZZ|NLZ|E01)[0-9]{2}/(JAN|FEB|MAR|APR|MAI|JUN|JUL|AUG|SEP|OKT|NOV|DEZ)\\.[0-9]{5} (Basler Zeitung|Berner Zeitung|Der Bund|St. Galler Tagblatt|Neue Zürcher Zeitung|Neue Luzerner Zeitung|Tagesanzeiger), [0-9]{2}\\.[0-9]{2}\\.[0-9]{4}(, S\\.\\s?([0-9-,]{1,6})?)?(lzhp|nzhp|zzhp|uzhp|szhp|lzv2|a|b|c|d|e)?; (.*)+\\))"
artikel <- which(str_detect(daten, muster)); ac <- length(artikel)
metadaten <- str_extract(daten[artikel], muster)
metadaten.id <- str_extract(metadaten, "(BAZ|BEZ|BUN|A97|NZZ|NLZ|E01)[0-9]{2}/(JAN|FEB|MAR|APR|MAI|JUN|JUL|AUG|SEP|OKT|NOV|DEZ)\\.[0-9]{5}")
metadaten.quelle <- str_extract(metadaten, "(Basler Zeitung|Berner Zeitung|Der Bund|St. Galler Tagblatt|Neue Zürcher Zeitung|Neue Luzerner Zeitung|Tagesanzeiger)")
metadaten.datum <- dmy(str_extract(metadaten, "[0-9]{2}\\.[0-9]{2}\\.[0-9]{4}"))
metadaten.seite <- str_sub(str_extract(metadaten, "S\\. [0-9]{1,3}"), start = 4)
metadaten.titel <- str_sub(str_extract(metadaten, ";(.*)+\\)"), start = 3, end = -2)

# Parsen der Daten
daten.df <- data.frame(text = character(ac), id = metadaten.id, quelle = metadaten.quelle, datum = metadaten.datum, seite = metadaten.seite, titel = metadaten.titel, row.names = 1:ac, stringsAsFactors = F)
for (i in seq_along(artikel))
{
  if (!exists("parse_start")|i == 1) parse_start <- 1
  else parse_start <- artikel[i-1] + 2
  parse_stop <- artikel[i]
  artikel_text <- paste(daten[parse_start:parse_stop], collapse = " ")
  daten.df$text[i] <- str_replace(artikel_text, muster, "")
}
jahr <- str_sub(daten.df$datum, start = 1, end = 4)
monat <- str_sub(daten.df$datum, start = 6, end = 7)
daten.df <- data.frame(daten.df, jahr, monat, stringsAsFactors = F)

# Aufräumen
rm(ac, artikel, artikel_text, i, metadaten, metadaten.datum, metadaten.id, metadaten.quelle, metadaten.seite, metadaten.titel, muster, parse_start, parse_stop, jahr, monat)
rm(dateien, daten)


# ggplot theme-Einstellung
theme_set(theme_bw())

# Plotten der Aktivität
aktivitaet <- daten.df %>% filter(datum >= "2006-07-01") %>% mutate(date.print = ymd(format(datum, "%Y-%m-01"))) %>% group_by(quelle, jahr, monat, date.print) %>% summarise(total = n())
ggplot(aktivitaet, aes(date.print, total, group = quelle, col = quelle)) + geom_line(size = 1) + scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") + ggtitle("Artikel zur Finanzkrise in Schweizer Tageszeitungen") + xlab("Monat") + ylab("Artikel") + theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Vorbereiten des Korpus
korpus <- corpus(daten.df, docid_field = "id", text_field = "text")
korpus.stats <- summary(korpus, n = 100000)
