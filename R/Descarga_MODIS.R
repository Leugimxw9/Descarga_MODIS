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


# # Procesamiento datos  --------------------------------------------------

# Lectura MODIS -----------------------------------------------------------

print("*** LECTURA Y PROCESAMIENTO DE EVAPOTRANSPIRACIÓN ***")
setwd("~/_Descarga_Datos/MODIS/Imagenes_MODIS/")

print("Cargando archivos tif...")
Modis_datos<- list.files(pattern = "tif")
Modis_datos<-stack(Modis_datos)
print("Información...")
Modis_datos
Nombre<-names(Modis_datos)

print("Calculando factor de conversión...")
Factor_modis<-function(x){
  x*0.1
}
Modis_datos<-calc(Modis_datos, fun=Factor_modis)

print("Convirtiendo valores de relleno a NA...")
Modis_datos[Modis_datos > 3000]<-NA

if(Resp=="YES"){
print("Aplicando Máscara...")
Modis_datos<-crop(Modis_datos,extent(Area))
Modis_datos<-mask(Modis_datos, Area)
}

print("Creando Mapas...")
if(!require(RColorBrewer)){
  install.packages("RColorBrewer")
  require(RColorBrewer)}else{library(RColorBrewer)}

col_RB<-colorRampPalette(c("Blue", "Yellow", "Red"))

NL<-(nlayers(Modis_datos))
i=0
while(i<=NL){
  i<-i+1
  if(i<=NL){
    cat("Datos restantes: ",(NL-i), "\n")
    png(filename=paste0(Nombre[i],".png"), width = 1200, height=1200, units="px")
    plot(Modis_datos[[i]], col=col_RB(maxValue(Modis_datos[[i]])), main="Evapotranspiración", sub=paste0(Nombre[i]),
         cex.main=3, cex.sub=2, cex.lab=4)
    dev.off()
  }
}

RespG<-winDialog("yesno","¿Desea guardar las imágenes procesadas?")

if(RespG=="YES"){
  print("*** COMENZANDO A GUARDAR DATOS RASTER ***")
  dir.create("~/_Descarga_Datos/MODIS/Raster procesados/")
  i=0
  while(i <= NL){
    
    i<-i+1
    if(i<NL){
      cat("Datos restantes: ",(NL-i), "\n")
      writeRaster(Modis_datos[[i]], filename = paste0("~/_Descarga_Datos/MODIS/Raster procesados/", Nombre[i]), suffix=Nombre[i], format="GTiff", overwrite=TRUE)
    }
  }
}else{winDialog("ok","Proceso terminado.")}



