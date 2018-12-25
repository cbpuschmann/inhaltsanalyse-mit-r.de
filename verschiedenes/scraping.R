url <- 'https://www.ecowatch.com/'

webpage <- scan(url, what = "char", sep = "\n")

cleanFun <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}

webtext <- cleanFun(webpage)
webtext <- webtext[webtext != ""]
head(webtext)

#install.packages('rvest')

library("rvest")

#Reading the HTML code from the website
webpage <- read_html(url)

webpage$doc
