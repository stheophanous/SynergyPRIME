#Import population projections for Leeds
popul.projection <- read.csv('M:\\Mistral\\PopulationProjection.csv')
popul.projection <- popul.projection[,c(2,4,5)]
popul.projection <- subset(popul.projection, popul.projection$C_AGE >= 16 & popul.projection$C_AGE <= 74) #Ages 16-74 -> Same as Economic Activity UK census ages -> Split to Commuters/Retired.
colnames(popul.projection) <- c('Age', 'ProjectedYear', 'Population')
MSOAs <- read.csv('M:\\Mistral\\LADtoMSOA.csv')

#Find total Leeds population for each year
iyear <- 2018
leeds.per.year <- data.frame(matrix(NA, nrow = 24, ncol = 2))
colnames(leeds.per.year) <- c('year', 'population')
for (i in 1:24){
  leeds.per.year$population[i] <- sum(popul.projection$Population[which(popul.projection$ProjectedYear == iyear)])
  leeds.per.year$year[i] <- iyear
  iyear <- iyear + 1
}

#MSOA population projections per year
LADtoMSOA <- data.frame(matrix(NA, nrow = nrow(MSOAs)*24, ncol = 3))
colnames(LADtoMSOA) <- c('MSOA', 'year', 'population')

jyear <- 2018
for (i in 1:nrow(LADtoMSOA)){
  if (jyear <= 2041){
    LADtoMSOA$year[i] <- jyear
    jyear <- jyear + 1
  } else if (jyear > 2041){
    LADtoMSOA$year[i] <- 2018
    jyear <- 2019
  }
}

j <- 1
for (i in 1:nrow(LADtoMSOA)){
  if (as.numeric(LADtoMSOA$year[i]) < 2041){
    LADtoMSOA$MSOA[i] <- as.character(MSOAs$GEOGRAPHY_CODE[j])
  } else if (as.numeric(LADtoMSOA$year[i]) == 2041){
    LADtoMSOA$MSOA[i] <- as.character(MSOAs$GEOGRAPHY_CODE[j])
    j <- j+1
  }
}

for (i in 1:nrow(LADtoMSOA)){
  prop <- as.numeric(MSOAs$PROP[as.character(MSOAs$GEOGRAPHY_CODE) == as.character(LADtoMSOA$MSOA[i])])
  total <- as.numeric(leeds.per.year$population[leeds.per.year$year == LADtoMSOA$year[i]])
  popul <- prop * total
  LADtoMSOA$population[i] <- as.numeric(popul)
}

# MSOAs to OAs
OAs <- read.csv('M:\\Mistral\\OAsInMSOAs.csv')
colnames(OAs) <- c('inputRow', 'MSOA', 'proportion', 'OA')
OAs$MSOA <- as.character(OAs$MSOA)
OAs$OA <- as.character(OAs$OA)

MSOAtoOA <- OAs[rep(row.names(OAs), 24), 1:4]
MSOAtoOA <- MSOAtoOA[order(MSOAtoOA[,2], MSOAtoOA[,4]), ]
MSOAtoOA$year <- NA
MSOAtoOA$total.population <- NA

jyear <- 2018
for (i in 1:nrow(MSOAtoOA)){
  if (jyear <= 2041){
    MSOAtoOA$year[i] <- jyear
    jyear <- jyear + 1
  } else if (jyear > 2041){
    MSOAtoOA$year[i] <- 2018
    jyear <- 2019
  }
}

for (i in 1:nrow(MSOAtoOA)){
  popul <- LADtoMSOA$population[as.character(LADtoMSOA$MSOA) == trimws(as.character(MSOAtoOA$MSOA[i])) & LADtoMSOA$year == MSOAtoOA$year[i]]
  prop <- as.numeric(MSOAtoOA$proportion[i])
  MSOAtoOA$total.population[i] <-  popul * prop
}

MSOAtoOA$total.population <- round(MSOAtoOA$total.population)

sum(LADtoMSOA$population, na.rm = TRUE)
sum(MSOAtoOA$total.population, na.rm = TRUE)

MSOAtoOA <- MSOAtoOA[,2:6]
MSOAtoOA <- subset(MSOAtoOA, !is.na(MSOAtoOA$total.population))

write.csv(MSOAtoOA, file = 'M:\\Mistral\\OAprojpopulation16to74.csv')

#---------------------------------------------------------------------------------------------
# Do exactly the same but for ages 75+
rm(list = ls())

#Import population projections for Leeds
popul.projection <- read.csv('M:\\Mistral\\PopulationProjection.csv')
popul.projection <- popul.projection[,c(2,4,5)]
popul.projection <- subset(popul.projection, popul.projection$C_AGE >= 75) #Ages 75+ -> Assume ALL retired
colnames(popul.projection) <- c('Age', 'ProjectedYear', 'Population')
MSOAs <- read.csv('M:\\Mistral\\LADtoMSOA.csv')

#Find total Leeds population for each year
iyear <- 2018
leeds.per.year <- data.frame(matrix(NA, nrow = 24, ncol = 2))
colnames(leeds.per.year) <- c('year', 'population')
for (i in 1:24){
  leeds.per.year$population[i] <- sum(popul.projection$Population[which(popul.projection$ProjectedYear == iyear)])
  leeds.per.year$year[i] <- iyear
  iyear <- iyear + 1
}

#MSOA population projections per year
LADtoMSOA <- data.frame(matrix(NA, nrow = nrow(MSOAs)*24, ncol = 3))
colnames(LADtoMSOA) <- c('MSOA', 'year', 'population')

jyear <- 2018
for (i in 1:nrow(LADtoMSOA)){
  if (jyear <= 2041){
    LADtoMSOA$year[i] <- jyear
    jyear <- jyear + 1
  } else if (jyear > 2041){
    LADtoMSOA$year[i] <- 2018
    jyear <- 2019
  }
}

j <- 1
for (i in 1:nrow(LADtoMSOA)){
  if (as.numeric(LADtoMSOA$year[i]) < 2041){
    LADtoMSOA$MSOA[i] <- as.character(MSOAs$GEOGRAPHY_CODE[j])
  } else if (as.numeric(LADtoMSOA$year[i]) == 2041){
    LADtoMSOA$MSOA[i] <- as.character(MSOAs$GEOGRAPHY_CODE[j])
    j <- j+1
  }
}

for (i in 1:nrow(LADtoMSOA)){
  prop <- as.numeric(MSOAs$PROP[as.character(MSOAs$GEOGRAPHY_CODE) == as.character(LADtoMSOA$MSOA[i])])
  total <- as.numeric(leeds.per.year$population[leeds.per.year$year == LADtoMSOA$year[i]])
  popul <- prop * total
  LADtoMSOA$population[i] <- as.numeric(popul)
}

# MSOAs to OAs
OAs <- read.csv('M:\\Mistral\\OAsInMSOAs.csv')
colnames(OAs) <- c('inputRow', 'MSOA', 'proportion', 'OA')
OAs$MSOA <- as.character(OAs$MSOA)
OAs$OA <- as.character(OAs$OA)

MSOAtoOA <- OAs[rep(row.names(OAs), 24), 1:4]
MSOAtoOA <- MSOAtoOA[order(MSOAtoOA[,2], MSOAtoOA[,4]), ]
MSOAtoOA$year <- NA
MSOAtoOA$total.population <- NA

jyear <- 2018
for (i in 1:nrow(MSOAtoOA)){
  if (jyear <= 2041){
    MSOAtoOA$year[i] <- jyear
    jyear <- jyear + 1
  } else if (jyear > 2041){
    MSOAtoOA$year[i] <- 2018
    jyear <- 2019
  }
}

for (i in 1:nrow(MSOAtoOA)){
  popul <- LADtoMSOA$population[as.character(LADtoMSOA$MSOA) == trimws(as.character(MSOAtoOA$MSOA[i])) & LADtoMSOA$year == MSOAtoOA$year[i]]
  prop <- as.numeric(MSOAtoOA$proportion[i])
  MSOAtoOA$total.population[i] <-  popul * prop
}

MSOAtoOA$total.population <- round(MSOAtoOA$total.population)

sum(LADtoMSOA$population, na.rm = TRUE)
sum(MSOAtoOA$total.population, na.rm = TRUE)

MSOAtoOA <- MSOAtoOA[,2:6]
MSOAtoOA <- subset(MSOAtoOA, !is.na(MSOAtoOA$total.population))

write.csv(MSOAtoOA, file = 'M:\\Mistral\\OAprojpopulation75plus.csv')
