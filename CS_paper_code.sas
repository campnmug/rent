libname rentdata 'C:\Users\myers\Dropbox\Myers_x220\Documents\WORK\SAS\SAS_MWSUG\Cross Section-accepted\PR_rent_Data';
%let dir =C:\Users\myers\Dropbox\Myers_x220\Documents\WORK\SAS\SAS_MWSUG\Cross Section-accepted\PR_rent_Data;
title1 'Ann Arbor Rent Data';
Data rents;
	set rentdata.rent;
	rmpp=rm/NO;
	Fem=Sex;
	Femdist=sex*dist;
	FemRMPP=sex*RMPP;
	label rmpp ='Rooms per person';
	run;
proc format ;
value distance	0-6 	='close 0-6 blocks'
				7-12 	='further 7-12 blocks'
				13-60 	='far out 16-60 blocks' ;
value gender	1		='Female'
				0		='Male';
				run;

Title1 'Hasty regression';
proc reg data=rents;
/* model rent = rm dist sex/influence partial;
model rent = rm no dist sex/influence partial;
*/
	model rpp = sex;
	model rpp = dist sex; 
	model rpp = rmpp dist sex;
	run;

ods pdf file="&dir\CS_paper_code_results.pdf";

Title1 'Class means';
proc means data=rents maxdec=2;
	class sex;
	var rpp ;
	format sex gender.;
	run;

Title1 'Add CV and Skew';
proc means data=rents maxdec=2 n mean std cv skew kurtosis;
	class sex;
	var rpp ;
	format sex gender.;
	run;

Title1 'Measures of confounding variables';
proc means data=rents maxdec=1 ;
	class sex;
	var rmpp dist;
	format sex gender.;
	run;



ods graphics on;
Title2 'RENT distribution box plots';
	proc sgplot data=rents;
	vbox rent / category = sex datalabel;
	run;

	/* not in paper 

Title2 'RPP=(RENT/RM)distribution box plots';
	proc sgplot data=rents;
	vbox rpp / category = sex datalabel;
	run;

title1 'Visualization';
Title2 'RENT distribution box plots';
	proc sgplot data=rents;
	hbox rpp  / category = sex  boxwidth=0.25 discreteoffset=-0.15 datalabel;
	hbox dist / category = sex  boxwidth=0.25 discreteoffset=+0.15 y2axis datalabel;
	run;

	*/

Title1;
Title2 'RPP=(RENT/RM)distribution box plots';
	proc sgplot data=rents;
	vbox rpp  / category = sex  boxwidth=0.25 discreteoffset=-0.15 datalabel;
	vbox dist / category = sex  boxwidth=0.25 discreteoffset=+0.15 datalabel y2axis;

	run;



Title2 'univariate';
ods select extremeobs ;
proc univariate data=rents;
var rpp dist;
class sex;
run;

title ' ';
proc univariate data=rents noprint;
   class sex;
   histogram RPP /    midpercents
					  nrows        = 2
                      intertile    = 1
                      cprop
                      normal(noprint);
   inset n = "N" mean std / pos = nw;
   where RPP < 245; /* removes two extreme values */
run;





data rent2;
	set rents;
	length clean $3;
	if sex=0 and RPP=285 then M1=1; else M1=0;
	if sex=0 and dist=60 then M2=1; else M2=0;
	if sex=1 and dist=24 then M3=1; else M3=0;

	if sum(of M1, M2, M3) = 0 then clean='yes'; else clean='no';
	run;




Title2 'PROC FREQ distance by sex';
proc freq data=rents;
	 tables rmpp*sex  rm*no /norow nocol nocum nopercent;
	 run;

	 /* not in paper 
Title2 'PROC FREQ distance by sex';
proc freq data=rents;
	 tables dist*sex /norow nocol nocum nopercent;
	 run;
*/

Title2 'PROC FREQ distance categories by sex';
proc freq data=rents;
	 tables dist*sex /norow nocol nocum nopercent;
	 format dist distance. sex gender.;
	 run;

Title2 'PROC MEANS distance categories by sex';
proc means data=rents maxdec=2;
	class dist sex;
	var rent rpp  ;
	format dist distance. sex gender.;
	run;






Title1 'Custom Tables for RPP Statistics';
Title2 'Two dimensional table, rows before the comma, columns after.';
Title3 'Means of RPP by Sex and distance.';
Proc tabulate data=rent2;
	class dist no rm sex ;
	var rent rpp  ;
	Table dist , sex*rpp*mean;  
	format dist distance. sex gender.;
	run;

	/* not in paper 
Title2 'Two dimensional table, rows before the comma, columns after.';
Title3 'Mean, standard deviation and sample size of RPP by Sex and distance.';
Proc tabulate data=rent2;
	class dist no rm sex ;
	var rent rpp  ;
	Table (all dist), sex*rpp*(n mean stddev);
	format dist distance. sex gender.;
	run;
*/

Title2 'Two dimensional table, rows before the comma, columns after.';
Title3 'Mean, standard deviation and sample size of RPP by Sex and distance.';
Title4 'Use of titles and null titles to clean up the presentation';
Proc tabulate data=rent2;
	class dist no rm sex ;
	var rent rpp  ;
	Table (all=Total dist) , (all='Total' sex='')*rpp=''*(n mean stddev);
	format dist distance. sex gender.;
	run;
title;


/* not in paper 


title2 'Using Scatter plot option of SGPLOT for Rent.';
title3 'Markers are colored by group, red=female, blue=male.'; 
proc sgplot data=rents;
	scatter y=RENT x=dist  / group=sex;
	run;


*/



ODS GRAPHICS / ATTRPRIORITY=NONE;  
title2 'Using Scatter plot option of SGPLOT for Rent Per Person (RPP).';
title3 'Markers are colored by group, blue=male, red=female.'; 
title4 'original data N=32';
proc sgplot data=rent2;
	styleattrs datasymbols=(diamond circleFilled ) datacontrastcolors=(blue red);
	scatter y=RPP x=dist  / group=sex  Markerattrs=(size=10px)datalabel ;
	run;

	/* not in paper
ODS GRAPHICS / ATTRPRIORITY=NONE;  
title2 'Using Scatter plot option of SGPLOT for Rent Per Person (RPP).';
title3 'Markers are colored by group, blue=male, red=female.'; 
title4 'Cleaned data n=29';
proc sgplot data=rent2;
	styleattrs datasymbols=(diamond circleFilled ) datacontrastcolors=(blue red);
	scatter y=RPP x=dist  / group=sex  Markerattrs=(size=10px)datalabel ;
	where clean='yes';
	run;

*/





Title1;	

/* not in paper 
Title2 'Histograms of RPP by sex';
proc sgplot data=rent2;
	histogram RPP /  binwidth=25;
	density RPP / type=kernel;
	density RPP / type=normal;
	format dist distance. sex gender.;
	run;
*/

	Title2 'Histograms of RPP by sex';
proc sgplot data=rent2;
	histogram RPP / Group=sex transparency=.6 binwidth=25;
	density RPP / group=sex type=kernel;
	density RPP / group=sex type=normal;
	format dist distance. sex gender.;
	run;	
Title2 'Histograms of RPP by sex';
Title3 'Outliers in RPP and DIST removed';
proc sgplot data=rent2;
	histogram RPP / Group=sex transparency=.6 binwidth=25;
	density RPP / group=sex type=kernel;
	density RPP / group=sex type=normal;
	where clean='yes';
	format dist distance. sex gender.;
	run;





Title2 'Linear Regression and Loess Regression, RPP by Distance';

/* not in paper, not well specified

proc SGPLOT data=rent2;
	reg x=dist y=rpp /  clm clmtransparency=.7 ;
 	loess x=dist y=rpp /group=sex  clm nomarkers clmtransparency=.25; 
	where sex=1 and clean='yes';
run;
*/

/* not in paper 
Title2 'Linear Regression, RPP by Distance';
proc SGPLOT data=rent2;
	reg x=dist y=rpp / group=sex clm clmtransparency=0 ;
run;

*/
ODS GRAPHICS / ATTRPRIORITY=NONE;

title1;
Title2 'Linear Regression and Loess Regression, RPP by Distance, by Sex on cleaned data';
proc SGPLOT data=rent2;
	styleattrs datasymbols=(diamond circleFilled ) datacontrastcolors=(red blue);

	reg x=dist y=rpp /group=sex clm clmtransparency=.6 datalabel;
 	loess x=dist y=rpp /group=sex clm nomarkers clmtransparency=.2 ;
	where clean='yes';
run;



Title2 'PROC CORRELATION';
proc corr data=rent2;
	var rpp; with rmpp dist sex;
	run;

Title2 'PROC CORRELATION on clean dataset';
proc corr data=rent2;
	var rpp; with rmpp dist sex;
	where clean='yes';
	run;

title2 'Partial correlation of RPP and SEX, holding constant DIST and RMPP, on cleaned dataset';
proc corr data=rent2;
	var rpp; with sex; partial RMPP DIST;
	where clean='yes';
	run;

ods graphics on;
/* not in paper 
Title2 'Testing the average rent (or RPP) difference between males and females.';
proc ttest data=rent2 ;
	class sex;
	var rpp; 
	run;

*/
Title2 'Testing the average rent (or RPP) difference between males and females.';
proc ttest data=rent2 ;
	class sex;
	var rpp; 
	where clean='yes';
	format SEX gender.;
	run;


/* not in paper
Title2 'Linear Regression after outliers removed';
proc reg data=rent2;
model rent = no rm dist sex;
model rpp = rmpp dist sex;
where clean='yes';
output out=rentr rstudent=rstudent;
run;


Title1 'Linear Regression and Loess Regression, Rstudent by Distance, by Sex';
proc SGPLOT data=rentr;
	reg x=dist y=rstudent /group=sex clm clmtransparency=.6 datalabel;
 	loess x=dist y=rstudent /group=sex clm nomarkers clmtransparency=.2 datalabel;
	where clean='yes';
run;
Title1 'Linear Regression and Loess Regression, Rstudent by RMPP, by Sex';
proc SGPLOT data=rentr;
	reg x=rmpp y=rstudent /group=sex clm clmtransparency=.6 datalabel;
	where clean='yes' ;
	run;
proc means data=rentr n mean std cv min max maxdec=1;
var rstudent;
run;
proc freq data=rentr;
Tables rmpp*sex/norow nocol nocum nopercent;
where clean='yes';
format sex gender.;
run;
*/

Title1 'Linear Regression and fully interactive model with and without outlier marks';
proc reg data=rent2;
	model_1:  model rpp = rmpp dist sex;
	model_2:  model rpp = rmpp dist sex femrmpp femdist;
	Test_2:   test  sex = femrmpp=femdist=0;
		Test_2Bsum:  test  sex + femrmpp + femdist=0;

	model_1b: model rpp = rmpp dist sex m1 m2 m3;
	model_2b: model rpp = rmpp dist sex femrmpp femdist m1 m2 m3;
	Test_2B:  test  sex = femrmpp=femdist=0;
	run;

Title2 'Linear Regression fully interactive model after outliers removed from data';
proc reg data=rent2;
	model_1a: model rpp = rmpp dist sex;
	model_2a: model rpp = rmpp dist sex femrmpp femdist;
	Test_2a: test sex=femrmpp=femdist=0;
	output out=rentr rstudent=rstudent;
	where clean='yes';
	run;

	/* not in paper 
Title1 'Linear Regression and Loess Regression, Rstudent by Distance, by Sex';
proc SGPLOT data=rentr;
	reg x=dist y=rstudent /group=sex clm clmtransparency=.6 datalabel;
 	loess x=dist y=rstudent /group=sex clm nomarkers clmtransparency=.2 datalabel;
	where clean='yes';
run;
Title1 'Linear Regression, Rstudent by RPP, by Sex';
proc SGPLOT data=rentr;
	reg y=rpp x=rstudent /group=sex clm clmtransparency=.6 datalabel;
	where clean='yes' ;
	run;

proc means data=rentr n mean std cv min max;
var rstudent;
run;

	*/
ods pdf close;
