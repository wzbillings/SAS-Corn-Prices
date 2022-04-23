********************************************************************************
*  TITLE :      SAS GRAIN PRICE PROJECT ANALYSIS
*                  
*  DESCRIPTION: Final project for BIOS 7400 with Xiao Song, UGA, Spring 2022.
*               Simple analysis of grain price data.
*                                                                   
*-------------------------------------------------------------------------------
*  JOB NAME:    analysis.SAS
*  LANGUAGE:    SAS v9.4 (on demand for academics)
*
*  NAME:        Zane Billings
*  DATE:        2022-04-22
*
*******************************************************************************;

FOOTNOTE "Job run by Zane Billings on &SYSDATE at &SYSTIME.";

TITLE 'ANALYSIS OF USDA HISTORICAL GRAIN PRICE DATA';

OPTIONS NODATE LS=95 PS=42;

LIBNAME HOME '/home/u59465388/SAS-Grain-Prices';

ODS GRAPHICS / WIDTH = 6in HEIGHT = 6in;

*******************************************************************************;
* Show the descriptor portion of the dataset;
*******************************************************************************;

TITLE2 "CONTENTS OF GRAINS DATASET";

PROC CONTENTS DATA = HOME.GRAINS;
RUN;

*******************************************************************************;
* Plot outcome time series;
*******************************************************************************;

FOOTNOTE;

TITLE2 "PRICE PER BUSHEL OF GRAINS OVER TIME";
PROC SGPLOT DATA = HOME.GRAINS;
	SERIES X = YEAR Y = LPE / GROUP = GRN;
RUN;

TITLE2 "GRAIN PRICES AND PRESIDENT'S POLITICAL PARTY OVER TIME";
PROC SGPANEL DATA = HOME.GRAINS;
	PANELBY GRN;
	SERIES X = YEAR Y = LPE / LINEATTRS = (COLOR = "GRAY") SMOOTHCONNECT;
	SCATTER X = YEAR Y = LPE / GROUP = PARTY
		MARKERATTRS = (SYMBOL = CIRCLEFILLED);
RUN;

TITLE2 "PERCENT CHANGE DISTRIBUTION BY PRESIDENT'S POLITICAL PARTY";
PROC SGPANEL DATA = HOME.GRAINS;
	PANELBY GRN;
	HBOX PCT / GROUP = PARTY;
RUN;

ODS GRAPHICS / WIDTH = 6in HEIGHT = 9in;

TITLE2 "SCATTERPLOTS OF PRICE VS COVARIATES";
PROC SGSCATTER DATA = HOME.GRAINS;
	PLOT LPE * (ACR HVT LNR PRD YLD) / REG
		COLUMNS = 2 GROUP = GRN;
RUN;

PROC SGSCATTER DATA = HOME.GRAINS;
	PLOT LPE * (INFL PWR TEMP VALUE) / REG
		COLUMNS = 2;
RUN;

*******************************************************************************;
* Plots of covariates across time;
*******************************************************************************;

TITLE2 "CHANGE IN COVARIATES ACROSS TIME";
PROC SGSCATTER DATA = HOME.GRAINS;
	PLOT (ACR HVT LNR PRD YLD) * YEAR /
		COLUMNS = 2 GROUP = GRN JOIN MARKERATTRS = (SIZE = 0);
RUN;

PROC SGSCATTER DATA = HOME.GRAINS;
	PLOT (INFL PWR TEMP VALUE) * YEAR /
		COLUMNS = 2 JOIN MARKERATTRS = (SIZE = 0);
RUN;

*******************************************************************************;
* Univariate analyses;
*******************************************************************************;

* Univariate analysis of main outcome by grain type;
TITLE2 "UNIVARIATE SUMMARY OF GRAIN DATA OVER TIME";

ODS GRAPHICS / WIDTH = 4in HEIGHT = 4in;

PROC UNIVARIATE DATA = HOME.GRAINS PLOTS;
	VAR LPE;
	CLASS GRN;
RUN;

*******************************************************************************;
* Bivariate analyses of price and covariates, ignoring time;
*******************************************************************************;

* Correlations;
PROC CORR PEARSON SPEARMAN DATA = HOME.GRAINS;
	VAR LPE ACR HVT LNR PRD YLD INFL PWR TEMP VALUE;
	BY GRN;
RUN;

* Mean difference in LPE by party;
PROC MEANS DATA = HOME.GRAINS MEAN STDERR MEDIAN RANGE NWAY;
	VAR LPE;
	CLASS PARTY;
	BY GRN;
RUN;

*******************************************************************************;
* Simple and multiple OLS regression models;
*******************************************************************************;

%MACRO ALLSIMPLE(DAT = , RESP = , PRED = );
	%LET N = %SYSFUNC(COUNTW(&DAT));
	%DO I = 1 %TO &N;
		PROC GLM DATA = &DAT PLOTS = ALL;
			CLASS GRN;
			MODEL &RESP = %SCAN(&PRED, &I) | GRN / NOINT;
		RUN;
	%END;
%MEND;

%ALLSIMPLE(
	DAT = HOME.GRAINS,
	RESP = LPE,
	PRED = ACR PRD INFL TEMP PWR YEAR
);

PROC GLM DATA = HOME.GRAINS PLOTS = ALL;
	CLASS GRN PARTY;
	MODEL LPE = GRN | PARTY;
RUN;

* 1866 FULL MODEL;
PROC MIXED DATA = HOME.GRAINS PLOTS = ALL;
	CLASS GRN PARTY;
	MODEL LPE =
		GRN HVT PRD INFL PWR YEAR PARTY
		GRN*HVT GRN*PRD GRN*INFL GRN*PWR GRN*YEAR GRN*PARTY /
		NOINT SOLUTION
	;
RUN;

* FULL MODEL WITH TEMP (1880 MODEL);
PROC MIXED DATA = HOME.GRAINS PLOTS = ALL;
	CLASS PARTY GRN;
	MODEL LPE =
		GRN HVT PRD INFL PWR YEAR
		GRN*HVT GRN*PRD GRN*INFL GRN*PWR GRN*YEAR GRN*PARTY /
		NOINT SOLUTION
	;
RUN;

*******************************************************************************;
* GLS multiple regression analysis;
*******************************************************************************;

PROC MIXED DATA = HOME.GRAINS PLOTS = ALL;
	CLASS PARTY GRN;
	MODEL LPE = HVT PRD INFL PWR YEAR GRN GRN*HVT GRN*PRD /
		NOINT SOLUTION CHISQ;
	REPEATED;
RUN;

*******************************************************************************;
* Simple forecasting;
*******************************************************************************;

DATA TS_DAT;
	SET HOME.GRAINS;
	T = MDY(1, 1, YEAR);
RUN;

PROC ARIMA DATA = TS_DAT;
	IDENTIFY VAR = LPE NLAG = 30 SCAN STATIONARITY = (RW = 10);
RUN;

PROC ARIMA DATA = TS_DAT;
	IDENTIFY VAR = LPE(1);
RUN;

PROC ARIMA DATA = TS_DAT;
	IDENTIFY VAR = LPE;
	ESTIMATE P = 1;
	ESTIMATE Q = 1;
	ESTIMATE P = 1 Q = 1;
	ESTIMATE P = 2;
RUN;

PROC ARIMA DATA = TS_DAT;
	IDENTIFY VAR = LPE;
	ESTIMATE P = 1;
	OUTLIER;
	FORECAST LEAD = 10 INTERVAL = YEAR ID = T OUT = GRAIN_FC;
RUN;
	
	
	
	
	
	
	
	
	
	



