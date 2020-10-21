
/*Final Script voor Provincies*/
/*Parameters*/

%let REGION_LABEL=Luxembourg District;
%let REGION_PREFIX=ZD;
%let REGION_ISO=932;
%let PROVINCE_LABEL=Custom Lux District;
%let PROVINCE_DATASET=MAPSCSTM.CUSTOM_DISTRLU1;



/*Load Custom Regions*/


GOPTIONS ACCESSIBLE;
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
PROC MAPIMPORT 	DATAFILE="&path/limadmin/LIMADM_DISTRICTS_WGS84_&encoding..shp"
				OUT=MAPSCSTM.DistrLUMap;
				ID DISTRICT;
RUN;



/* add DENSITY variable */
PROC GREDUCE DATA=MAPSCSTM.DistrLUMap OUT=MAPSCSTM.DistrLUMap;
	ID DISTRICT;
RUN;
data MAPSCSTM.DistrLUMap; 
length DISTRICT $12; 
set MAPSCSTM.DistrLUMap; 
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
 SET MAPSCSTM.DistrLUMap;
 length ID $ 15 IDNAME $55;
 if District="Diekirch" then num=1; 
 else if District="Grevenmacher" then num=2; 
 else if district="Luxembourg" then num=3; 
 ID= "&REGION_PREFIX.-"!!strip(put(num,1.)); 
 IDNAME="District "||strip(DISTRICT);
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






GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

%LET _CLIENTTASKLABEL='Create Test Table';
%LET _CLIENTPROJECTPATH='C:\Users\sbxdad\Documents\Visual Analytics Documents\Custom Regions\Own Research\Final Scripts\Final Script voor Provincies.egp';
%LET _CLIENTPROJECTNAME='Final Script voor Provincies.egp';
%LET _SASPROGRAMFILE=;

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


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

