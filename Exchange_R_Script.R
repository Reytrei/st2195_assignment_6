library("dplyr")
library("tidyr")


speeches <- read.csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/speeches.csv", header=FALSE, sep = ";", col.names = c("Date","Contents"))
fx <- read.csv("D:/Juanma/Juanma/Universidad/Programacion/st2195_assignment_6/fx.csv",header=FALSE, col.names = c("Date","Exchange_Rate") )

exchanges <- fx %>% left_join(speeches)

exchanges[, 2] <- sapply(exchanges[, 2], as.numeric)

exchanges <-  exchanges %>% drop_na("Exchange_Rate")


