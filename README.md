# Calidad del agua subterránea en México

## Proyecto desarrollado para la Dra. Mónica Imelda Martínez, de la Unidad Académica de Ciencias Químicas de la Universidad Autónoma de Zacatecas. 
La aplicación shiny puede visitarse la siguiente URL: https://ddiannae.shinyapps.io/calidad-agua/

En esta aplicación se despliega un mapa de la República Mexicana con la ubicación de los pozos registrados por CONAGUA en el 2020. El conjunto de datos contiene el valor de los siguientes contaminantes en miligramos por litro: Alcalinidad Total, Arsénico Total, Cadmio Total, Cromo Total, Dureza Total, Hierro Total, Fluoruros Totales, Mercurio Total, Manganeso Total, Nitrógeno de Nitratos, Plomo Total, Sólidos Disueltos Totales-Medidos, y Sólidos Disueltos Totales. Además, contiene el valor de Coliformes Fecales en número más probable por 100 mililitros y el valor de Conductividad en microsiemens por centímetro. El valor de cada contaminante está asociado con una clasificación categórica de acuerdo a las escalas establecidas por CONAGUA. La variable llamada Semáforo, también establecida por CONAGUA, es un indicador del nivel de contaminación global según los contaminantes presentes en el pozo.

El mapa permite filtrar los pozos visibles de acuerdo a su cuenca hidrográfica y seleccionar una variable para asignar el color del marcador asociado a un pozo. Sobre el mapa geográfico se muestra un *heatmap* o mapa de calor asociado a la variable Semáforo para identificar zonas donde se concentran pozos con 
agua de baja calidad. Al dar click en un marcador de pozo se despliega su Clave y Nombre asociados. 

La aplicación también incluye un explorador de datos que filtra los pozos según Estado y Municipio, permite realizar búsquedas de acuerdo a alguna consulta y ordenar el conjunto de datos. También es posible localizar cualquier pozo en el mapa, desde el explorador de datos. 
