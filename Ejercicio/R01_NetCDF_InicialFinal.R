#
#  Andres Sepulveda (andres.sepulveda@gmail.com) 2020/08/04
#  Andres Sepulveda (andres.sepulveda@gmail.com) 2021/10/07
# 

#rm(list=ls())
library(ncdf4)
library(geodist)

setwd("./")

inp <-nc_open('JaivaAncud_sml.nc')
lat <- ncvar_get(inp,varid ='lat')       # Dimensiones (tiempo,n_particula)
lon <- ncvar_get(inp,varid ='lon')
status <- ncvar_get(inp,varid ='status')
z <- ncvar_get(inp,varid ='z')
ptime <- ncvar_get(inp,varid ='time')
trajectory <- ncvar_get(inp,varid ='trajectory')
nc_close(inp)

latini <- c()
latend <- c()
lonini <- c()
lonend <- c()
t_ini  <- c()

for (part in 1:length(trajectory)) {
  #lat
  auxlat <- lat[,part]
  auxlat2 <-auxlat[auxlat < 1]
  latini[part] <- auxlat2[1]
  latend[part] <- auxlat2[length(auxlat2)]
  # lon
  auxlon <- lon[,part]
  auxlon2 <-auxlon[auxlon < 1]
  lonini[part] <- auxlon2[1]
  lonend[part] <- auxlon2[length(auxlon2)]
  # time
  auxtim <- ptime[which(auxlon < 1)[[1]]]
  t_ini[part] <- auxtim[1]
}

t_ini=(t_ini-t_ini[1])/3600

puntos <- read.table("PuntosJaivaAncud.txt", header = FALSE)
latp <- puntos[, c(2)]
lonp <- puntos[, c(1)]
plot(lonp,latp)

#
# Encontrar, para cada particula liberada, el punto de una lista mas cercano
#
cercalat <-c()
cercalon <-c()
dpuntos  <-c()
distap   <-c()

for (k in 1:length(lonini)) {
  pini <- c(lonini[k],latini[k])

    for (l in 1:length(lonp)) {
    auxp <- c(lonp[l],latp[l])  
    dpuntos[l] <- geodist(pini, auxp, measure = "haversine")        
  }
  cercalat[k] <- latp[which(dpuntos == min(dpuntos))[[1]]]
  cercalon[k] <- lonp[which(dpuntos == min(dpuntos))[[1]]]
  distap[k]   <- min(dpuntos)
}

dista <-c()
for (i in 1:length(lonini)) {
  pini <- c(lonini[i],latini[i])
  pend <- c(lonend[i],latend[i])
  #   colnames(pini) <- colnames(pend) <-c("lon","lat")
  dista[i]  <- geodist(pini,pend,measure="haversine")
}

#
# TODO:  Integrar distancia a lo largo de la trayectoria
#

iniend <- cbind(t_ini,cercalon,cercalat,distap, lonini,latini,lonend,latend,dista)

iniendaux <- format(iniend,digits=4, nsmall=4)

write.csv(iniendaux,'R01_InicialesFinales.csv')

par(mfrow=c(1,2),mar=c(6,5,5,3))
plot(lonini,latini,main="Inicio",xlab="Longitud"
     ,ylab="Latitud",xlim=c(-75, -72),ylim=c(-42,-41.3))
plot(lonend,latend,main="Fin",xlab="Longitud"
     ,ylab="Latitud",xlim=c(-75, -72),ylim=c(-42,-41.3))


par(mfrow=c(1,1))
plot(latini,dista/1000,main="Distancia",xlab="Latitud"
     ,ylab="Distancia [km]",xlim=c(-42,-41.3))

plot(ptime)

plot(t_ini)

#
# TODO: Las particulas que viajan mucho, quedan cerca de la costa?
#


hist(dista/1000,main="",xlab = "Distancia [km]",ylab = "%",freq = TRUE)
