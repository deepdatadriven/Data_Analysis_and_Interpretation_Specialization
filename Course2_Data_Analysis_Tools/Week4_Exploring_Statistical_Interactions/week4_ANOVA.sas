/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1GH2="How often have you had a headache/categorical"
	H1ED9="Have you ever been expelled from school?/categorical";

/* manage missing data*/
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;
if H1ED9=6 or H1ED9=8 then H1ED9=.;

/* create secondary variables */
/* sum H1ED1 and H1ED2 to get the total times skipped school */
if H1ED1=0 then H1ED1QU=0;
else if H1ED1=1 then H1ED1QU=2;
else if H1ED1=2 then H1ED1QU=7;
else if H1ED1=3 then H1ED1QU=45;
else H1ED1QU=.;

if H1ED1QU NE . and H1ED2 NE . then SKIPFREQ=H1ED1QU+H1ED2;
else if H1ED1QU EQ . and H1ED2 NE . then SKIPFREQ=H1ED2;
else if H1ED1QU NE . and H1ED2 EQ . then SKIPFREQ=H1ED1QU;
else SKIPFREQ=.;

if SKIPFREQ LT 7 then SKIPCAT=0;
else if SKIPFREQ GE 7 then SKIPCAT=1;
else SKIPCAT=.;

/* create secondary variables*/
/* multi-categories into 2 categories */
if H1GH2=0 or H1GH2=1 or H1GH2=2 then HEADCAT=0;
else if H1GH2=3 or H1GH2=4 then HEADCAT=1;
else HEADACT=.;

/*add label to secondary variables*/
label SKIPFREQ="times skipped school/quantitative"
	HEADACT="times have had a headache: above once a week or not";

/* sub the data */
if H1GI1Y GE 80;
if H1ED9 NE .;

/*sort data*/
proc sort; by H1ED9;

/* anova procedure: 2 levels */
proc freq; table HEADCAT;
proc anova; class HEADCAT;
model SKIPFREQ=HEADCAT;
means HEADCAT; by H1ED9;
run;
