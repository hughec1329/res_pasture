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
library(XML)
library(rjson)

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
