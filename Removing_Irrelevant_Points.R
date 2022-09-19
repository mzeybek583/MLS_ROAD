### This is an R code to remove irrelevant points in MLS based point cloud

### clear lines in Console and all variable in R environment
rm(list = ls())
cat("\f")

ID <- 3 #This is the test area ID
### Set path directions to load input and save output
# Path to load inputs
Path1 <- paste0("/Users/serkanbicici/Desktop/Pre-processing/Inputs/Test Area", ID)
# Path to save outputs
Path2 <- paste0("/Users/serkanbicici/Desktop/Pre-processing/Outputs/Test Area", ID)
Path3 <- paste0("/Users/serkanbicici/Desktop/Pre-processing/Processing Times/Test Area", ID)

library(rgdal)
library(raster)
library(rgeos)
library(lidR)

### set processing time
time <- proc.time()

### Step1: Loading vehicle trajectory
setwd(Path1)
traj <- readOGR("VehicleTrajectory.shp")

### Step2: Loading original data
setwd(Path1)
pcl <- readLAS(files = "Original_Data.las")

### Step3: Buffering vehicle trajectory 
traj.buff <- buffer(traj, width=10, dissolve=TRUE)
buffer <- traj.buff@polygons[[1]]@Polygons[[1]]@coords #sp object of class Polygon
setwd(Path2)
shapefile(traj.buff, filename='Veh_traj.buffer.shp', overwrite=TRUE)

### Step4: Clipped the original data using buffered vehicle trajectory
clipped.las <- clip_polygon(pcl,buffer[,1],buffer[,2])
setwd(Path2)
writeLAS(clipped.las, "Buffered_Data.las")

## Step5: Classification Step (Parameters chosen mainly for speed)
mycsf <- csf(FALSE, 0.1, 0.2, rigidness = 1, time_step = 0.65)
CSF1 <- classify_ground(clipped.las, mycsf)
setwd(Path2)
writeLAS(CSF1, "CSF_Results.las")

## Step6: Removing non-ground points
ground.df <- lasfilterground(las = CSF1)
setwd(Path2)
writeLAS(ground.df, "GroundPoints.las")

# Read processing time
setwd(Path3)  
t<-format(round((proc.time()-time)[3], 2), nsmall = 2)
write.csv(t, file = paste0("Step1.txt"), row.names = FALSE) 


# ## Producing plots
# plot(traj, axes=T, col = "lightgreen")
# plot(pcl)
# plot(traj.buff, axes=T,col = "red", lwd = 0.1 , lty=2)
# plot(clipped.las)
# plot(CSF1, color = "Classification")
# plot(ground.df)
