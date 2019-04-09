#Import changes in agent activities
library(dplyr)
agent.activities <- as.data.frame(read.csv('M:\\GitHub\\surf\\abm\\surf-abm\\results\\out\\ABBF-otley-prime\\2039\\agent-change-activity.csv', row.names = NULL))
agent.activities <- agent.activities[,c(2:11)]
agent.activities <- agent.activities %>% filter(!grepl('None', PreviousActivity))
agent.activities <- agent.activities[complete.cases(agent.activities),]

#Convert BNG to WGS84
library(rgdal)
library(stringr)
ukgrid = "+init=epsg:27700"
latlong = "+init=epsg:4326"
previous.coords <- cbind(Easting = as.numeric(as.character(agent.activities$Px)), Northing = as.numeric(as.character(agent.activities$Py)))
previous.coords <- na.omit(object = previous.coords)
agent.activities.SP <- SpatialPointsDataFrame(previous.coords, data = agent.activities, proj4string = CRS("+init=epsg:27700"))
agent.activities.SP.LL <- spTransform(agent.activities.SP, CRS(latlong))
agent.activities.SP.LL@data$PreviousLong <- coordinates(agent.activities.SP.LL)[,1]
agent.activities.SP.LL@data$PreviousLat <- coordinates(agent.activities.SP.LL)[,2]

next.coords <- cbind(Easting = as.numeric(as.character(agent.activities$Nx)), Northing = as.numeric(as.character(agent.activities$Ny)))
next.coords <- na.omit(object = next.coords)
agent.activities.SP2 <- SpatialPointsDataFrame(next.coords, data = agent.activities, proj4string = CRS("+init=epsg:27700"))
agent.activities.SP2.LL <- spTransform(agent.activities.SP2, CRS(latlong))
agent.activities.SP2.LL@data$NextLong <- coordinates(agent.activities.SP2.LL)[,1]
agent.activities.SP2.LL@data$NextLat <- coordinates(agent.activities.SP2.LL)[,2]

activities.prev.coords <- as.data.frame(agent.activities.SP.LL)
activities.prev.coords <- activities.prev.coords[,c(1:12)]
activities.next.coords <- as.data.frame(agent.activities.SP2.LL)
activities.next.coords <- activities.next.coords[,c(11:12)]
final.agent.activities <- cbind(activities.prev.coords, activities.next.coords)

#Compute distance between 2 activities
library(geosphere)
final.agent.activities$distance <- NA
for (i in 1:nrow(final.agent.activities)){
  final.agent.activities$distance[i] <- distm(c(final.agent.activities$PreviousLong[i], final.agent.activities$PreviousLat[i]), c(final.agent.activities$NextLong[i], final.agent.activities$NextLat[i]), fun = distHaversine)
}

#Calculate time since beginning of iteration
timeperiteration <- 600 # **In seconds - CHANGE depending on time per iteration in SURF!!
final.agent.activities$time <- as.numeric(final.agent.activities$Iteration) * timeperiteration

#Sort by agent ID and time
final.agent.activities <- final.agent.activities[with(final.agent.activities, order(final.agent.activities[,3], final.agent.activities[,1])), ]

#Find closest centroid to previous activity
library(raster)
previous.activity.coords <- final.agent.activities[,c(3,11:12)]
previous.activity.coords.SP <- SpatialPointsDataFrame(coords = previous.activity.coords[,c(2,3)], data = previous.activity.coords, proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
raster::shapefile(previous.activity.coords.SP, "C:\\Users\\medsthe\\Desktop\\CoordsToCentroids\\PreviousActivity2039.shp")
#Import to ArcMap along with Centroids file
#Find the closest centroid to each point
previous.activity.centroids <- readOGR(dsn = 'C:\\Users\\medsthe\\Desktop\\CoordsToCentroids', layer = 'PreviousActivityCentroids2039')
previous.activity.centroids <- as.data.frame(previous.activity.centroids)

#Find closest centroid to next activity
next.activity.coords <- final.agent.activities[,c(3,13:14)]
next.activity.coords.SP <- SpatialPointsDataFrame(coords = next.activity.coords[,c(2,3)], data = next.activity.coords, proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
raster::shapefile(next.activity.coords.SP, "C:\\Users\\medsthe\\Desktop\\CoordsToCentroids\\NextActivity2039.shp")
#Import to ArcMap along with Centroids file
#Find the closest centroid to each point
next.activity.centroids <- readOGR(dsn = 'C:\\Users\\medsthe\\Desktop\\CoordsToCentroids', layer = 'NextActivityCentroids2039')
next.activity.centroids <- as.data.frame(next.activity.centroids)

#Add centroid IDs to the original table
final.agent.activities <- cbind(final.agent.activities, previous.activity.centroids$id)
final.agent.activities <- cbind(final.agent.activities, next.activity.centroids$id)
colnames(final.agent.activities)[17] <- 'PreviousCentroidID'
colnames(final.agent.activities)[18] <- 'NextCentroidID'

#Remove pedestrians/walkers based on distance
summary(final.agent.activities$distance)
distanceold <- final.agent.activities$distance
final.agent.activities <-  mutate(final.agent.activities, decile_rank = ntile(final.agent.activities$distance,10))
final.agent.activities <- final.agent.activities[final.agent.activities$decile_rank > 2, ]
summary(final.agent.activities$distance)
distancenew <- final.agent.activities$distance
boxplot(distanceold, distancenew, col = c('red','blue'), ylab = 'Distance (m)')

#Change time so it starts from 0 
mintime <- min(final.agent.activities$time)
mintime
starttime <- 23400 #CHANGE according to beginning time of simulation (now 06:30)
final.agent.activities$time <- final.agent.activities$time - starttime

write.csv(final.agent.activities, file = "C:\\Users\\medsthe\\Desktop\\agentactivities2039.csv")




