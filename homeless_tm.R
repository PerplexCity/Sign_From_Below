library(tm)
library(slam)
library(ggplot2)

bbi<-element_text(face="bold.italic", color="black")

signs <- read.csv("~/Desktop/transcribed_signs.csv", stringsAsFactors=FALSE)

signs$url <- NULL
total <- sum(signs$length)
signs$length <- NULL
dim(signs)

#turns the sign text into the corpus
docs <- Corpus(DataframeSource(signs))

#cleans the corpus, removing puncuation, odd characters, capitlization, etc.
docs <- tm_map(docs, removePunctuation)

for(j in seq(docs))   
{   
  docs[[j]] <- gsub("/", " ", docs[[j]])   
  docs[[j]] <- gsub("@", " ", docs[[j]])   
  docs[[j]] <- gsub("\\|", " ", docs[[j]])
} 

docs <- tm_map(docs, tolower)
docs <- tm_map(docs, stemDocument)
docs <- tm_map(docs, stripWhitespace)
docs <- tm_map(docs, PlainTextDocument)

dtm <- DocumentTermMatrix(docs)
tdm <- TermDocumentMatrix(docs) 

#functions that split the corpus in bigrams, trigrams, etc.
BigramTokenizer <-
  function(x)
    unlist(lapply(ngrams(words(x), 2), paste, collapse = " "), use.names = FALSE)

TrigramTokenizer <-
  function(x)
    unlist(lapply(ngrams(words(x), 3), paste, collapse = " "), use.names = FALSE)

FourgramTokenizer <-
  function(x)
    unlist(lapply(ngrams(words(x), 4), paste, collapse = " "), use.names = FALSE)

freq_df <- function(tdm){
  freq <- sort(rowSums(as.matrix(tdm)), decreasing=TRUE)
  freq_df <- data.frame(word=names(freq), freq=freq)
  return(freq_df)
}

unigram <- removeSparseTerms(TermDocumentMatrix(docs), 0.9999)
unigram_freq <- freq_df(unigram)

bigram <- removeSparseTerms(TermDocumentMatrix(docs, control = list(tokenize = BigramTokenizer)), 0.9999)
bigram_freq <- freq_df(bigram)

trigram <- removeSparseTerms(TermDocumentMatrix(docs, control = list(tokenize = TrigramTokenizer)), 0.9999)
trigram_freq <- freq_df(trigram)

fourgram <- removeSparseTerms(TermDocumentMatrix(docs, control = list(tokenize = FourgramTokenizer)), 0.9999)
fourgram_freq <- freq_df(fourgram)

term_freq_plot <- ggplot(unigram_freq[1:25,], aes(reorder(word, freq), freq/total)) +
  labs(y = "Frequency", x="", 
       title = "NYC Homeless Signs:\nTop 25 Words") +
  scale_y_continuous(limits = c(0,0.05),
                     breaks=c(0, 0.01, 0.02, 0.03, 0.04, 0.05),
                     labels = c("0%", "1%", "2%", "3%", "4%", "5%")) +
  theme(axis.text.x = element_text(size = 12), 
        axis.text.y = element_text(size=12),
        title=bbi) +
  geom_bar(stat = "identity", fill="light blue") + coord_flip()

bigram_freq_plot <- ggplot(bigram_freq[1:25,], aes(reorder(word, freq), freq)) +
  labs(y = "Frequency", x="", 
       title = "NYC Homeless Signs:\nTop 25 Bigrams") +
  theme(axis.text.x = element_text(size = 12), 
        axis.text.y = element_text(size=12),
        title=bbi) +
  geom_bar(stat = "identity", fill="light blue") + coord_flip()

#creates weighted list of all trigrams
trigrams <- c()
for (i in 1:dim(trigram_freq)[1]){
  tg <- trigram_freq[i,1]
  numb <- trigram_freq[i,2]
  trigrams <- c(trigrams, rep(as.character(tg), numb))
}

#creates sentences out of trigrams
trigram_simulator <- function(){
  #starts with random trigram
  start <- sample(trigrams, 1)
  for (i in 1:10){
    pieces <- strsplit(start, " ")
    end <- tail(pieces[[1]], n=2)
    options = c()
    #creates list of plausible subsequent trigrams
    for (i in trigrams){
      if (identical(strsplit(i, " ")[[1]][1:2],end)){
        options <- c(options, i)
      }
    }
    #if list is non-empty, picks random one and splices them together
    if (length(options) > 0){
      new <- sample(options, 1)
      tail <- strsplit(new, " ")[[1]][3]
      start <- paste(start, tail, sep = " ")
    }
    #if there are none, completely new trigram picked
    else{
      new <- sample(trigrams,1)
      start <- paste(start, new, sep = " ")
    }
  }
  # after ten iterations, prints sentence
  print(start)
}

trigram_simulator()