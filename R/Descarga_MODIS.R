# Creando directorio principal --------------------------------------------
rm(list=ls())
Encoding = "UTF-8"
setwd("~/")
getwd()
print("Creando directorios...")
if(dir.exists("~/_Descarga_Datos/")==FALSE){
  dir.create("~/_Descarga_Datos/")
}


# Earthdata

# Packages  ---------------------------------------------------------------

if(!require(MODIS)){
  install.packages("MODIS")
  require(MODIS)}else{library(MODIS)}
if(!require(sf)){
  install.packages("sf")
  require(sf)}else{library(sf)}
if(!require(rgdal)){
  install.packages("rgdal")
  require(rgdal)}else{library(rgdal)}
if(!require(rgdal)){
  install.packages("svDialogs")
  require(svDialogs)}else{library(svDialogs)}


# OSGEO -----------------------------------------------------------------------

winDialog("ok", "Comenzando el procesamiento de datos MOD16A2.")

if(dir.exists("C:/OSGeo4W64/bin/")==FALSE){
  stop(winDialog("ok","Debe instalar OSGEO4W para las liberías de GDAL/OGR:
       https://trac.osgeo.org/osgeo4w/"))}else{"GDAL/OGR instalado..."}
print("Continuando procesamiento...")

Sys.which("C:/OSGeo4W64/bin/")
GDALPATH<-"C:/OSGeo4W64/bin/"

if(dir.exists("~/_Descarga_Datos/MODIS/")==FALSE){
  dir.create("~/_Descarga_Datos/MODIS/")
}

setwd("~/_Descarga_Datos/MODIS/")
Ruta<-"~/_Descarga_Datos/MODIS/"

# Login Earthdata
EarthdataLogin(usr=getPass::getPass("Usuario Earthdata: "),pwd=getPass::getPass("Contraseña Earthdata: "))


# Parametros MODIS
MODISoptions(localArcPath = Ruta,
             outDirPath = Ruta,
             gdalPath = GDALPATH,
             MODISserverOrder = c("LPDAAC", "LAADS"))
             
Fecha1<-dlgInput("Ingrese la fecha inicial de descarga (Año-Mes-Día): ")$res
Fecha2<-dlgInput("Ingrese la fecha final de descarga (Año-Mes-Día): ")$res
Fecha1<-transDate(begin = Fecha1)
Fecha2<-transDate(end = Fecha2)
             

# Delimitando a la zona de estudio ----------------------------------------



print("*** Cargando un vectorial de la zona de estudio ***")
Resp<-winDialog("yesnocancel", "¿Desea seleccionar un vectorial para la zona de estudio?")

if(Resp=="YES"){
  Area<-readOGR(choose.files(default="",caption="Seleccione el archivo vectorial de la zona de estudio:"))
  Area_proj<-crs(Area)
  WGS84<-CRS("+proj=longlat +datum=WGS84 +no_defs")
  if(projection(WGS84)==projection(Area_proj)){print("Proyección correcta.")}else{
    print("Cambiando proyección a ESPG:4326")
    Area<-spTransform(Area, WGS84)
    crs(Area)}
  A<-getTile(Area)
  runGdal(job="/Imagenes_MODIS/",
          product="MOD16A2",
          extent=A,
          begin=Fecha1$beginDOY,
          end=Fecha2$endDOY,
          SDSstring = "1",
          outProj= "EPSG:4326")
  }

if(Resp=="NO"){
  Tile_v<-dlgInput(message = "TileV: ")$res
  Tile_H<-dlgInput(message = "TileH: ")$res
  runGdal(job="/Imagenes_MODIS/",
          product="MOD16A2",
          tileV = Tile_v,
          tileH = Tile_H,
          begin=Fecha1$beginDOY,
          end=Fecha2$endDOY,
          SDSstring = "1",
          outProj= "EPSG:4326"
  )
}

if(Resp=="CANCEL"){stop(winDialog("ok","Se detuvo el procedimiento de descarga."))}




