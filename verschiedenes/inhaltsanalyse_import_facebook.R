# Automatisierte Inhaltsanalyse mit R
#
# import_facebook.R
# 
# Facebook-Daten mittels Facebook-API und Paket 'Rfacebook' extrahieren
# Details: https://github.com/pablobarbera/Rfacebook
# API: https://developers.facebook.com/apps/

# Installation und Laden der notwendigen Bibliotheken
if(!require("Rfacebook")) install.packages("Rfacebook")
library("Rfacebook")

# API-Einstellung für die Authentifizierung
myAppID <- "452605828274481"
myAppSecret <- "9ce9238b892d73e7338ae0efcf405268"

# Authentifizierung mit der Facebook API
if (!exists("fb_oauth")) fb_oauth <- fbOAuth(app_id = myAppID, app_secret = myAppSecret, extended_permissions = F)

# Extraktion von Postings auf einer Facebook-Seite 
fb_posts <- getPage("SPD", token = fb_oauth, n = 50)

# Extraktion von Kommentaren auf einer Facebook-Seite 
fb_comments <- getPost("47930567748_10155444620577749", token = fb_oauth, likes = FALSE)


# Skript für die Extraktion von Postings/Kommentaren/Likes für einen Zeitabschnitt (funktioniert derzeit nicht ganz reibungslos)

# page settings
pagename <- "SPD"

# timespan settings
since_date <- "2018-03-04"
until_date <- "2018-03-05"
timespan <- seq(as.Date(since_date), as.Date(until_date), "days")

for (i in 1:(length(timespan)-1))
{
  # report current day
  print(""); print(paste("Retrieving data for", timespan[i], "..."))
  # create data frames if nothing has been downloaded yet
  if (!exists("fb_posts")) fb_posts <- data.frame(from_id=NULL, from_name=NULL, message=NULL, created_time=NULL, type=NULL, link=NULL, id=NULL, likes_count=NULL, comments_count=NULL, shares_count=NULL)
  if (!exists("fb_comments")) fb_comments <- data.frame(from_id=NULL, from_name=NULL, message=NULL, created_time=NULL, likes_count=NULL, id=NULL)
  #if (!exists("fb_likes")) fb_likes <- data.frame(from_name=NULL, from_id=NULL, id=NULL)
  # retrieve new posts from the page and merge with existing posts. note that until is exclusive, i.e. -1 day!
  fb_posts_new <- getPage(page = pagename, token = fb_oauth, since = timespan[i], until = timespan[i+1])
  if (nrow(fb_posts_new) >= 1)
  {
    # add new posts to collection
    fb_posts <- rbind(fb_posts, fb_posts_new)
    # get ids of new posts in order to retrieve comments and likes
    pagepostids <- fb_posts_new$id
    for (j in 1:length(pagepostids))
    {
      # iterate through new post ids and download comments and likes
      fb_userposts <- getPost(pagepostids[j], fb_oauth, likes = FALSE)
      # combine comments and likes with existing data
      if (fb_posts_new$comments_count[j] > 0) fb_comments <- rbind(fb_comments, fb_userposts$comments)
      #if (fb_posts_new$likes_count[j] > 0) fb_likes <- rbind(fb_likes, cbind(fb_userposts$likes, id = pagepostids[j]))
    }
  }
}
# clean up
rm(myAppID, myAppSecret, pagename, since_date, until_date, timespan, fb_posts_new, pagepostids, i, j)
