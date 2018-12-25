# Automatisierte Inhaltsanalyse mit R
#
# import_twitter.R
# 
# Tweets mittels Twitter-API und Paket 'rtweet' extrahieren
# Details: http://rtweet.info/

# Installation und Laden der notwendigen Bibliotheken
if(!require("rtweet")) install.packages("rtweet")
library("rtweet")

# App-Name (beliebig wählbar)
appname <- "MeineApp"

# API Key (findet man unter https://apps.twitter.com/)
key <- "5lIb81Kj6UH6davFLz9vMc06U"

# API Secret (findet man unter https://apps.twitter.com/)
secret <- "1ElGAQnQPM41vw0NEsmEsvOQVkQAhNIHwlT63oOh6srXuBpVcB"

# Twitter Token für die Verifizierung bei der Twitter API erstellen
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret)

# Tweets mit Schlagwort suchen ("Trump")
trump.suche <- search_tweets(q = "Trump", n = 100, lang = "en")

# Tweets eines bestimmten Nutzers abrufen (@realDonaldTrump)
trump.tweets <- get_timeline("realDonaldTrump", n = 200)


