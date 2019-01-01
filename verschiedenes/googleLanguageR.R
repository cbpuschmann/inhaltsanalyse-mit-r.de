# Google Cloud Services for NLP
# https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

library("googleLanguageR")
gl_auth("verschiedenes/googleLanguageR-b70ebebb5229.json")

#texts <- c("to administer medicince to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so", "I don't know how to make a text demo that is sensible")
x <- scan("daten/sherlock/romane/01 A Scandal in Bohemia.txt", what = "char", sep = "\n")
nlp_result <- gl_nlp(paste(x, collapse = " "))

text <- "to administer medicine to animals is frequently a very difficult matter, and yet sometimes it's necessary to do so"

## translate British into Danish
gl_translate(text, target = "de")$translatedText
