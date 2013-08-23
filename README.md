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

## deliverey
- pretty displaying?? leaflet js library via slidify/shiny webapp.
- scrape pasture satellite data - update padocks automagically.
- established solution?? - reinventing wheel of othe ag software? - need to research and ask hambo
- using qgis can digitise hand drawn maps w gmaps satelite overvie - autocalc area.
- http://www.ga.gov.au/webtemp/image_cache/GA20950.pdf
- then how store multiple repeated observations for each paddock?? PostGIS?

## DB design
- RDB design - table for each cocky w each paddock as polygon in vector layer?
- paddock observations:

FarmerID  |  paddockID  |  date  |  level  |  notes
--------------|-----------------|--------|---------|---------
10

etc.

- unique - foreign key - paste(farmerID,paddockID) - 

