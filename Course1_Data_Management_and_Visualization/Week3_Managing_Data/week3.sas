/*access the data from cloud data library*/
libname mylib "/courses/d1406ae5ba27fe300" access=readonly;

/*read the specific dataset*/
data new; set mylib.addhealth_pds;

/*add label to variables*/
label H1GH2="how often have you had a headache" 
    H1DA1="times walk around the house" 
    H1DA2="times did you do your hobbies" 
    H1DA4="times did you go roller-blading/bycycling and so on"
    H1DA5="time did you play an active sport" 
    H1DA6="time did you do exercise" 
    H1DA7="times did you hang out with friends" 
    H1ED1="times absent from school with an excuse" 
    H1ED2="times skipped school without an excuse";

/* coding out missing data */
if H1GH2=6 or H1GH2=8 then H1GH2=.;
if H1DA1=6 or H1DA1=8 then H1DA1=.;
if H1DA2=6 or H1DA2=8 then H1DA2=.;
if H1DA4=6 or H1DA4=8 then H1DA4=.;
if H1DA5=6 or H1DA5=8 then H1DA5=.;
if H1DA6=6 or H1DA6=8 then H1DA6=.;
if H1DA7=6 or H1DA7=8 then H1DA7=.;
if H1ED1=6 or H1ED1=7 or H1ED1=8 or H1ED1=9 then H1ED1=.;
if H1ED2=996 or H1ED2=997 or H1ED2=998 then H1ED2=.;

/* collapse "absent school without an execuse" data */
if H1ED2 LE 0 then SKIP=0;
else if H1ED2 LE 2 then SKIP=1;
else if H1ED2 LE 10 then SKIP=2;
else SKIP=3;

/* create secondary variables*/
if H1ED1 NE . and SKIP NE . then SKIPSCH=H1ED1+SKIP;
else if H1ED1 EQ . and SKIP NE . then SKIPSCH=SKIP;
else if H1ED1 NE . and SKIP EQ . then SKIPSCH=H1ED1;
else SKIPSCH=.;

label SKIP="collapsed: times skipped school without an excuse"
	SKIPSCH="total times skipped school";
	
/*subset the data*/
if H1GI1Y GE 80;

/*sort data*/
proc sort; by aid;

/* print variables*/
proc print; var H1ED1 SKIP SKIPSCH;
proc freq; tables H1GH2 H1DA1 H1DA2 H1DA4 H1DA5 H1DA6 H1DA7 H1ED1 H1ED2 SKIP SKIPSCH;
run;
