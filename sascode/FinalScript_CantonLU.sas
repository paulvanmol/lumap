/*Final Script voor Arrondissement*/
/*Parameters*/


%let REGION_LABEL=Luxembourg Canton;
%let REGION_PREFIX=ZC;
%let REGION_ISO=933;
%let PROVINCE_LABEL=Custom Lux Canton;
%let PROVINCE_DATASET=MAPSCSTM.CUSTOM_CANTLU1;


/*Load Custom Regions*/

/* create libraries */
libname valib "&configdir/SASApp/Data/valib";
libname MAPSCSTM "&path/sasdata";
proc sql; 
delete * from valib.attrlookup
where ID ? "&REGION_PREFIX"; 
delete * from valib.centlookup
where ID ? "&REGION_PREFIX"; 
quit;

/* import SHAPE file to SAS dataset */
PROC MAPIMPORT 	DATAFILE="&path/limadmin/LIMADM_CANTONS_WGS84_&encoding..shp"
				OUT=MAPSCSTM.CantonLUMap contents;
				ID CANTON;
RUN;

/* add DENSITY variable */
PROC GREDUCE DATA=MAPSCSTM.CantonLUMap OUT=MAPSCSTM.CantonLUMap;
	ID CANTON;
RUN;

data MAPSCSTM.CantonLUMap; 
length CANTON $23 DISTRICT $12;
set MAPSCSTM.CantonLUMap; 
run; 
/* add Custom Regions to ATTRLOOKUP */ 
proc sql;
 insert into valib.attrlookup
 values ( 
  "&REGION_LABEL.",            /* IDLABEL=State/Province Label */
  "&REGION_PREFIX.", 		/* ID=SAS Map ID Value */
  "&REGION_LABEL.",            /* IDNAME=State/Province Name */
  "",                   	/* ID1NAME=Country Name */
  "",                          /* ID2NAME */
  "&REGION_ISO.",              /* ISO=Country ISO Numeric Code */
  "&REGION_LABEL.",          	/* ISONAME */
  "&REGION_LABEL.",     	/* KEY */
  "",                          /* ID1=Country ISO 2-Letter Code */
  "",                          /* ID2 */
  "",                          /* ID3 */
  "",                          /* ID3NAME */
  0                            /* LEVEL (0=country level) */
 );
;quit;


/* create Custom Regions dataset */
data &PROVINCE_DATASET.;
 SET MAPSCSTM.CantonLUMap;
 length ID $ 15 IDNAME $ 55; 
 Canton=propcase(Canton);
 select (Canton);
 when ("Capellen")  ID="LU-CA";
 when ("Clervaux" ) ID="LU-CL";
 when ("Diekirch")  ID="LU-DI";
 when ("Echternach")  ID="LU-EC";
 when ("Esch-Sur-Alzette") ID="LU-ES";
 when ("Grevenmacher")  ID="LU-GR";
 when ("Luxembourg") ID="LU-LU";
 when ("Mersch")  ID="LU-ME";
 when ("Redange")  ID="LU-RE";
 when ("Remich")  ID="LU-RM";
 when ("Vianden")  ID="LU-VD";
 when ("Wiltz")  ID="LU-WI";
  
 otherwise; 
 end; 
 
 IDNAME = "Canton "||strip(Canton);
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

/* add custom subregions to ATTRLOOKUP */
proc sql;
 insert into valib.attrlookup
 select distinct 
  IDNAME,                              /* IDLABEL=State/Province Label */
  ID, 				        			/* ID=SAS Map ID Value */
  IDNAME,                              /* IDNAME=State/Province Name */
  "&REGION_LABEL.",                    /* ID1NAME=Country Name */
  "",                                  /* ID2NAME */
  "&REGION_ISO.",                      /* ISO=Country ISO Numeric Code */
  "&REGION_LABEL.",            			/* ISONAME */
  trim(IDNAME) || "|&REGION_LABEL.",   /* KEY */
  "&REGION_PREFIX.",                   /* ID1=Country ISO 2-Letter Code */
  "",                                  /* ID2 */
  "",                                  /* ID3 */
  "",                                  /* ID3NAME */
  1                                    /* LEVEL (1=state level) */
 from &PROVINCE_DATASET.
;quit;run;


/* add data to CENTLOOKUP */
proc sql;
  /* add custom region to CENTLOOKUP */
  insert into valib.centlookup
  select distinct
     "&PROVINCE_DATASET." as mapname,
     "&REGION_PREFIX." as ID,
     avg(x) as x,
     avg(y) as y
  from &PROVINCE_DATASET.;
  /* add custom provinces to CENTLOOKUP */
  insert into valib.centlookup
  select distinct
     "&PROVINCE_DATASET." as mapname,
     ID as ID,
     avg(x) as x,
     avg(y) as y
  from &PROVINCE_DATASET.
  group by id;
;quit;run;








GOPTIONS ACCESSIBLE;
proc sql;
   create table &PROVINCE_DATASET._TEST as
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


