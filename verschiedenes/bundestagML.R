# libraries
if(!require("quanteda")) install.packages("quanteda")
if(!require("tidyverse")) install.packages("tidyverse")
if(!require("RTextTools")) install.packages("RTextTools")
#if(!require("gridExtra")) install.packages("gridExtra")
#if(!require("urltools")) install.packages("urltools")
theme_set(theme_bw())


# vorbereitung

# first remove texts with Tokens < 100 via corpus_subset !
load("daten/bundestag/bundestag.korpus.RData")
docvars(korpus.bundestag, "Tokens") <- korpus.bundestag.stats$Tokens
korpus.bundestag.filtered <- corpus_subset(korpus.bundestag, Tokens >= 150)
korpus.bundestag.filtered <- corpus_subset(korpus.bundestag.filtered, speaker_party %in% c("cducsu", "gruene",  "linke", "spd"))
# ausserdem müssen noch einige redner ausgeschlossen, die parlamentarische funktion haben, d.h. schmidt, lammert, pau, bulmahn etc
partei <- docvars(korpus.bundestag.filtered, "party")
weitere.stoppwoerter <- scan("daten/bundestag/weitere_stoppwoerter.txt", what = "char", sep = "\n", quiet = T)
meine.dfm <- dfm(korpus.bundestag.filtered, remove_numbers = TRUE, remove_punct = TRUE, remove = c(stopwords("german"), weitere.stoppwoerter))
meine.dfm
meine.dfm.trim <- dfm_trim(meine.dfm, min_docfreq = 0.001, docfreq_type = "prop") # optional: min_count = 10
#meine.dfm.trim <- dfm_trim(meine.dfm, min_termfreq = 2, min_docfreq = 2)
meine.dfm.trim


# nb classification

modell.NB <- textmodel_nb(meine.dfm.trim, partei, prior = "docfreq")
head(as.character(predict(modell.NB)))

# prediction accuracy
prop.table(table(predict(modell.NB) == partei))*100
# random guessing accuracy
prop.table(table(sample(predict(modell.NB)) == partei))*100

# plot entscheidender terme
nb.terme <- as.data.frame(t(modell.NB$PwGc)) %>% 
  rownames_to_column("Wort") %>% 
  gather(Partei, Wahrscheinlichkeit, -Wort) %>% 
  arrange(Partei, desc(Wahrscheinlichkeit)) %>% 
  #left_join(labels.kategorien, by = "Kategorie") %>% 
  group_by(Partei) %>% 
  mutate(Rang = row_number()) %>% 
  filter(Rang <= 10)
p1 <- ggplot(filter(nb.terme, Partei == "CDU"), aes(reorder(Wort, Rang), Wahrscheinlichkeit)) + geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("") + ylab("") + ggtitle("CDU")
p2 <- ggplot(filter(nb.terme, Partei == "CSU"), aes(reorder(Wort, Rang), Wahrscheinlichkeit)) + geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("") + ylab("") + ggtitle( "CSU")
p3 <- ggplot(filter(nb.terme, Partei == "SPD"), aes(reorder(Wort, Rang), Wahrscheinlichkeit)) + geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("") + ylab("") + ggtitle("SPD")
p4 <- ggplot(filter(nb.terme, Partei == "DIE GRÜNEN"), aes(reorder(Wort, Rang), Wahrscheinlichkeit)) + geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("") + ylab("") + ggtitle("DIE GRÜNEN")
p5 <- ggplot(filter(nb.terme, Partei == "DIE LINKE"), aes(reorder(Wort, Rang), Wahrscheinlichkeit)) + geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + xlab("") + ylab("") + ggtitle("DIE LINKE")
grid.arrange(p1, p2, p3, p4, p5, nrow = 3)


# svm classification

container <- create_container(convert(meine.dfm.trim, to = "matrix"), as.numeric(factor(partei)), trainSize = 1:21456, testSize = 21457:23840, virgin = FALSE)
models <- train_models(container, algorithms = c("MAXENT", "SLDA"))
classifiers <- classify_models(container, models)
analytics <- create_analytics(container, classifiers)
summary(analytics)
