/*access the data from cloud data library*/
libname mydata "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mydata.addhealth_pds;

keep H1ED2 H1GH2 H1TO16 H1ED1 H1ED9 H1GH1 H1ED16 H1ED18 H1ED19 H1SE1 H1WP10 H1WP14;

/*add label to variables*/
label H1GH2="How often have you had a headache/categorical"
	H1TO16="How many drinks did you usually have each time?/quantitative"
	H1ED1="Skip school with excuse/categorical"
	H1ED2="Skip school without excuse/quantitative"
	H1ED9="Have you ever been expelled from school?/categorical"
	H1GH1="how is your health?/categorical"
	H1ED16="paying attention in school"
	H1ED18="getting along with other students?"
	H1ED19="feel close to people at your school"
	H1SE1="how sure are you that you could stop yourself to use birth control?"
	H1WP14="Father cares about you"
	H1WP10="Mother cares about you";
	
/* manage missing data*/
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;
if H1TO16=96 or H1TO16=98 or H1TO16=99 or H1TO16=97 or H1TO16=90 then H1TO16=.;
if H1ED9=6 or H1ED9=8 then H1ED9=.;
if H1GH1=6 or H1GH1=8 then H1GH1=.;
if H1ED16=6 or H1ED16=7 or H1ED16=8 then H1ED16=.;
if H1ED18=6 or H1ED18=7 or H1ED18=8 then H1ED18=.;
if H1ED19=6 or H1ED19=7 or H1ED19=8 then H1ED19=.;
if H1SE1=96 or H1SE1=97 or H1SE1=98 or H1SE1=99 then H1SE1=.;
if H1WP10=6 or H1WP10=7 or H1WP10=8 then H1WP10=.;
if H1WP14=6 or H1WP14=7 or H1WP14=8 or H1WP14=9 then H1WP14=.;


data new1; set new;
/* delete observations with missing data */
if cmiss(of _all_) then delete;
run;

/* print plot */
ods graphics on;

/* randomly split dataset into a trainning dataset 70% and test dataset */
proc surveyselect data=new1 out=traintest seed=123
 samprate=0.7 method=srs outall;
run;

/* lasso multiple regression with lars algorithm k=10 fold validation */
proc glmselect data=traintest plot=all seed=123;
	partition role=selected(train='1' test='0');
	model H1ED2=H1GH2 H1TO16 H1ED1 H1ED9 H1GH1 H1ED16 H1ED18 H1ED19 H1SE1 
	H1WP10 H1WP14/selection=lar(choose=cv stop=none) cvmethod=random(10);
run;