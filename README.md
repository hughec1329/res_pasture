# automated pasture mapping project

## data collection
- fulcrum app - $29 month for licence - get gps then play?
- data collection - better than epicollect?? slicker less bakcground work/
- gps - phone accurate enough? may need handheld gps to do inital paddock walk and establish fencelines then go from there.
- can make shapefiles, load maps locally on tablet using tile mill (OS mapbox format used by map stored in sqlite db)
- maybe use quantum gis to manage shapefiles collected of tablet or gps - stored as postGIS

## workflow - geolocating readings -> paddock
- ideally fulcrum be able to edit attributres off shapefile polygon you're currently in, 
- if not R script to match data points collected for each paddock to polygon - update history and 

- tilemill can import shapefiles from postgis - with custom styling e.g. color for last weeks growth.


### WATCH projcection!!
- use projected in qgis to get area in metres.
- UTM zone 55 east of ~ lorne = JUC
- UTM zone 54 west of lorne - WARRNAMBOOL
- http://www.fossworkflowguides.com/gis/tutorials/00007/
- of GDA94 - http://www.dse.vic.gov.au/property-titles-and-maps/geodesy/geocentric-datum-of-australia-gda

## deliverey
- pretty displaying?? leaflet js library via slidify/shiny webapp.
- scrape pasture satellite data - update padocks automagically.
- established solution?? - reinventing wheel of othe ag software? - need to research and ask hambo
- using qgis can digitise hand drawn maps w gmaps satelite overvie - autocalc area.
- http://www.ga.gov.au/webtemp/image_cache/GA20950.pdf
- then how store multiple repeated observations for each paddock?? PostGIS?

#POSTGIS
- set up succesfully alahttps://the-free-qgis-training-manual.readthedocs.org/en/latest/postgis/index.html

## DB design
- DB design - 
1.	farmer: 

fid (PKEY)  | name | location (spatial)  | farm poly (union of paddock poly??) | total area (ST_area from paddock poly) | notes
------------|------|---------------------|-------------------------------------|----------------------------------------|------

2.	paddock:

fid (PKEY) | pid (PKEY) | poly(spatial) | area (ST_area) | recent cover (most recent observation from 3.) | recent notes
-----------|------------|---------------|----------------|------------------------------------------------|-------------

3.	observations:

FarmerID  |  paddockID  |  date  |  level  |  notes
----------|-------------|--------|---------|-------


- unique - foreign key - paste(farmerID,paddockID) ?? 

## Drawing maps: tile mill
- can script -/usr/share/tilemill/index.js export --help
- load standard cartoCSS - from ~/Documents/MapBox/project/farms
- but use postgis layer?? 

### styling
- best with transperent polygon and no bakcgrond - then can have underlayer of gogle earth
- style.mss to have conditional color and labels of paddock id, (paddock cover)
