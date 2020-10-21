%LET PATH = D:\workshop\lumap;
%LET ConfigDir=d:/sas/config/Lev1;
%let encoding=latin1; 
/*%LET PATH = /workshop/lumap/sascode/;*/
/*%LET ConfigDir = /sas/config/Lev1;*/
/*%include "&PATH.Change Length in Map Data.sas";*/

%include "&PATH./sascode/FinalScript_CantonLU.sas";
%include "&PATH./sascode/FinalScript_DistrictLU.sas";
%include "&PATH./sascode/FinalScript_MunicipalityLU.sas";

