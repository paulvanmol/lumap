
%LET PATH = D:\workshop\lumap;
%LET ConfigDir=d:/sas/config/Lev1;
%let encoding=utf8;
%let projection=luref;
 
/*%LET PATH = /workshop/lumap/sascode/;*/
/*%LET ConfigDir = /sas/config/Lev1;*/
/*%include "&PATH.Change Length in Map Data.sas";*/
/*Final Script voor Municipality*/
/*Parameters*/

%let REGION_LABEL=Luxembourg Municipality;
%let REGION_PREFIX=ZL;
%let REGION_ISO=934;
%let PROVINCE_LABEL=Custom Lux Municipality;
%let PROVINCE_DATASET=MAPSCSTM.CUSTOM_MUNLU1;

libname mapscstm "&path/sasdata"; 
proc mapimport datafile="&path\addresses\addresses.shp"  out=mapscstm.addresses contents ; 
run; 




GOPTIONS ACCESSIBLE;
/* create libraries */
libname valib "&configdir/SASApp/Data/valib";
libname MAPSCSTM "&path/sasdata";


/* import SHAPE file to SAS dataset */
PROC MAPIMPORT 	DATAFILE="&path/limadmin/LIMADM_COMMUNES.shp" contents
				OUT=MAPSCSTM.MunicipalityLUREF;
				ID LAU2;
RUN;


/* add DENSITY variable */
PROC GREDUCE DATA=MAPSCSTM.MunicipalityLUREF OUT=MAPSCSTM.MunicipalityLUREF;
	ID LAU2;
RUN;

data MAPSCSTM.MunicipalityLUREF; 
length lau2 $4; 
set MAPSCSTM.MunicipalityLUREF; 
run; 


/* create Custom Regions dataset */
data &PROVINCE_DATASET.LUREF;
 SET MAPSCSTM.MunicipalityLUREF;
 length ID $ 15 IDNAME $55; 
 ID = compress("&REGION_PREFIX.-" || put(LAU2,$4.));
 IDNAME = Propcase(COMMUNE);
 LONG = X;
 LAT = Y;
 ISO = "&REGION_ISO.";
 RESOLUTION = 1;
 LAKE = 0;
 ISOALPHA2 = "&REGION_PREFIX.";
 AdminType = "regions";
 WHERE DENSITY <= 2;
 keep ID SEGMENT IDNAME LONG LAT X Y ISO DENSITY RESOLUTION LAKE ISOALPHA2 AdminType;
run;



/*create test table*/

GOPTIONS ACCESSIBLE;
proc sql;
   create table &PROVINCE_DATASET.LUREF_TEST as
   select distinct 
       ID as ID,
       IDNAME as NAME
   from &PROVINCE_DATASET.;
   create table &PROVINCE_DATASET._TEST as
   select *,
       round(ranuni(1) * 10000) as population,
       round(ranuni(1) * 100000) as avg_income format=dollar20.0
   from &PROVINCE_DATASET._TEST
   group by ID, NAME
   order by ID, NAME
;quit;run;

/*select Avenue Gaston Diderich nr 54*/
proc sql; 
create table work.query_for_addresses_0002 as 
select * from mapscstm.addresses t1
WHERE t1.rue = 'Avenue Gaston Diderich' AND t1.numero = '54';
quit; 

proc SGMAP mapdata=mapscstm.custom_munlu1luref respDATA=mapscstm.custom_munlu1_poparea 
	plotdata=WORK.QUERY_FOR_ADDRESSES_0002;
	
	CHOROMAP population /mapid=id id=id ; 
	scatter   x=x y=y / markerattrs=(symbol=diamond color=red) datalabel=rue;
		
	;
RUN;
QUIT;

TITLE;FOOTNOTE;

GOPTIONS CBACK=;

%_eg_conditional_dropds(WORK.MAPCHARTRESPONSEPREP);
%_eg_conditional_dropds(WORK.MAPCHARTMAPPREP);
