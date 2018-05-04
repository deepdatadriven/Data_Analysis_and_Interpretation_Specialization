/*access the data from cloud data library*/
libname mydata "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mydata.addhealth_pds;

keep AID H1ED2 H1GH2 H1TO16 H1ED1 H1ED9 H1GH1 H1ED16 H1ED18 H1ED19 H1SE1 H1WP10 H1WP14;


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

data clus_train;
set traintest;
if selected=1;
run;
data clus_test;
set traintest;
if selected=0;
run;

/* standardize the clustering variables to have a mean of 0 and standard deviation of 1 */
proc standard data=clus_train out=clustvar mean=0 std=1; 
var H1GH2 H1TO16 H1ED1 H1ED9 H1GH1 H1ED16 H1ED18 H1ED19 H1SE1 H1WP10 H1WP14;
run; 

%macro kmean(K);

proc fastclus data=clustvar out=outdata&K. outstat=cluststat&K. maxclusters= &K. maxiter=300;
var H1GH2 H1TO16 H1ED1 H1ED9 H1GH1 H1ED16 H1ED18 H1ED19 H1SE1 H1WP10 H1WP14;
run;

%mend;

%kmean(1);
%kmean(2);
%kmean(3);
%kmean(4);
%kmean(5);
%kmean(6);
%kmean(7);
%kmean(8);
%kmean(9);
%kmean(10);

/* extract r-square values from each cluster solution and then merge them to plot elbow curve */
data clus1;
set cluststat1;
nclust=1;

if _type_='RSQ';

keep nclust over_all;
run;

data clus2;
set cluststat2;
nclust=2;

if _type_='RSQ';

keep nclust over_all;
run;

data clus3;
set cluststat3;
nclust=3;

if _type_='RSQ';

keep nclust over_all;
run;

data clus4;
set cluststat4;
nclust=4;

if _type_='RSQ';

keep nclust over_all;
run;
data clus5;
set cluststat5;
nclust=5;

if _type_='RSQ';

keep nclust over_all;
run;
data clus6;
set cluststat6;
nclust=6;

if _type_='RSQ';

keep nclust over_all;
run;
data clus7;
set cluststat7;
nclust=7;

if _type_='RSQ';

keep nclust over_all;
run;
data clus8;
set cluststat8;
nclust=8;

if _type_='RSQ';

keep nclust over_all;
run;
data clus9;
set cluststat9;
nclust=9;

if _type_='RSQ';

keep nclust over_all;
run;

data clusrsquare;
set clus1 clus2 clus3 clus4 clus5 clus6 clus7 clus8 clus9;
run;

* plot elbow curve using r-square values;
symbol1 color=blue interpol=join;
proc gplot data=clusrsquare;
plot over_all*nclust;
run;

*****************************************************************************************
further examine cluster solution for the number of clusters suggested by the elbow curve
*****************************************************************************************

* plot clusters for 5 cluster solution;
proc candisc data=outdata5 out=clustcan;
class cluster;
var H1GH2 H1TO16 H1ED1 H1ED9 H1GH1 H1ED16 H1ED18 H1ED19 H1SE1 H1WP10 H1WP14;
run;


proc sgplot data=clustcan;
scatter y=can2 x=can4 / group=cluster;
run;

* validate clusters on H1ED2;

* first merge clustering variable and assignment data with H1ED2 data;
data H1ED2_data;
set clus_train;
keep AID H1ED2;
run;

proc sort data=outdata3;
by AID;
run;

proc sort data=H1ED2_data;
by AID;
run;

data merged;
merge outdata3 H1ED2_data;
by AID;
run;

proc sort data=merged;
by cluster;
run;

proc means data=merged;
var H1ED2;
by cluster;
run;

proc anova data=merged;
class cluster;
model H1ED2 = cluster;
means cluster/tukey;
run;
 