/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1GH2="how often have you had a headache/categorical"; 

/* manage missing data*/
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;

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


/*add label to secondary variables*/
label SKIPCAT="skipped school above 7 times or not/categorical";
	
/*subset the data*/
if H1GI1Y GE 80;

/*sort data*/
proc sort; by aid;

/* Chi-square procedure */
proc freq; table SKIPCAT;
proc freq; tables SKIPCAT*H1GH2/chisq;
proc gchart; vbar H1GH2/discrete type=mean sumvar=SKIPCAT;
run;

/* print each pair categories of H1GH2 */
data pair1; set new;
if H1GH2=0 or H1GH2=1;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair2; set new;
if H1GH2=0 or H1GH2=2;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair3; set new;
if H1GH2=0 or H1GH2=3;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair4; set new;
if H1GH2=0 or H1GH2=4;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair5; set new;
if H1GH2=1 or H1GH2=2;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair6; set new;
if H1GH2=1 or H1GH2=3;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair7; set new;
if H1GH2=1 or H1GH2=4;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair8; set new;
if H1GH2=2 or H1GH2=3;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair9; set new;
if H1GH2=2 or H1GH2=4;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;

data pair10; set new;
if H1GH2=3 or H1GH2=4;
proc sort; by aid;
proc freq; tables SKIPCAT*H1GH2/chisq;
run;