agent.activities <- read.csv("C:\\Users\\medsthe\\Desktop\\agentactivities2019.csv")

length(which(as.numeric(agent.activities$PreviousCentroidID) == as.numeric(agent.activities$NextCentroidID)))

library(XML)
library(xml2)

#Prepare lists to add to xml file
vehicleArrival2 <- list()
modalId2 <- as.list(rep(53, each = nrow(agent.activities)))
timeGeneration2 <- as.list(agent.activities$time)
generationSeed2 <- as.list(sample(10000:99999,nrow(agent.activities),replace=F))
selectionSeed2 <- generationSeed2
originId2 <- as.list(agent.activities$PreviousCentroidID)
destinationId2 <- as.list(agent.activities$NextCentroidID)
arrivals2 <- list()

for (i in 1:nrow(agent.activities)){
  vehicleArrival2 <- list(
    modalId2[[i]],
    timeGeneration2[[i]],
    generationSeed2[[i]],
    selectionSeed2[[i]],
    originId2[[i]],
    destinationId2[[i]]
  )
  arrivals2[[i]] <- vehicleArrival2
}

#Construct XML tree
traffic.arrivals <- as_xml_document(list(TrafficArrivals = list(
  trafficArrivalId = list(sample(10000:99999,1,replace=F)),
  vehicleTypes = list(
    vehicleType = structure(list(
      modalId = list(0)
    ), id = "53")
  ),
  initialTime = list(min(agent.activities$time)),
  duration = list(max(agent.activities$time)),
  warmUp = list(0),
  replication = list(sample(10000:99999,1,replace=F)),
  arrivals = list(
    vehicleArrival = structure(list(
      modalId = list(arrivals2[[1]][1]),
      timeGeneration = list(arrivals2[[1]][2]),
      generationSeed = list(arrivals2[[1]][3]),
      selectionSeed = list(arrivals2[[1]][4]),
      originId = list(arrivals2[[1]][5]),
      destinationId = list(arrivals2[[1]][6])
    ), id = "1")
  ),
  demandProfile = list(
    profileInterval = list(max(agent.activities$time)),
    vehicleProfile = structure(list(730, 0, 0, 0), id = "53")
  )
)))

for (i in 2:length(arrivals2)){
  xml_add_child(xml_children(traffic.arrivals)[[7]], 'vehicleArrival', id = as.character(i))
  xml_add_child(xml_children(xml_children(traffic.arrivals)[[7]])[[i]], 'modalId', as.character(arrivals2[[i]][1]))
  xml_add_child(xml_children(xml_children(traffic.arrivals)[[7]])[[i]], 'timeGeneration', as.character(arrivals2[[i]][2]))
  xml_add_child(xml_children(xml_children(traffic.arrivals)[[7]])[[i]], 'generationSeed', as.character(arrivals2[[i]][3]))
  xml_add_child(xml_children(xml_children(traffic.arrivals)[[7]])[[i]], 'selectionSeed', as.character(arrivals2[[i]][4]))
  xml_add_child(xml_children(xml_children(traffic.arrivals)[[7]])[[i]], 'originId', as.character(arrivals2[[i]][5]))
  xml_add_child(xml_children(xml_children(traffic.arrivals)[[7]])[[i]], 'destinationId', as.character(arrivals2[[i]][6]))
}

write_xml(traffic.arrivals, file = "C:\\Users\\medsthe\\Desktop\\FinalSim\\trafficarrivals2019.ata")
