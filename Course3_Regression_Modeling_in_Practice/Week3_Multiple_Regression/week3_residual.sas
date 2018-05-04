/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1GH2="How often have you had a headache/categorical"
	H1TO16="How many drinks did you usually have each time?"
	H1ED9="Have you ever been expelled from school?/categorical"
	H1GH1="how is your health?";

/* manage missing data*/
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;
if H1TO16=96 or H1TO16=98 or H1TO16=99 or H1TO16=97 or H1TO16=90 then H1TO16=.;
if H1ED9=6 or H1ED9=8 then H1ED9=.;
if H1GH1=6 or H1GH1=8 then H1GH1=.;

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

/* create secondary variables*/
/* multi-categories into 2 categories */
if H1GH2=0 or H1GH2=1 or H1GH2=2 then HEADCAT=0;
else if H1GH2=3 or H1GH2=4 then HEADCAT=1;
else HEADCAT=.;

/*add label to secondary variables*/
label SKIPFREQ="times skipped school/quantitative"
	HEADCAT="times have had a headache: above once a week or not";

/* sub the data */
if H1GI1Y GE 80;
/*sort data*/
proc sort; by AID;
proc freq; table H1GH1;
/* get the mean value */
proc means; var H1TO16;
run;

/* create a new dataset */
data new2; set new;
/* center the H1TO16 */
H1TO16_C=H1TO16-4.4139715;
H1TO16_C2 = H1TO16_C*H1TO16_C;
/* sub the data */
if H1GI1Y GE 80;

/*sort data*/
proc sort; by AID;

/* regression model with q-q plot */
proc means; var H1TO16_C;
proc glm plots(unpack)=all; 
	model SKIPFREQ=HEADCAT H1TO16_C H1TO16_C2 H1ED9 H1GH1/solution clparm;
	output residual=res student=stdres out=results;
run;

proc gplot;
	label stdres="standardized Residual" AID="Adolescent";
	plot stdres*AID/vref=2;
run;

proc reg plots=partial;
	model SKIPFREQ=HEADCAT H1TO16_C H1TO16_C2 H1ED9 H1GH1/partial;
run;
