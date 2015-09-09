
options(stringsAsFactors = FALSE)

library(stringr)
library(XML)

apikey = ""

#artist = "Tool"
artist = "460"

#artist = "Taylor Swift"
#artist = "259675"

get_artist <- function(artist, apikey){
  
  call = paste("http://api.musixmatch.com/ws/1.1/artist.search?",
               "q_artist=",artist,
               "&apikey=",apikey,
               "&format=xml", sep = "")
  
  xml <- xmlParse(call)
  
  artist_ids <- xmlToDataFrame(nodes=getNodeSet(xml, "//artist/artist_id"))
  artist_names <- xmlToDataFrame(nodes=getNodeSet(xml, "//artist/artist_name"))
  
  return(data.frame(id = artist_ids$text, name = artist_names$text))
}

get_albums <- function(artist, apikey){
  
  call = paste("http://api.musixmatch.com/ws/1.1/artist.albums.get?",
               "artist_id=", artist,
               "&apikey=", apikey,
               "&page_size=100",
               "&format=xml", sep = "")
  
  xml <- xmlParse(call)
  
  albums <- xmlToDataFrame(nodes=getNodeSet(xml, "//album/album_id"))
  #albums <- xmlToDataFrame(nodes=getNodeSet(xml, "//album/album_name"))
  
  return(albums$text)
}

get_tracks <- function(album, apikey){
  
  call = paste("http://api.musixmatch.com/ws/1.1/album.tracks.get?",
               "album_id=", album,
               "&apikey=", apikey,
               "&page_size=100",
               "&f_has_lyrics=1",
               "&format=xml", sep = "")
  
  xml <- xmlParse(call)
  
  tracks <- xmlToDataFrame(nodes=getNodeSet(xml, "//track/track_id"))
  
  return(tracks$text)
}
  
get_lyrics <- function(track, apikey){
  
  call = paste("http://api.musixmatch.com/ws/1.1/track.lyrics.get?",
               "track_id=", track,
               "&apikey=", apikey,
               "&format=xml", sep = "")
  
  xml <- xmlParse(call)
  
  lyrics <- tryCatch(xmlToDataFrame(nodes=getNodeSet(xml, "//lyrics_body")),
                     error = function(e) print("NA"))
  
  lyrics_clean <- lyrics %>% 
    as.character() %>% 
    gsub("This Lyrics is NOT for Commercial use","", .) %>% 
    gsub("\\n", " ", .)
  
  return(lyrics_clean)
}
  
get_corpus <- function(artist, apikey){
  
  #get albums for particular artist
  albums <- get_albums(artist, apikey)
  
  #loop through albums
  tracks <- lapply(albums, get_tracks, apikey) %>% unlist()
  
  #loop through tracks
  lyrics <- lapply(tracks, get_lyrics, apikey) %>% unlist()
  
  obj <- list(lyrics = data.frame(lyrics),
              n_albums = length(albums),
              n_tracks = length(tracks))
  
  return(obj)
}

collection <- get_corpus(artist, apikey)

library(tm)
library(SnowballC)
library(slam)

removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)

other <- c("instrumental","fuck","fucking","get","shit","fucker","asshole","fucked","know","like","just","got")

custom_stopwords <- c(stopwords("english"), other) %>% sapply(., function(x) gsub("[[:punct:]]", "", x),
                                                              simplify = "array",
                                                              USE.NAMES = F)

corpus <- Corpus(VectorSource(collection$lyrics$lyrics)) %>%
  tm_map(content_transformer(tolower)) %>%
  tm_map(stripWhitespace) %>%
  tm_map(removePunctuation) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeURL) %>%
  tm_map(removeWords, custom_stopwords) %>%
  tm_map(stemDocument) %>%
  tm_map(PlainTextDocument)

tdm <- corpus %>%
  TermDocumentMatrix(control = list(minWordLength = 3))

dtm <- as.DocumentTermMatrix(tdm)

#slam::row_sums(dtm, na.rm = T)
#slam::col_sums(tdm, na.rm = T)

term.freq <- slam::row_sums(tdm, na.rm = T)
high.freq <- sort(term.freq, decreasing = T)[1:20]
freq.terms <- findFreqTerms(tdm, lowfreq = high.freq[length(high.freq)])

df <- data.frame(term = names(high.freq), freq = high.freq)

# Bar chart of most frequent words  

library(ggplot2)

ggplot(df, aes(x = term, y = freq)) +
  geom_bar(stat = "identity") +
  xlab("Terms") +
  ylab("Count") +
  coord_flip()

# Correlated words appearing in the same description (r >= 0.1)  

#source("http://bioconductor.org/biocLite.R")
#biocLite("graph")
#biocLite("Rgraphviz")

library(graph)
library(Rgraphviz)

plot(tdm,
     term = freq.terms,
     corThreshold = 0.2,
     weighting = T)

# Word cloud  

library(wordcloud)

word.freq <- sort(term.freq, decreasing = T)[1:100]
#COL <- ifelse(names(word.freq) %in% c("fail", "diagnose"), "red", "black")
pal2 <- brewer.pal(8,"Dark2")

wordcloud(words = names(word.freq),
          freq = word.freq,
          #colors = COL,
          scale = c(4, 0.1),
          colors = pal2,
          rot.per = 0.15,
          random.color = F,
          random.order = F)

#K-means clustering
library(fpc)
library(cluster)

d <- dist(t(dtm), method = "euclidian")

kfit <- kmeans(d, 5)

clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, labels=2, lines=0)

#Topic models identified by Latent Dirichlet Allocation  

library(topicmodels)

set.seed(12345)
lda <- LDA(dtm, k = 5, method = "Gibbs") # find topics using Latent Dirichlet Allocation
term <- terms(lda, 5) # first x terms of every topic
topics <- apply(term, MARGIN = 2, paste, collapse = ";")

doc_topics <- topics(lda, 1)
