# 20130829 HCrockford

# R function to: 
## pull recent observations, 
## write to postgis
## pull spatial join
## update table observations.

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
		cover = js$records[[i]]$form_values[[1]],
		notes = js$records[[i]]$form_values[[2]])
})
rest = data.frame(t(res),stringsAsFactors = F)
rest$dat = as.POSIXct(as.numeric(rest$dat),origin = "1970-01-01")
rest$cover = as.numeric(rest$cover)

# connect to postgis
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="farms")
# write table to postgis
dbWriteTable(con,'obs',rest)
# add spatial points
dbGetQuery(con,'ALTER TABLE obs ADD COLUMN geom GEOMETRY;')
dbGetQuery(con,"UPDATE obs SET geom = ST_GeometryFromText('POINT(' || lon || ' ' || lat || ')',4326)") # have to import as long lat
dbGetQuery(con,"UPDATE obs SET geom = ST_Transform(geom, 3111)") # then transform to projected
dbGetQuery(con,'ALTER TABLE obs DROP COLUMN lat;')
dbGetQuery(con,'ALTER TABLE obs DROP COLUMN lon;')
dbGetQuery(con,'ALTER TABLE obs RENAME "row.names" to obsno;')
# do spatial join.
out = dbGetQuery(con, 'SELECT s.dat as date, p.fid, p.pid, s.cover, s.notes FROM juc_farms p, obs s WHERE ST_INTERSECTS(p.geom,s.geom) ORDER BY pid;')

write.csv(out,file = paste(Sys.Date(),unique(out$fid), 'obs', sep = '_'),row.names = F)
dbGetQuery(con, 'INSERT INTO observations SELECT s.dat as date, p.fid, p.pid, s.cover, s.notes, s.geom FROM juc_farms p, obs s WHERE ST_CONTAINS(p.geom,s.geom) ORDER BY pid;')

dbGetQuery(con, 'DROP TABLE obs')

#####
### SHECKING
#####
#check results - need to do this before write DB?
print(ifelse(nrow(out) == nrow(rest),paste('succesfully imported',nrow(rest),'paddock observations'), 'WARNING: some paddocks not matched'))

int = dbGetQuery(con, 'select obsno, pid ,ST_WITHIN(o.geom,p.geom) as inside from obs o,juc_farms p;')
success = dcast(int,obsno ~ .,sum)

print(paste('succes observations: ' ,paste(success$obsno[success[,2] == 1],sep = ',', collapse =  ' ')))
print( paste('missed observations: ' ,paste(success$obsno[success[,2] == 0],sep = ',', collapse =  ' ')))
print( paste('double observations: ' ,paste(success$obsno[success[,2] > 1],sep = ',', collapse =  ' ')))


dbGetQuery(con, 'SELECT select obsno, pid ,ST <- DISTANCE(o.geom,p.geom) as dist from obs o,juc_farms p ORDER BY dist;')

# check for double observations
if(sum(duplicated(out$pid)) != 0){
	print('one or more paddocks duplicated')
	print(out[duplicated(out$pid),])
} else {
	print('no duplicates detected')
}


# drops rows that dont have geolocation - try nearest neighbour.
# allows duplicate observations - stop if same day??
