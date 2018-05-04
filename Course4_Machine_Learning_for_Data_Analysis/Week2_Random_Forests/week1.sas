/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1GH2="How often have you had a headache/categorical"
	H1TO16="How many drinks did you usually have each time?/quantitative"
	H1ED1="Skip school with excuse/categorical"
	H1ED2="Skip school without excuse/quantitative"
	H1ED9="Have you ever been expelled from school?/categorical"
	H1GH1="how is your health?/categorical";

/* manage missing data*/
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;
if H1TO16=96 or H1TO16=98 or H1TO16=99 or H1TO16=97 or H1TO16=90 then H1TO16=.;
if H1ED9=6 or H1ED9=8 then H1ED9=.;
if H1GH1=6 or H1GH1=8 then H1GH1=.;

/* create secondary variables */
/* skip school without excuse 1-yes, 2-no */
if H1ED2=0 then SKIPCAT=2;
else if H1ED2=. then SKIPCAT=.;
else SKIPCAT=1;	

/* get mean values */
proc means; var H1TO16;
run;

/* create a new dataset */
data new2; set new;
/* center the H1TO16 */
H1TO16_C=H1TO16-5.3429454;

/*add label to secondary variables*/
label H1TO16_C="Centered: How many drinks did you usually have each time?/quantitative"
	SKIPCAT="Skip school without excuse/categorical";
	
if SKIPCAT NE .;

/* sort data */
proc sort; by AID;
proc means; var H1TO16_C;
proc freq; table SKIPCAT;
run;

ods graphics on;
proc hpsplit seed=15531;
class H1GH2 H1ED1 H1ED9 H1GH1 SKIPCAT;
model SKIPCAT=H1GH2 H1TO16_C H1ED1 H1ED9 H1GH1;
grow gini;
prune costcomplexity;
run;
