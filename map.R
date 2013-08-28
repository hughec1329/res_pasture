# R script to spit out pretty plot
# 20130828 HCrockford

library(rgdal)
library(RColorBrewer)
mp = readOGR('PG:dbname=farms','farm_tojizz')
coll = colorRamp(c('white','green'))
mapcol = coll(mp$cover/max(mp$cover))
mapcol = cut(mp$cover,7)
ncol = 8
plot(mp,col = terrain.colors(ncol)[cut(mp$cover,ncol)])

