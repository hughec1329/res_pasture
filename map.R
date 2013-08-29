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

# read in json and see how we did
library(RCurl)
library(rjson)
library(RPostgreSQL)

id = '01c1d934-696f-461d-b486-a7eaec126a8c' # form id for 'survey' i
# get from curl -H "X-ApiToken: c8490d70abe32c668f9aec635cca036aae1f5a13fbc47cdcfae422f1f0f2b930" https://api.fulcrumapp.com/api/v2/forms
dat = as.numeric(as.POSIXct(Sys.Date(),tz = 'UTC') - 10*60*60) # get data collected since midnight 
urll = paste('https://api.fulcrumapp.com/api/v2/records','?updated_since=',dat,'&form_id=', id,sep = "")
header = c('X-ApiToken'  =  'c8490d70abe32c668f9aec635cca036aae1f5a13fbc47cdcfae422f1f0f2b930')

ret = getURL(urll, httpheader = header)
js = fromJSON(ret)
res = sapply(1:length(js$records),function(i) { 
       		datt =  as.POSIXct(strptime(js$records[[i]]$created_at,format = '%Y-%m-%dT%H:%M:%SZ'),tz = 'GMT')
	 	attributes(datt)$tzone = 'Australia/Melbourne'
	c(	dat = datt,
	 	lat = js$records[[i]]$latitude,
		lon = js$records[[i]]$longitude,
		cover = js$records[[i]]$form_values[[2]],
		comment = js$records[[i]]$form_values[[1]])
})
rest = data.frame(t(res),stringsAsFactors = F)
rest$dat = as.POSIXct(as.numeric(rest$dat),origin = "1970-01-01")
rest$cover = as.numeric(rest$cover)

# connect to postgis
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="farms")

# write table to postgis
dbWriteTable(con,'obs',rest,row.names = F)
# add spatial points
dbGetQuery(con,'ALTER TABLE obs ADD COLUMN the_geom GEOGRAPHY;')
dbGetQuery(con,"UPDATE obs SET the_geom = ST_GeometryFromText('POINT(' || lon || ' ' || lat || ')',4326)")
dbGetQuery(con,'ALTER TABLE obs DROP COLUMN lat;')
dbGetQuery(con,'ALTER TABLE obs DROP COLUMN lon;')
# do spatial join.
out = dbGetQuery(con, 'SELECT p.fid, p.pid, s.cover, s.comment FROM farm_tojizz p, obs s WHERE ST_INTERSECTS(p.geom,s.the_geom) ORDER BY cover DESC;')

dbGetQuery(con, 'DROP TABLE obs')
