

```{r}


# Analyse mit Naive Bayes in quanteda: https://tutorials.quanteda.io/machine-learning/nb/


# monkeylearn API (Überblick über Funktionen: https://app.monkeylearn.com/main/explore/)
# Kostenloser API Key: https://app.monkeylearn.com/accounts/register/

# Installation und Einstellungen
if(!require("devtools")) install.packages("devtools")
devtools::install_github("ropensci/monkeylearn")
library("monkeylearn")
apikey <- "aed10806f2387f5060762ca351afdd215d45dec4"

# Zufallssample aus dem NYT-Korpus ziehen
nyt.text <- daten$Title[sample(1:nrow(daten), size = 100)]

# Named Entity Recognition
#text <- "In the 19th century, the major European powers had gone to great lengths to maintain a balance of power throughout Europe, resulting in the existence of a complex network of political and military alliances throughout the continent by 1900.[7] These had started in 1815, with the Holy Alliance between Prussia, Russia, and Austria. Then, in October 1873, German Chancellor Otto von Bismarck negotiated the League of the Three Emperors (German: Dreikaiserbund) between the monarchs of Austria-Hungary, Russia and Germany."
ml.entities <- monkeylearn_extract(nyt.text, extractor_id = "ex_isnnZRbS", key = apikey, verbose = T)
ml.entities

# Sentiment Analysis
ml.sentiment <- monkeylearn_classify(nyt.text, classifier_id = "cl_Jx8qzYJh", key = apikey, verbose = T)
ml.sentiment

# News Classification
ml.class <- monkeylearn_classify(nyt.text, classifier_id = "cl_hS9wMk9y", key = apikey, verbose = T)
ml.class
```
