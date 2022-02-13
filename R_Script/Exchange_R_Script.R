library("dplyr")
library("tidyr")
library("zoo")
library(tidyverse)
library(tidytext)


# Importing Data
speeches <- read.csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/speeches2.csv", header=TRUE, sep = "|")
fx <- read.csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/fx.csv",header=FALSE, col.names = c("date","Exchange_Rate") )

#Removing unwanted columns from speeches
speeches <- speeches[,c(1,5)]

#Correcting name
colnames(speeches)[2] <- "contents"

#Grouping by date to eliminate duplicates for same date
speeches <- speeches %>% 
  group_by(date) %>% 
  summarise(contents = paste(contents, Collapse = ""))

#Joining Fx and Speeches
exchanges <- fx %>% 
  left_join(speeches)

#Changing Exchange Rate to Numeric
exchanges[, 2] <- sapply(exchanges[, 2], as.numeric)

# Filling NA in Exchange Rate with previous data
exchanges <- exchanges %>% 
  fill(Exchange_Rate)

#Calculating exchange rates
exchanges$returns <- c(-diff(exchanges$Exchange_Rate)/exchanges$Exchange_Rate[-1]*100, NA)

#Classifying good news
exchanges <- exchanges %>% 
  mutate(good_news = case_when(exchanges$returns > 0.5 ~ 1, exchanges$returns < 0.5 ~ 0))

#Classifying bad news
exchanges <- exchanges %>% 
  mutate(bad_news = case_when(exchanges$returns < -0.5 ~ 1, exchanges$returns > -0.5 ~ 0))

#Eliminating returns column
exchanges <- subset(exchanges, select = -returns)

#Droping NA on contents
exchanges <- exchanges %>% 
  drop_na(contents) 

#Creating list of stop_words
custom_stop_words <- tribble(
  ~word,      ~lexicon,
  "de", "CUSTOM",
  "die", "CUSTOM",
  "la", "CUSTOM",
  "ã", "CUSTOM",
  "la", "CUSTOM",
  "der", "CUSTOM",
  "die", "CUSTOM",
  "der", "CUSTOM",
  "el", "CUSTOM",
  "des", "CUSTOM",
  "en", "CUSTOM",
  "und", "CUSTOM",
  "los", "CUSTOM",
  "â", "CUSTOM",
  "lâ", "CUSTOM",
  "del", "CUSTOM",
  "les", "CUSTOM",
  "di", "CUSTOM",
  "le", "CUSTOM",
  "dâ", "CUSTOM"
  )
stop_words2 <- stop_words %>%
  bind_rows(custom_stop_words)

#selecting common words with good news
good_indicators <- exchanges %>% 
#tokenizing words
  unnest_tokens(word, contents) %>%
#eliminating stopwords
  anti_join(stop_words2) %>%
  filter(good_news == 1) %>%
#grouping by word
  group_by(word) %>%
#counting words
  count(word) %>%
  arrange(desc(n)) 

#selecting top 20
good_indicators <- good_indicators[1:20,1]

#selecting common words with bad news
bad_indicators <- exchanges %>% 
  #tokenizing words
  unnest_tokens(word, contents) %>%
  #eliminating stopwords
  anti_join(stop_words2) %>%
  filter(bad_news == 1) %>%
  #grouping by word
  group_by(word) %>%
  #counting words
  count(word) %>%
  arrange(desc(n)) 

#selecting top 20 words
bad_indicators <- bad_indicators[1:20,1]

#Exporting CSVs
write.csv(good_indicators,"D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/R_Script/good_indicators.csv")
write.csv(bad_indicators,"D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/R_Script/bad_indicators.csv")
