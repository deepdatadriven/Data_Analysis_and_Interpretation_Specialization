/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1TO7="cigarettes smoked each day during past 30 days" 
	H1TO16="How many drinks did you usually have each time?";

/* manage missing data*/
if H1TO7=96 or H1TO7=97 or H1TO7=98 then H1TO7=.;
if H1TO16=96 or H1TO16=98 or H1TO16=99 or H1TO16=97 then H1TO16=.;

/*subset the data*/
if H1GI1Y GE 80;

proc sort; by aid;
proc freq; tables H1TO7 H1TO16;
proc gplot; plot H1TO16*H1TO7;
proc corr; var H1TO7 H1TO16;
run;