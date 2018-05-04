/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1TO7="cigarettes smoked each day during past 30 days" 
	H1TO16="How many drinks did you usually have each time?"
	H1ED9="Have you ever been expelled from school?/categorical";

/* manage missing data*/
if H1TO7=96 or H1TO7=97 or H1TO7=98 then H1TO7=.;
if H1TO16=96 or H1TO16=98 or H1TO16=99 or H1TO16=97 then H1TO16=.;
if H1ED9=6 or H1ED9=8 then H1ED9=.;

/*subset the data*/
if H1GI1Y GE 80;
if H1ED9 NE .;

proc sort; by aid;
proc sort; by H1ED9;
proc means; var H1TO7;

data new2; set new;

H1TO7_C=H1TO7-4.7527840;

label H1TO7_C="centred number of cigarettes smoke each day";

/* without quadratic term */
proc glm; model H1TO16=H1TO7_C/solution clparm;
/* add quadratic term */
proc glm; model H1TO16=H1TO7_C H1TO7_C*H1TO7_C/solution clparm;

/* scatteplot with linear and quadratic regression line */
proc sgplot; 
	reg x=H1TO7_C y=H1TO16 / lineattrs=(color=blue thickness=2) degree=1 clm;
	reg x=H1TO7_C y=H1TO16 / lineattrs=(color=green thickness=2) degree=2 clm;
	xaxis label="cigarettes smoked each day";
	yaxis label="drinks did you usually have each time";
run;