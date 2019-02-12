# ----------------------------------------------------------------------
# METADATA EXPORT INTO XML WITH GEOMETA LIBRARIE
# author : Christine Plumejeaud / LIENSS (using  Juliette Fabre / OSU OREME)
# creation : 2018/10/29
# last update : 2019/02/10
# -----------------------------------------------------------------------

# The script extracts all metadata from an Excel file and formats them into ISO19115 with geometa library, 
# The script is based on the geometa ISOMetadata example (see geometa documentation) and geonapi example (see geonapi documentation)

# Emmanuel Blondel. (2018, August 22). geometa: Tools for Reading and Writing ISO/OGC Geographic Metadata in R (Version 0.3). Zenodo. http://doi.org/10.5281/zenodo.1402245
# Blondel, Emmanuel. (2018, April 27). geonapi: R Interface to GeoNetwork API (Version 0.1-0). Zenodo. http://doi.org/10.5281/zenodo.1345013

# SCRIPT PROGRESS
# ---------------

# - extract metadata from all views <my_schema>.<my_view> that contain at least the following fields :
#   - resource_identifier (home-made identifier)
#   - parent_identifier = identifier of the parent dataset when series
#   - status (ex: onGoing / completed)
#   - title
#   - abstract
#   - resource_type (= dataset or series)
#   - spatialRepresentationType : vector, raster, etc.
#   - resource_language (= eng | fra) 
#   - creation_date of the metadata
#   - publish_date of the metadata
#   - update_date of the metadata
#   - resource_format (= tableDigital | mapDigital | ...)
#   - update_frequency of the DATA (ex: continual / notPlanned)
#   - temporal_extent_name of the DATA
#   - start_date of the DATA : you can write 28/02/2019, it will be converted in "2019-02-28" by the program
#   - end_date of the DATA : you can write 28/02/2019, it will be converted in "2019-02-28" by the program
#   - spatial_extent_name of the data
#   - geom = geometry WKT (eg in postgis: st_astext(st_envelope(st_convexhull(st_collect(geom)))) )
#   - reference_system (EPSG code, eg: 4326)
#   - topic_categories  = list of topics separated with , (= environment, geoscientificInformation)
#   - inspire_themes = list of <keyword>---<uri> separated with ,
#   - gemet_keywords = list of <keyword>---<uri> separated with ,
#   - agrovoc_keywords = list of <keyword>---<uri> separated with ,
#   - other_keywords = list of keywords separated with ,
#   - md_contact (responsible) = list of <name, first name>---<organisation>---<email> separated with ;
#   - lineage
#   - use_condition = list of use conditions separated with ---
#   - online_resource = list of <url>---<description> separated with ,
#   - thumbnail_url (thumbnail url)
#   - wms_resource = list of <wms_url>---<layer_name>---<description> separated with ,

#Codes list ISO 19115	
	#https://geo-ide.noaa.gov/wiki/index.php?title=ISO_19115_and_19115-2_CodeList_Dictionaries#CI_PresentationFormCode
	#http://inspire-regadmin.jrc.ec.europa.eu/dataspecification/ScopeObjectDetail.action;jsessionid=D5583D5100D9DBE9BD2137CEBB2398B9?objectDetailId=11859
	
#INSPIRE topic categories	
	#en anglais	UNIQUEMENT
	#http://inspire.ec.europa.eu/metadata-codelist/TopicCategory
	#farming', 'biota', 'boundaries', 'climatologyMeteorologyAtmosphere', 'economy', 'elevation', 'environment', 'geoscientificInformation', 'health', 'imageryBaseMapsEarthCover', 'intelligenceMilitary', 'inlandWaters', 'location', 'oceans', 'planningCadastre', 'society', 'structure', 'transportation', 'utilitiesCommunication'
#Thèmes inspires	
	#http://inspire.ec.europa.eu/theme/lc
#GEMET keywords	
	#https://www.eionet.europa.eu/gemet/fr/inspire-theme/nz
#EnvThese: for otherKeywords
	#http://vocabs.ceh.ac.uk/evn/tbl/envthes.evn
	
#########################################################################################
## init
#########################################################################################

# Get arguments
dir <- cleanargs[regexpr("-d=", args)>0]

# Configure lib path of local run
.libPaths(c( .libPaths(), "D:/Dev/R") )

## Directory containing both CSV files defining metadata and contact (CSV format, encoded in UTF8 is expected)
## Répertoire où se situe les fichiers CSV de métadonnées et contacts
metadatadir <- "D:/Travail/OwnCloud/Zone Atelier PVS/QRcode/QRcode_3/Metadata/Cours_atelier_R_MD/ZATU/"
## Répertoire où seront exportées les fichiers XML de métadonnées
exportxml_dir <- "D:/Travail/OwnCloud/Zone Atelier PVS/QRcode/QRcode_3/Metadata/Cours_atelier_R_MD/Export_XML/"

## Set the prefix you wish to find easily your metadatafiles
##Prefix des fiches de métadonnées
prefix <- "ZATU"

setwd(metadatadir)
getwd()


# LOAD LIBRARIES
library(XML)
library(geometa)
library(uuid)
library(rgeos)
library(gdata) #For trim

#########################################################################################
## open sources
#########################################################################################

# SELECT METADATA
# homemade function to extract all records of Excel files exported in CSV and encoded in UTF-8 
metadata <- read.csv(paste0(metadatadir,"metadata_ISO19115_pour_scriptR-ZATU-V3_3_prepared_metadata2.csv"), sep=";", dec=".", stringsAsFactors=FALSE)
contacts <- read.csv(paste0(metadatadir,"metadata_ISO19115_pour_scriptR-ZATU-V3_3_prepared_contacts.csv"), sep=";", dec=",", stringsAsFactors=FALSE)

colnames(metadata)
 [1] "resource_identifier"       "parent_identifier"        
 [3] "status"                    "title"                    
 [5] "abstract"                  "resource_type"            
 [7] "spatialRepresentationType" "resource_language"        
 [9] "creation_date"             "publish_date"             
[11] "update_date"               "resource_format"          
[13] "update_frequency"          "temporal_extent_name"     
[15] "start_date"                "end_date"                 
[17] "spatial_extent_name"       "geom"                     
[19] "reference_system"          "topic_categories"         
[21] "inspire_themes"            "gemet_keywords"           
[23] "other_keywords"            "md_contact"               
[25] "lineage"                   "use_condition"            
[27] "online_resource"           "thumbnail_url"            
[29] "wms_resource"             "uuid"

nrow(metadata)
#12

head(metadata)

colnames(contacts)
 [1] "electronicMailAddress"    "organisationName"        
 [3] "positionName"             "Name"                    
 [5] "firstname"                "deliveryPoint"           
 [7] "city"                     "administrativeArea"      
 [9] "postalCode"               "country"                 
[11] "voice"                    "facsimile"               
[13] "setNameISOOnlineResource" "ISOOnlineResource" 


nrow(contacts )
5

head(contacts )

convertDate <- function(date){
	#date <- "19/08/2015"
   result <- date
   startdate_list <- trim(strsplit(date, '/'))[[1]]
   if (length(startdate_list) > 1 & nchar(startdate_list[3])==4) {
	#Convertir la date
	result <- as.POSIXct(paste(startdate_list[3], startdate_list[2], startdate_list[1], sep="-"))
   } else {
	result  <- as.POSIXct(date)
   }
   return (result)
}


#########################################################################################
## create XML metadata files
#########################################################################################

metadata$uuid <- ''

# For temporalExtent XSD validation in GN
ISOMetadataNamespace[["GML"]]$uri <- "http://www.opengis.net/gml"
i<- 1

for(i in 1:nrow(metadata))
{
  
  cat(paste0('<b>--------- ', metadata$resource_identifier[i],'</b>\n'))
  md <- ISOMetadata$new()
  
  # ------------------------------------
  # METADATA SECTION
  # ------------------------------------
  
  # MD identifier
  resource_identifier <- metadata$resource_identifier[i]
  
  uuid <- UUIDgenerate()
  md_identifier <- paste(prefix, uuid, sep = "_")
  ## Check if the metadata have already been inserted into GN or not
  #if(nrow(gn_records) && resource_identifier %in% gn_records$oreme_identifier) md_identifier <- gn_records$md_identifier[gn_records$oreme_identifier == resource_identifier] else md_identifier <- UUIDgenerate()
  metadata$uuid[i] <- md_identifier
  md$setFileIdentifier(md_identifier)

  # Parent Uuid
  md$setParentIdentifier(metadata$parent_identifier[i])
  
  md$setDataSetURI(resource_identifier)
  
  md$setLanguage(metadata$resource_language[i])
  md$setCharacterSet("utf8")
  mdDate <- Sys.time()
  md$setDateStamp(mdDate)
  md$setMetadataStandardName("ISO 19115:2003/19139")
  md$setMetadataStandardVersion("1.0")
  
  # HierarchyLevel
  md$setHierarchyLevel(tolower(metadata$resource_type[i]))
  
  # Metadata contacts : role1 = email2; role2 = email2; etc...
  contact_list <- trim(strsplit(metadata$md_contact[i], ';'))[[1]]
  for(c in contact_list)
  {
	print(c)
	role=(strsplit(c, '='))[[1]][1]
	email=(strsplit(c, '='))[[1]][2]

	#electronicMailAddress	organisationName	positionName	Name	firstname	deliveryPoint	city	administrativeArea	postalCode	country	
	#voice	facsimile	setNameISOOnlineResource	ISOOnlineResource

	org <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$organisationName
	name <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$Name
	deliveryPoint <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$deliveryPoint
	city <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$city
	postalCode <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$postalCode
	country <- 	contacts[which(trim(contacts$electronicMailAddress) == email), ]$country

	rp <- ISOResponsibleParty$new()
      rp$setIndividualName(name)
      rp$setOrganisationName(org)
	rp$setRole(role)
	contact <- ISOContact$new()
    
	isoaddress <- ISOAddress$new()
	isoaddress$setEmail(email)
      isoaddress$setDeliveryPoint(paste(deliveryPoint, country))
	isoaddress$setCity (city )
	isoaddress$setPostalCode (postalCode )
	isoaddress$setCountry (country )
    
	contact$setAddress(isoaddress)
	rp$setContactInfo(contact)
	md$addContact(rp)
  }
  

  # ------------------------------------
  # REFERENCE SYSTEM SECTION
  # ------------------------------------
  
  RS <- ISOReferenceSystem$new()
  RSId <- ISOReferenceIdentifier$new(code = toString(metadata$reference_system[i]), codeSpace = "EPSG")
  RS$setReferenceSystemIdentifier(RSId)
  md$setReferenceSystemInfo(RS)
  


  # ------------------------------------
  # IDENTIFICATION SECTION
  # ------------------------------------
  
  IDENT <- ISODataIdentification$new()
  
  # Abstract
  abstract <- metadata$abstract[i]
	
  IDENT$setAbstract(abstract) 
  
  IDENT$setLanguage(metadata$resource_language[i])
  IDENT$setCharacterSet("utf8") ## Tester latin 1
  
  # Topic categories metadata$topic_categories
  topic_list <- trim(unlist(strsplit(metadata$topic_categories[i], ',')))
  for(t in topic_list) IDENT$addTopicCategory(t)
  
  # Status
  IDENT$addStatus(metadata$status[i])
  
  # Metadata contacts : role1 = email2; role2 = email2; etc...
  contact_list <- trim(strsplit(metadata$md_contact[i], ';'))[[1]]
  for(c in contact_list)
  {
	print(c)
	role=(strsplit(c, '='))[[1]][1]
	email=(strsplit(c, '='))[[1]][2]

	#electronicMailAddress	organisationName	positionName	Name	firstname	deliveryPoint	city	administrativeArea	postalCode	country	
	#voice	facsimile	setNameISOOnlineResource	ISOOnlineResource

	org <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$organisationName
	name <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$Name
	deliveryPoint <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$deliveryPoint
	city <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$city
	postalCode <- contacts[which(trim(contacts$electronicMailAddress) == email), ]$postalCode
	country <- 	contacts[which(trim(contacts$electronicMailAddress) == email), ]$country

	rp <- ISOResponsibleParty$new()
      rp$setIndividualName(name)
      rp$setOrganisationName(org)
	rp$setRole(role)
	contact <- ISOContact$new()
    
	isoaddress <- ISOAddress$new()
	isoaddress$setEmail(email)
      isoaddress$setDeliveryPoint(paste(deliveryPoint, country))
	isoaddress$setCity (city )
	isoaddress$setPostalCode (postalCode )
	isoaddress$setCountry (country )
    
	contact$setAddress(isoaddress)
	rp$setContactInfo(contact)
	IDENT$addPointOfContact(rp)
  }
   
  
  # Title
  ct <- ISOCitation$new()
  ct$setTitle(metadata$title[i])
  
  iso_date <- ISODate$new()
  iso_date$setDate(mdDate)
  iso_date$setDateType("revision")
  ct$addDate(iso_date)
  
  if(!is.na(metadata$creation_date[i]))
  {
    iso_date <- ISODate$new()
    iso_date$setDate(convertDate(metadata$creation_date[i]))
    iso_date$setDateType("creation")
    ct$addDate(iso_date)
  }
  
  ct$setEdition("1.0")
  ct$setEditionDate(as.Date(mdDate))
  ct$setIdentifier(ISOMetaIdentifier$new(code = md_identifier))
  IDENT$setCitation(ct)
  
  # Thumbnail
  if(!is.na(metadata$thumbnail_url[i]))
  {
    v <- lapply(strsplit(metadata$thumbnail_url[i], ''), function(x) which(x == '.')) [[1]];
    extension <- substring(metadata$thumbnail_url[i], v[length(v)]+1);
    go <- ISOBrowseGraphic$new(
      fileName = metadata$thumbnail_url[i],
      fileDescription = "Thumbnail",
      ## fileType = paste0("image/", get_file_ext(get_file_without_path(metadata$thumbnail_url[i])))
	## Recoder cette partie avec cet exemple : metadata$thumbnail_url[i] = "www.toto.fr/monimage.jpg"
	fileType = paste0("image/", extension)

    )
    IDENT$addGraphicOverview(go)
  }
  
  # Maintenance information
  mi <- ISOMaintenanceInformation$new()
  mi$setMaintenanceFrequency(metadata$update_frequency[i])
  IDENT$setResourceMaintenance(mi)
  
  # Legal constraint(s)
  lc <- ISOLegalConstraints$new()
  use_conditions <- trim(unlist(strsplit(metadata$use_condition[i], '---')))
  if(!is.na(metadata$use_condition[i])) {
	for(use in use_conditions) {
		lc$addUseLimitation(use)
		lc$addAccessConstraint("copyright")
  		lc$addAccessConstraint("license")
  		lc$addUseConstraint("copyright")
  		lc$addUseConstraint("license")
	}
  } else {
  	## Ajout de CC BY 4.0 par défaut
   	lc$addUseLimitation('This work is licensed under a Creative Commons Attribution 4.0 License (CC BY 4.0, https://creativecommons.org/licenses/by/4.0).')
  	lc$addAccessConstraint("copyright")
  	lc$addAccessConstraint("license")
  	lc$addUseConstraint("copyright")
  	lc$addUseConstraint("license")
  }
  IDENT$setResourceConstraints(lc)
  

  # Spatial extent
  if(!is.na(metadata$geom[i]))
  {
    extent <- ISOExtent$new()
    spatial_extent <- readWKT(metadata$geom[i])
    xmin <- spatial_extent@bbox[1,1]
    xmax <- spatial_extent@bbox[1,2]
    ymin <- spatial_extent@bbox[2,1]
    ymax <- spatial_extent@bbox[2,2]
    if(xmin == xmax)
    {
      xmin <- xmin - 0.001
      xmax <- xmax + 0.001
    }
    if(ymin == ymax)
    {
      ymin <- ymin - 0.001
      ymax <- ymax + 0.001
    }
    spatialExtent <- ISOGeographicBoundingBox$new(minx = xmin, miny=ymin, maxx=xmax, maxy=ymax)
    extent$setGeographicElement(spatialExtent)
    IDENT$addExtent(extent)
  }
  
  # Temporal extent
  if(!is.na(metadata$start_date[i])) 
  {
    extent <- ISOExtent$new()
    time <- ISOTemporalExtent$new()

    start_date <- convertDate (metadata$start_date[i])
    if(!is.na(metadata$end_date[i]) ) {
	end_date <- convertDate (metadata$end_date[i]) 
	if (as.double(end_date - start_date, units = "secs") == 0) {
		end_date <- end_date + 1
	}
    } else end_date <- as.POSIXct(Sys.Date())
    print(end_date)
    temporalExtent <- GMLTimePeriod$new(beginPosition = start_date, endPosition = end_date)
    ## Note : ISOTemporalExtent.setTimeInstant is not yet implemented.
    ## https://github.com/eblondel/geometa/blob/master/R/ISOTemporalExtent.R     
    time$setTimePeriod(temporalExtent)
    extent$setTemporalElement(time)
    IDENT$addExtent(extent)
  }
  
  # Keywords
  inspire_themes <- trim(unlist(strsplit(metadata$inspire_themes[i], ',')))
  gemet_keywords <- trim(unlist(strsplit(metadata$gemet_keywords[i], ',')))
  #agrovoc_keywords <- trim(unlist(strsplit(metadata$agrovoc_keywords[i], ',')))
  other_keywords <- c()
  if (!is.na(metadata$other_keywords[i]))
    other_keywords <- trim(unlist(strsplit(metadata$other_keywords[i], ',')))
  
  if(!all(is.na(inspire_themes)))
  {
    kwd1 <- ISOKeywords$new()
    for(k in inspire_themes)
    {
      anc1 <- ISOAnchor$new(name = strsplit(k, '---')[[1]][1], href = strsplit(k, '---')[[1]][2])
      kwd1$addKeyword(anc1)
    }
    kwd1$setKeywordType("theme")
    th <- ISOCitation$new()
    th_ref <- ISOAnchor$new(name = "GEMET - INSPIRE themes, version 1.0", href="http://www.eionet.europa.eu/gemet/inspire_themes")
    th$setTitle(th_ref) 
	## Message d'erreur : is.na pour un objet non list ni vecteur
    inspire_date <- ISODate$new()
    inspire_date$setDate("2008-06-01")
    inspire_date$setDateType("publication")
    th$addDate(inspire_date)
    kwd1$setThesaurusName(th)
    IDENT$addKeywords(kwd1)
  }
  if(!all(is.na(gemet_keywords)))
  {
    kwd2 <- ISOKeywords$new()
    for(k in gemet_keywords)
    {
      anc1 <- ISOAnchor$new(name = strsplit(k, '---')[[1]][1], href = strsplit(k, '---')[[1]][2])
      kwd2$addKeyword(anc1)
    }
    kwd2$setKeywordType("theme")
    th <- ISOCitation$new()
    th$setTitle("GEMET")
    gemet_date <- ISODate$new()
    gemet_date$setDate("2010-01-13")
    gemet_date$setDateType("publication")
    th$addDate(gemet_date)
    kwd2$setThesaurusName(th)
    IDENT$addKeywords(kwd2)
  }

  if(!all(is.na(other_keywords)))
  {
    kwd4 <- ISOKeywords$new()
    for(k in other_keywords) kwd4$addKeyword(k)
    kwd4$setKeywordType("theme")
    IDENT$addKeywords(kwd4)
  }
  
  # Spatial representation type
  IDENT$addSpatialRepresentationType(metadata$spatialRepresentationType[i])
  
  
  md$setIdentificationInfo(IDENT)
  
  # ------------------------------------
  # DISTRIBUTION SECTION
  # ------------------------------------
  
  # Online resources
  distrib <- ISODistribution$new()
  dto <- ISODigitalTransferOptions$new()
  online_resource_list <- strsplit(metadata$online_resource[i], ',')[[1]]
  if(!all(is.na(online_resource_list))) {
  for(o in 1:length(online_resource_list))
  {
    link <- trim(online_resource_list[o])

    url <- strsplit(link, '---')[[1]][1]
    name <- strsplit(link, '---')[[1]][2]
    if(! is.na(name) & name != 'Associated DOI')
    {
      newURL <- ISOOnlineResource$new()
      newURL$setLinkage(url)
      newURL$setName(name)
      newURL$setDescription(name)
      newURL$setProtocol("WWW:LINK-1.0-http--link")
      dto$addOnlineResource(newURL)
    } else if (is.na(name)) {
    	newURL <- ISOOnlineResource$new()
      newURL$setLinkage(url)
      newURL$setName(metadata$title[i])
	newURL$setDescription(metadata$title[i])
	newURL$setProtocol("WWW:LINK-1.0-http--link")
	dto$addOnlineResource(newURL)
    } 
  }
  }
  if(!is.na(metadata$wms_resource[i]))
  {
    wms_resource_list <- strsplit(metadata$wms_resource[i], ',')[[1]]
    for(wms in 1:length(wms_resource_list))
    {
      link <- trim(wms_resource_list[wms])
      url <- strsplit(link, '---')[[1]][1]
      name <- strsplit(link, '---')[[1]][2]
      desc <- strsplit(link, '---')[[1]][3]
      newURL <- ISOOnlineResource$new()
      newURL$setLinkage(url)
      if (! is.na(name)) {
		newURL$setName(name)
	} else newURL$setName(metadata$title[i])
      if (! is.na(desc)) {
		newURL$setDescription(desc)
	} else newURL$setDescription(metadata$title[i])
      newURL$setProtocol("OGC:WMS")
      dto$addOnlineResource(newURL)
    }
  }
  distrib$setDigitalTransferOptions(dto)
  
  # Format
  format <- ISOFormat$new()
  format$setName(metadata$resource_format[i]) # CI_PresentationFormCode
	## BIDON ! 
  format$setVersion("v1.1") #metadata$version_format[i]
  distrib$addFormat(format)
  
  md$setDistributionInfo(distrib)
  
  # ------------------------------------
  # DATA QUALITY
  # ------------------------------------
  
  dq <- ISODataQuality$new()
  scope <- ISOScope$new()
  scope$setLevel("dataset")
  dq$setScope(scope)
  
  # Lineage
  lineage <- ISOLineage$new()

  info <- metadata$lineage[i]

  
  lineage$setStatement(info)
  dq$setLineage(lineage)
  
  # INSPIRE - interoperability of spatial data sets and services
  dc_inspire1 <- ISODomainConsistency$new()
  cr_inspire1 <- ISOConformanceResult$new()
  cr_inspire_spec1 <- ISOCitation$new()
  cr_inspire_spec1$setTitle("Commission Regulation (EU) No 1089/2010 of 23 November 2010 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards interoperability of spatial data sets and services")
  cr_inspire1$setExplanation("See the referenced specification")
  cr_inspire_date1 <- ISODate$new()
  cr_inspire_date1$setDate(ISOdate(2010,12,08))
  cr_inspire_date1$setDateType("publication")
  cr_inspire_spec1$addDate(cr_inspire_date1)
  cr_inspire1$setSpecification(cr_inspire_spec1)
  cr_inspire1$setPass(TRUE)
  dc_inspire1$addResult(cr_inspire1)
  dq$addReport(dc_inspire1)
  
  # INSPIRE - metadata
  dc_inspire2 <- ISODomainConsistency$new()
  cr_inspire2 <- ISOConformanceResult$new()
  cr_inspire_spec2 <- ISOCitation$new()
  cr_inspire_spec2$setTitle("COMMISSION REGULATION (EC) No 1205/2008 of 3 December 2008 implementing Directive 2007/2/EC of the European Parliament and of the Council as regards metadata")
  cr_inspire2$setExplanation("See the referenced specification")
  cr_inspire_date2 <- ISODate$new()
  cr_inspire_date2$setDate(ISOdate(2008,12,3))
  cr_inspire_date2$setDateType("publication")
  cr_inspire_spec2$addDate(cr_inspire_date2)
  cr_inspire2$setSpecification(cr_inspire_spec2)
  cr_inspire2$setPass(TRUE)
  dc_inspire2$addResult(cr_inspire2)
  dq$addReport(dc_inspire2)
  
  md$addDataQualityInfo(dq)
  
  # ------------------------------------
  # EXPORT METADATA IN XML 
  # ------------------------------------
  file_name <- paste0(exportxml_dir, "/", resource_identifier, ".xml")
  print(file_name)
  cat(saveXML(md$encode(), file_name, encoding = 'UTF-8', indent = T))
 }

