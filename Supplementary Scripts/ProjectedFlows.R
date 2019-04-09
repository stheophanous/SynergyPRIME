#Surf flows
flows <- read.csv('C:\\Users\\medsthe\\Downloads\\surf-master\\abm\\surf-abm\\data\\otley\\model_data\\oa_flows-study_area.csv')
flows <- flows[,2:4]
flows <- flows[order(flows[,1], flows[,2]), ]

#Proportion of flows per OA
OAlist <- as.data.frame(unique(flows$Orig))
colnames(OAlist) <- 'OA'
OAlist$popul <- NA

for (i in 1:nrow(OAlist)){
  OAlist$popul[i] <- sum(flows$Flow[which(OAlist$OA[i] == flows$Orig)])
}

flows$prop <- NA
for (i in 1:nrow(flows)){
  flows$prop[i] <- flows$Flow[i] / OAlist$popul[flows$Orig[i] == OAlist$OA]
}

# Combine with population projections
popul.projections <- read.csv('M:\\Mistral\\FinalResultOAlevel.csv')

popul.projections.year <- subset(popul.projections, popul.projections$year == min(popul.projections$year))

flows$projflow <- NA

for (i in 1:nrow(flows)){
  flows$projflow[i] <- flows$prop[i] * popul.projections.year$commuters[as.character(flows$Orig[i]) == as.character(popul.projections.year$OA)]
}

flows$projflow <- round(flows$projflow)
totalprojectedflows <- flows[,c(1,2,5)]
totalprojectedflows$Year <- min(popul.projections$year)
colnames(totalprojectedflows)[3] <- 'Flow.proj'

minyear <- min(popul.projections$year)
maxyear <- max(popul.projections$year)

for (j in minyear+1:maxyear){
  popul.projections.year <- subset(popul.projections, popul.projections$year == j)
  flows$projflow <- NA
  for (i in 1:nrow(flows)){
    flows$projflow[i] <- flows$prop[i] * popul.projections.year$commuters[as.character(flows$Orig[i]) == as.character(popul.projections.year$OA)]
  }
  flows$projflow <- round(flows$projflow)
  projectedflows <- flows[,c(1,2,5)]
  projectedflows$Year <- j
  colnames(projectedflows)[3] <- 'Flow.proj'
  totalprojectedflows <- rbind(totalprojectedflows, projectedflows)
}

colnames(totalprojectedflows) <- c('OA', 'DestinationOA', 'FlowComm', 'Year')

write.csv(totalprojectedflows, file = 'M:\\Mistral\\ProjectedFlows.csv')

#================================================================================
#Add non-commuter flows
rm(list = ls())

#Surf flows
flows <- read.csv('C:\\Users\\medsthe\\Downloads\\surf-master\\abm\\surf-abm\\data\\otley\\model_data\\oa_flows-study_area.csv')
flows <- flows[,2:4]
flows <- flows[order(flows[,1], flows[,2]), ]

#Proportion of flows per OA
OAlist <- as.data.frame(unique(flows$Orig))
colnames(OAlist) <- 'OA'
OAlist$popul <- NA

for (i in 1:nrow(OAlist)){
  OAlist$popul[i] <- sum(flows$Flow[which(OAlist$OA[i] == flows$Orig)])
}

flows$prop <- NA
for (i in 1:nrow(flows)){
  flows$prop[i] <- flows$Flow[i] / OAlist$popul[flows$Orig[i] == OAlist$OA]
}

# Combine with population projections
popul.projections <- read.csv('M:\\Mistral\\FinalResultOAlevel.csv')

popul.projections.year <- subset(popul.projections, popul.projections$year == min(popul.projections$year))

flows$projflow <- NA

for (i in 1:nrow(flows)){
  flows$projflow[i] <- flows$prop[i] * popul.projections.year$noncommuters[as.character(flows$Orig[i]) == as.character(popul.projections.year$OA)]
}

flows$projflow <- round(flows$projflow)
totalprojectedflows <- flows[,c(1,2,5)]
totalprojectedflows$Year <- min(popul.projections$year)
colnames(totalprojectedflows)[3] <- 'Flow.proj'

minyear <- min(popul.projections$year)
maxyear <- max(popul.projections$year)

for (j in minyear+1:maxyear){
  popul.projections.year <- subset(popul.projections, popul.projections$year == j)
  flows$projflow <- NA
  for (i in 1:nrow(flows)){
    flows$projflow[i] <- flows$prop[i] * popul.projections.year$noncommuters[as.character(flows$Orig[i]) == as.character(popul.projections.year$OA)]
  }
  flows$projflow <- round(flows$projflow)
  projectedflows <- flows[,c(1,2,5)]
  projectedflows$Year <- j
  colnames(projectedflows)[3] <- 'Flow.proj'
  totalprojectedflows <- rbind(totalprojectedflows, projectedflows)
}

colnames(totalprojectedflows) <- c('OA', 'DestinationOA', 'FlowComm', 'Year')

projflowscommuters <- read.csv('M:\\Mistral\\ProjectedFlows.csv')

finalprojectedflows <- cbind(projflowscommuters[,c(2,3,5,4)], totalprojectedflows[,3])
colnames(finalprojectedflows) <- c('OriginOA', 'DestinationOA', 'Year', 'FlowComm', 'FlowNonComm')



write.csv(finalprojectedflows, file = 'M:\\Mistral\\FinalProjectedFlows.csv')


