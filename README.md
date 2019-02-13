# metadataReasy
Make your XML metadata files from Excel file using R (library geometa)

See : https://github.com/eblondel/geometa/wiki
See : https://cran.r-project.org/web/packages/geometa/index.html

---

## In the script, change the 3 config variables : 

### Directory containing both CSV files defining metadata and contact (CSV format, encoded in UTF8 is expected)
### Répertoire où se situe les fichiers CSV de métadonnées et contacts
metadatadir <- "D:/Travail/OwnCloud/Zone Atelier PVS/QRcode/QRcode_3/Metadata/Cours_atelier_R_MD/ZATU/"

### Répertoire où seront exportées les fichiers XML de métadonnées
exportxml_dir <- "D:/Travail/OwnCloud/Zone Atelier PVS/QRcode/QRcode_3/Metadata/Cours_atelier_R_MD/Export_XML/"

### Set the prefix you wish to find easily your metadata files
### Prefix des fiches de métadonnées
prefix <- "ZATU"

---

ZATU.zip : a zip containing an xlsx file that can be easily filled in by users ; this is an example coming from Zone Atelier Territoire Uranifère. 
- 2 CSV files are exported : metadata2.csv and contacts.csv that are read by R program (Excel_metadata.R) to build XML metadata files. 
- XML outputs are then fixed for UTF_8 encoding using python (convertEncoding.py) 
- then XML fixed are validated and uploaded in geonetwork : http://collec-za.org:8080/geonetwork/srv/fre/catalog.edit#/board
Search for ZATU.
