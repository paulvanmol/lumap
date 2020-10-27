
filename out "&path\geoaddr.json"; 
proc http 
url="http://apiv3.geoportail.lu/geocode/search?num=54&street=Avenue%20Gaston%20Diderich&zip=&locality=Luxembourg&_dc=1386599465147"
 out=out;
debug level=3;
run; 

libname geoaddr JSON  "&path\geoaddr.json"; 
proc contents data=geoaddr._all_; 
run; 

proc print data=geoaddr.alldata;
run; 
libname geoaddr clear; 
