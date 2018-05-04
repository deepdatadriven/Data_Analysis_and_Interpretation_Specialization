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
    H1ED2="times skipped school without an excuse"
    H1GI1Y="the year of birth";

/*subset the data*/
if H1GI1Y GE 80;

/*sort data*/
proc sort; by aid;
proc freq; tables H1GI1Y H1GH2 H1DA1 H1DA2 H1DA4 H1DA5 H1DA6 H1DA7 H1ED1 H1ED2;
run;


