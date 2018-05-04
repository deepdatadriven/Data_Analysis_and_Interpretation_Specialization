/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1GH2="how often have you had a headache/categorical" 
    H1DA10="hours a week play video or computer games/quantitative";

/* manage missing data*/
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1DA1=6 or H1DA1=8 then H1DA1=.;
if H1DA2=6 or H1DA2=8 then H1DA2=.;
if H1DA4=6 or H1DA4=8 then H1DA4=.;
if H1DA5=6 or H1DA5=8 then H1DA5=.;
if H1DA6=6 or H1DA6=8 then H1DA6=.;
if H1DA7=6 or H1DA7=8 then H1DA7=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;
if H1DA10=996 or H1DA10=998 then H1DA10=.;

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
else SKIPFREQ=.;

/* create secondary variables*/
/* change multi-categories to bi-category */
DAYACTF = H1DA1+H1DA2+H1DA4+H1DA5+H1DA6+H1DA7;

if DAYACTF LE 10 then DAYACT=0;
else if DAYACTF GT 10 then DAYACT=1;
else DAYACT=.;

/*add label to secondary variables*/
label SKIPCAT="skipped school above 7 times or not/categorical"
	SKIPFREQ="times skipped school/quantitative"
	DAYACT="total times of daily activities above 10 times or not/categorical";
	
/*subset the data*/
if H1GI1Y GE 80;

/*sort data*/
proc sort; by aid;

/* print frequecy tables */
proc freq; tables H1GH2 SKIPCAT SKIPFREQ H1DA10;
run;

/* print univariate tables */
proc univariate; var SKIPFREQ DAYACTF;
run;

/* print univariate graphs */
proc gchart; vbar H1GH2/discrete type=pct width=25;
run;

proc gchart; vbar SKIPFREQ/type=pct;
run;

proc gchart; vbar DAYACTF/ type=pct;
run;

/* categorical -> categorical */
proc gchart; vbar H1GH2/discrete type=mean sumvar=SKIPCAT;
run;

proc gchart; vbar H1GH2/discrete type=mean sumvar=DAYACT;
run;

/* quantitative -> quantitative just for run the code, not for research*/
proc gplot; plot H1DA10*SKIPFREQ;
run;