
"""
Created on Mon Feb 14 10:35:40 2022

@author: jtrelles
"""

import pandas as pd
from  nltk import word_tokenize
from nltk.corpus import stopwords
from collections import Counter


#Import CSVs
speeches = pd.read_csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/speeches2.csv",sep="|")
fx = pd.read_csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/fx.csv",header=None,names =["date","exchange_rate"] ,na_values=['-'])

# Change column name and select columns from speeches
speeches = speeches.rename(columns={ speeches.columns[4]: "contents" })
speeches = speeches[["date","contents"]]

#Change exchange_rate type as float
fx["exchange_rate"] = fx[["exchange_rate"]].astype(float)

#Fill NA values
fx_fill_na = fx.fillna(method = 'ffill')

#Change contents to string
speeches['contents'] = speeches['contents'].astype(str)

#Group by speeches to eliminate contents with same date
speeches['contents'] = speeches.groupby(['date'])['contents'].transform(lambda x : " ".join(x))
speeches = speeches.drop_duplicates()

#Join fx and speeches
exchanges = fx_fill_na.set_index('date').join(speeches.set_index('date'), how = 'left', )

#Calculate Returns
exchanges['returns'] = ((exchanges.exchange_rate - exchanges.exchange_rate.shift(1))*100/exchanges.exchange_rate.shift(1))



#Clasify good news
for index, row in exchanges.iterrows():
    if exchanges.loc[index, 'returns'] > 0.5 : 
        exchanges.loc[index,'good_news'] = 1,
    else: 
        exchanges.loc[index,'good_news'] = 0
#Clasify bad news
for index, row in exchanges.iterrows():
    if exchanges.loc[index, 'returns'] < -0.5 : 
        exchanges.loc[index,'bad_news'] = 1,
    else: 
        exchanges.loc[index,'bad_news'] = 0

#Drop NA from contents        
exchanges = exchanges.dropna(axis = 0, subset = {'contents'})


#Tokenize words
exchanges['tokenized_text'] = exchanges['contents'].apply(word_tokenize) 

#Filter words for good indicators
good_indicators = exchanges[exchanges.good_news == 1]

# Separate tokens en each column
good_indicators = good_indicators.explode('tokenized_text')

#Create a list of words
good_indicators = good_indicators['tokenized_text']
good_indicators = good_indicators.tolist()

#Creat list of stopwords = 
stopwords = nltk.corpus.stopwords.words('english')
new_words =  ("de", "die","la","ã","la","der","die","der","el","des","en","und","los","â","lâ","del", "les","di","le","dâ","speech")
for i in new_words : 
    stopwords.append(i)
              
#Eliminate punctuation
good_indicators = [t for t in good_indicators if t.isalpha()]
#To lower case
good_indicators = [t.lower() for t in good_indicators]
#Eliminate english stop words
good_indicators = [t for t in good_indicators if t not in stopwords]
#Select top 20 used words
good_indicators = Counter(good_indicators).most_common(20)
#To dataframe
good_indicators = pd.DataFrame(good_indicators , columns=["Words","Counts"])
#To CSV
good_indicators.to_csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/Python_Script/good.csv")

#Filter bad indicators
bad_indicators = exchanges[exchanges.bad_news == 1]
#Separate tokens en each column
bad_indicators = bad_indicators.explode('tokenized_text')

#Create a list of words
bad_indicators = bad_indicators['tokenized_text']
bad_indicators = bad_indicators.tolist()

#Eliminate punctuation
bad_indicators = [t for t in bad_indicators if t.isalpha()]
#To lower case
bad_indicators = [t.lower() for t in bad_indicators]
#Eliminate english stop words
bad_indicators = [t for t in bad_indicators if t not in stopwords]
#Select top 20 used words
bad_indicators = Counter(bad_indicators).most_common(20)
#To dataframe
bad_indicators = pd.DataFrame(bad_indicators , columns=["Words","Counts"])
#To CSV
bad_indicators.to_csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/Python_Script/bad.csv")
