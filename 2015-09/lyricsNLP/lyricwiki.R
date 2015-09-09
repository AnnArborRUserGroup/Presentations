

# resources
http://api.wikia.com/wiki/LyricWiki_API
http://api.wikia.com/wiki/LyricWiki_API/REST

#get song list in XML format
http://lyrics.wikia.com/api.php?func=getArtist&artist=Tool&fmt=xml&fixXML

#get song lyrics as text
http://lyrics.wikia.com/api.php?func=getSong&artist=Tool&song=Schism&fmt=text

#pass those songs into function to get lyrics
http://lyrics.wikia.com/api.php?func=getSong&artist=Tool&song=Schism&fmt=xml

library(XML)
library(RCurl)
library(dplyr)

#trim leading and trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#get discography
get_discog <- function(artist){
  
  call <- paste("http://lyrics.wikia.com/api.php?func=getArtist",
                "&artist=",URLencode(artist),
                "&fmt=xml&fixXML", sep = "")
  
  xml <- xmlParse(call)
  
  discog <- xmlToDataFrame(nodes=getNodeSet(xml, "//albumResult/songs/item"))
  
  return(discog)
}

#get song text
get_lyrics <- function(artist, song){
  
  songURL <- song %>% as.character() %>% URLencode()
  
  call <- paste("http://lyrics.wikia.com/api.php?func=getSong",
                "&artist=",artist,
                "&song=",songURL,
                "&fmt=text", sep = "")
  
  lyrics <- getURLContent(url = call) %>%
    as.character() %>%
    gsub("\\n", " ", .)
  
  return(lyrics)
}

artist <- "Tool"
song <- "Pushit (Live)"

discog <- get_discog(artist)

