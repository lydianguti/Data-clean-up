/******/
clear
set more off 
cap log close

* to set working directory
cd "C:\Users\lnguti\Desktop\NNPGH"

* start generating STATA log file
log using "LOGS\Data_cleaning_200514.smcl", replace
*1a. to bring in Adult_fup6_1pt1 and save sorted dataset
odbc load, exec("select * from Adult_fup6_1pt1;")dsn (JOOTRH2014)clear
gen source="adultfup_v6.1_pt1"
*import excel "DATA\RAW\Adult_fup6_1pt1.xlsx", sheet("Adult_fup6_1pt1") firstrow clear
describe

rename Patid patid
*to fill in PATID with TI_ID for blanks in PATID
tab patid
gen str8 patid2 = subinstr(patid," ","",.) 
*drop patid3
gen patid3=patid2
replace patid3=TI_id if (patid2=="-" | patid2==" ")
*list patid3 patid2 patid TI_id in 1/20
*gen source='adult fup v6.1 part1'
sort patid3 follup_date
save DATA\RAW\adult_fup_pt1, replace

*1b. to bring in Adult_fup6_1pt2 and save sorted dataset
*import excel "DATA\RAW\Adult_fup6_1pt2.xlsx", sheet("Adult_fup6_1pt2") firstrow clear
odbc load, exec("select * from Adult_fup6_1pt2;")dsn (JOOTRH2014)clear
gen source="adultfup_v6.1_pt2"

*to fill in PATID with TI_ID for blanks in PATID
*describe
tab patid
gen str8 patid2 = subinstr(patid," ","",.) 
*drop source patid3
gen patid3=patid2
*replace patid3=TI_id if (patid2=="-" | patid2==" ")
drop if patid3=="-"
*list patid3 patid2 patid TI_id in 1/20
sort patid3 follup_date
save DATA\RAW\adult_fup_pt2,replace

*1c. to bring in Adult_fup6_1pt3 and save sorted dataset
*import excel "DATA\RAW\Adult_fup6_1pt3.xlsx", sheet("Adult_fup6_1pt3") firstrow clear
odbc load, exec("select * from Adult_fup6_1pt3;")dsn (JOOTRH2014)clear
*to fill in PATID with TI_ID for blanks in PATID
gen source="adultfup_v6.1_pt3"

describe
tab patid
gen str8 patid2 = subinstr(patid," ","",.) 
*gen source='adult fup v6.1 part3'

*drop patid3
gen patid3=patid2
drop if patid3=="-"
*replace patid3=TI_id if (patid2=="-" | patid2==" ")
*list patid3 patid2 patid TI_id in 1/20
drop if patid3=="-"
sort patid3 follup_date
save DATA\RAW\adult_fup_pt3,replace

*to MERGE the 3 tables to make one Adult Follow Up version 6.0 table;
use DATA\RAW\adult_fup_pt1,clear
merge  patid3 follup_date using DATA\RAW\adult_fup_pt2
drop _merge
*save adult_fup_pt1_2,replace
sort patid3 follup_date
merge patid3 follup_date using adult_fup_pt3
gen adult_ped_ind=2
drop _merge Form_Id
save DATA\RAW\adult_fup_v6_all,replace
*describe
*to remove duplicate records;
duplicates drop
*to manipulate variables to enable merge with other datasets
use DATA\RAW\adult_fup_v6_all,clear

tostring(BP),gen(BP2)
drop BP 
rename BP2 BP
save DATA\RAW\adult_fup_v6_all,replace


*2. to bring in EXPRESS FOLLOW UP FORM and save sorted dataset
odbc load, exec("select * from Express_adult_followup;")dsn (NNPGH)clear
gen source="express"
*2a. to manipulate some of the variables in EXPRESS table to match adult_fup_v6_all
rename sexually_active sexual
rename patid patid3



gen FP=1 if FP_used1 | FP_used2 !=. 
gen miss_drugs=1 if missed_pills != "  " 
drop missed_pills FP_used1 FP_used2
sort patid follup_date
save DATA\RAW\express_followup,replace

*2b. append with ADULT FOLLOW UP version 6.0
use DATA\RAW\express_followup,clear
append using DATA\RAW\adult_fup_v6_all
save DATA\RAW\adult_fup_all,replace


*to remove duplicate records;
duplicates drop

*PEDIATRICS DATASET
import excel "DATA\RAW\Paed_fup6_1pt1.xlsx", sheet("Paed_fup6_1pt1") firstrow clear
*describe
sort patid follup_date
save DATA\RAW\Paed_fup6_1pt1, replace

import excel "DATA\RAW\Paed_fup6_1pt2.xlsx", sheet("Paed_fup6_1pt2") firstrow clear
*describe
sort patid follup_date
save DATA\RAW\Paed_fup6_1pt2, replace
*browse

import excel "DATA\RAW\Paed_fup6_1pt3.xlsx", sheet("Paed_fup6_1pt3") firstrow clear
*describe
sort patid follup_date
save DATA\RAW\Paed_fup6_1pt3, replace
*browse
*to merge the three parts of the PEDIATRIC FOLLOW UP data set to make a combined;
use DATA\RAW\Paed_fup6_1pt1, clear
merge  patid follup_date using DATA\RAW\Paed_fup6_1pt2
drop _merge
*save adult_fup_pt1_2,replace
sort patid follup_date
merge patid follup_date using DATA\RAW\Paed_fup6_1pt3
gen adult_ped_ind=1
drop Form_Id _merge
save DATA\RAW\pediatric_fup_v6_all,replace
*describe
*codebook

*changes to be made to ADULTS FOLLOW UP dataset to enable merge with PEDIATRIC

use DATA\RAW\adult_fup_v6_all, clear
replace ALT=subinstr(ALT," ","",.) 
destring(ALT),gen(ALT2)
drop ALT 
rename ALT2 ALT

replace creatinine=subinstr(creatinine," ","",.) 
destring(creatinine),gen(creatinine2)
drop creatinine 
rename creatinine2 creatinine

replace HB=subinstr(HB," ","",.) 
destring(HB),gen(HB2)
drop HB 
rename HB2 HB

replace SerumCRAG=subinstr(SerumCRAG," ","",.) 
destring(SerumCRAG),gen(SerumCRAG2)
drop SerumCRAG 
rename SerumCRAG2 SerumCRAG

*drop Drg1a_2 Drg1a_3
tostring(Drg1a),gen(Drg1a_2)
gen Drg1a_3=Drg1a_2
replace Drg1a_3="0"+Drg1a_2 if length(Drg1a_2)==1
replace Drg1a_3="" if Drg1a_2=="."
*tab Drg1a_3 
drop Drg1a Drg1a_2
rename Drg1a_3 Drg1a

/*replace LMP_date_N_A=subinstr(LMP_date_N_A," ","",.) 
destring(LMP_date_N_A),gen(LMP_date_N_A2)
drop LMP_date_N_A 
rename LMP_date_N_A2 LMP_date_N_A*/

tab Height
replace Height=subinstr(Height," ","",.) 
destring(Height),gen(Height2)
drop Height 
rename Height2 Height


tab miss_drugs
replace miss_drugs=subinstr(miss_drugs," ","",.) 
destring(miss_drugs),gen(miss_drugs2)
drop miss_drugs 
rename miss_drugs2 miss_drugs

tab Chemistry
replace Chemistry=subinstr(Chemistry," ","",.) 
destring(Chemistry),gen(Chemistry2)
drop Chemistry 
rename Chemistry2 Chemistry

tab M_sputumCulture
replace M_sputumCulture=subinstr(M_sputumCulture," ","",.) 
destring(M_sputumCulture),gen(M_sputumCulture2)
drop M_sputumCulture 
rename M_sputumCulture2 M_sputumCulture


tab Virology
replace Virology=subinstr(Virology," ","",.) 
destring(Virology),gen(Virology2)
drop Virology 
rename Virology2 Virology

tab Others
replace Others=subinstr(Others," ","",.) 
destring(Others),gen(Others2)
drop Others 
rename Others2 Others

tab Pt_ARV_today
replace Pt_ARV_today=subinstr(Pt_ARV_today," ","",.) 
destring(Pt_ARV_today),gen(Pt_ARV_today2)
drop Pt_ARV_today 
rename Pt_ARV_today2 Pt_ARV_today

/*tab Ncondoms
replace Ncondoms=subinstr(Ncondoms," ","",.) 
destring(Ncondoms),gen(Ncondoms2)
drop Ncondoms 
rename PNcondoms2 Ncondoms*/

tab referrals
replace referrals=subinstr(referrals," ","",.) 
destring(referrals),gen(referrals2)
drop referrals 
rename referrals2 referrals

tab CD4_NA
replace CD4_NA=subinstr(CD4_NA," ","",.) 
destring(CD4_NA),gen(CD4_NA2)
drop CD4_NA 
rename CD4_NA2 CD4_NA

save DATA\RAW\adult_fup_v6_all,replace

*changes to be made to PEDIATRIC FOLLOW UP dataset to enable merge with adults


use DATA\RAW\pediatric_fup_v6_all,clear
tostring(OthregimenSpecify),gen(OthregimenSpecify_2)
drop OthregimenSpecify 
rename OthregimenSpecify_2 OthregimenSpecify

tostring(LMP_date_N_A),gen(LMP_date_N_A2)
drop LMP_date_N_A 
rename LMP_date_N_A2 LMP_date_N_A


tostring(Other_examination),gen(Other_examination2)
drop Other_examination 
rename Other_examination2 Other_examination


tostring(app_date_N_A),gen(app_date_N_A2)
drop app_date_N_A 
rename app_date_N_A2 app_date_N_A


save DATA\RAW\pediatric_fup_v6_all,replace




*to append ADULT FOLLOW UP with PEDIATRIC FOLLOW UP
append using DATA\RAW\adult_fup_v6_all
save DATA\RAW\Follow_up_v6,replace
use DATA\RAW\Follow_up_v6,clear

*to get a summary of missing values in the must-fill questions;
tabmiss patid follup_date gender Section Type_of_visit disclosure employment ///
Substance_abuse HIV_risk_behavr supptgrp sexually_active Height Pulse BMI temp ///
BP SPO2 Weight N_Init taking_ffdrgs Hospitalization Func_ass Pallor Oedema ///
Jaundice Lymphadenopathy OralThrush F_clubbing ENT LN WHO Investigation ///
app_date app_date_N_A QAO TB_stat STI_Screening





*To clean variables;
*1. PATID;
*a.check for scanner errore
*To create a flagging variable for TIs
split patid ,gen(pat) parse(-)
gen TI_flag=regexm(pat2,"[TI]")
*list TI_flag pat2 patid
gen patid_error =regexm(patid,"[A-Z]")  if TI_flag==0
tab patid_error
*to output the PATIDs with errors for correction using source documents 
list patid follup_date if patid_error==1
*list patid if patid_error==1
*b.to check for out of range patient IDs when compared to the year indicated



*VERSION 5 
*ADULT FOLLOW UP
*VERSION 5.0
import excel "DATA\RAW\Adult_fu-pt1.xlsx", sheet("Adult_fu-pt1") firstrow clear
*describe
duplicates drop patid follup_date,force
sort patid follup_date
save DATA\RAW\Adult_fu-pt1, replace

import excel "DATA\RAW\Adult_fu-pt2.xlsx", sheet("Adult_fu-pt2") firstrow clear
*describe
*drop dup_flag
*duplicates tag  patid follup_date,gen(dup_flag)
*browse if dup_flag==1
duplicates drop patid follup_date,force
sort patid follup_date
save DATA\RAW\Adult_fu-pt2, replace
describe


use DATA\RAW\Adult_fu-pt1,clear
merge patid follup_date using DATA\RAW\Adult_fu-pt2
save DATA\RAW\Adult_follup_v5_0

*VERSION 5.1
import excel "DATA\RAW\Adult_fu-pt1v5_1.xlsx", sheet("Adult_fu-pt1v5_1") firstrow clear
*describe
duplicates drop patid follup_date,force
sort patid follup_date
save DATA\RAW\Adult_fu-pt1v5_1, replace


import excel "DATA\RAW\Adult_fu-pt2v5_1.xlsx", sheet("Adult_fu-pt2v5_1") firstrow clear
*describe
duplicates drop patid follup_date,force
sort patid follup_date
save DATA\RAW\Adult_fu-pt2v5_1, replace

use DATA\RAW\Adult_fu-pt1v5_1,clear
merge patid follup_date using DATA\RAW\Adult_fu-pt2v5_1
save DATA\RAW\Adult_follup_v5_1

*VERSION 5.2
import excel "DATA\RAW\Adult_fu-pt1v5_2.xlsx", sheet("Adult_fu-pt1v5_2") firstrow clear


/*DISCONTINUATION DATABASE CLEANING;*/
use DATA\RAW\DiscontinuationKEMRI,clear
*label the variables
 label name1 "Initial of first name of patient"
 label name2 "Initial of second name of patient"
 label name3 "Initial of third name of patient"
 label d01 "Reason for patient discontinuation"
 label withd_da "Day Of Patient Withdrawal"
 label withd_mo "Month Of Patient Withdrawal"
 label withd_yr "Year Of Patient Withdrawal"
 label d01a "Year Of Patient Withdrawal"

 
        da2 da3 da1
*MPLUS DISCONTINUATION DATASET

use DATA\RAW\DISCOMPLUS,clear
*label the variables
label variable xa_yr "Year Of Patient Withdrawal"
label variable xb_yr  "Year Of Death"
label variable xc_yr  "Year Of Last Negative HIV Test"
label variable xd1_yr "Year Attempt #1 Was Made"
label variable comp_da "day Form Completed " 
label variable comp_mo "month Form Completed "
label variable comp_yr "year Form Completed "
label variable x1 "Reason For Pt Discontinuation"
label variable xa_da "Day Of Patient Withdrawal"
label variable xa_mo "Month Of Patient Withdrawal"
label variable xa_yr "Year Of Patient Withdrawal"
label variable xatxt "Patient Requesting Withdrawal From Program - Reasons Given"
label variable xa1 "Patient Requesting Withdrawal From Program Information Source - Patient"
label variable xa2 "Patient Requesting Withdrawal From Program Information Source - Friend / Relative"
label variable xa3 "Patient Requesting Withdrawal From Program Information Source - Other"
label variable xb_da "Date Of Death (Day)"
label variable xb_mo "Date Of Death (Month)"
label variable xb_yr "Date Of Death (Year)"
label variable xbtxt "Cause Of Death"
label variable xbunk "Cause Of Death Not Known"
label variable xb1 "Deceased Report Information Source - Death Certificate"
label variable xb2 "Deceased Reported By Friend / Relative"
label variable xb3 "Deceased Information Source-Hospital Records"
label variable xb4 "Deceased Information Source - Other"
label variable xb4txt "Deceased Information Source -  Other Description"
label variable xc_da "Infant HIV-Negative - Date Of Last Negative HIV Test (Day)"
label variable xc_mo "Infant HIV-Negative - Date Of Last Negative HIV Test (Month)"
label variable xc_yr "Infant HIV-Negative - Date Of Last Negative HIV Test (Year)"
label variable xc1 "Infant Determined To Be HIV-Negative - Type Of Last HIV Test"
label variable xc1txt "Infant HIV-Negative - Type Of Last HIV Test Other Description"
label variable xc2 "Infant  HIV-Negative - Approx # Of Months Since Last Breast Feeding"
label variable xd_da "Patient LTFU - Date Of Last Scheduled Appointment Missed (Day)"
label variable xd_mo "Patient LTFU - Date Of Last Scheduled Appointment Missed  (Month)"
label variable xd_yr "Patient LTFU - Date Of Last Scheduled Appointment Missed  (Year)"
label variable xd1 "Patient LTFU Attempt #1 - Type Of Attempt"
label variable xd1txt "Patient LTFU Attempt #1 - Type Of Attempt Other Description"
label variable xd1_da "Patient LTFU Attempt #1 - Date Attempt #1 Was Made (Day)"
label variable xd1_mo "Patient LTFU Attempt #1 - Date Attempt #1 Was Made (Month)"
label variable xd1_yr "Patient LTFU Attempt #1 - Date Attempt #1 Was Made (Year)"
label variable xd2 "Patient LTFU Attempt #2 - Type Of Attempt"
label variable xd2txt "Patient LTFU Attempt #2 - Type Of Attempt Other Description"
label variable xd2_da "Patient LTFU Attempt #2 - Date Attempt #2 Was Made (Day)"
label variable xd2_mo "Patient LTFU Attempt #2 - Date Attempt #2 Was Made (Month)"
label variable xd2_yr "Patient LTFU Attempt #2 - Date Attempt #2 Was Made (Year)"
label variable xd3 "Patient LTFU Attempt #3 - Type Of Attempt"
label variable xd3txt "Patient LTFU Attempt #3 - Type Of Attempt  Other Description"
label variable xd3_da "Patient LTFU Attempt #3 - Date Attempt #3 Was Made (Day)"
label variable xd3_mo "Patient LTFU Attempt #3 - Date Attempt #3 Was Made (Month)"
label variable xd3_yr "Patient LTFU Attempt #3 - Date Attempt #3 Was Made (Year)"
label variable xccomm "Program Discontinuation Comments"

  
*to recode the variable d01 using the values of x1
drop d01
gen d01=.
replace d01=7 if x1==4 
replace d01=x1 if x1==1 | x1==2 | x1==3 
tab d01 x1

*to rename the variables to match those in the KEMRI dataset ; 
rename comp_yr disc_yr
rename comp_da disc_da
rename comp_mo disc_mo
rename xa_yr withd_yr
rename xa_da withd_da
rename xa_mo withd_mo
rename xb_da  death_da
rename xb_mo death_mo
rename xb_yr death_yr
rename xc_da test_da
rename xc_mo test_mo
rename xc_yr test_yr	

save DATA\RAW\DISCOMPLUS_2,replace
