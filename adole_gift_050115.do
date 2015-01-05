clear
cd "\\fsp-kec2\HISS PROJECT\GAP Data\NNPGH\RequestsForData\GiftWango"

use C:\Users\lnguti\Desktop\NNPGH\DATA\RAW\tbhivadultenrl_v6_v5.dta, clear
keep gender patid enrol_date  dob age bmi who cd4 supptgrp s_supptgrp/*
*/ weight height past_arv treated_tb tb_stat /*
*/ arv_eligible psycho_suppt source psycho_soc referrals_made
*disclosure disclosure_who discontinued1 discontinued2 discontinued3 
keep if age >=10 & age <=19
gen isadult=1
gen encounter_date=enrol_date
gen encounter_yr=year(enrol_date)
gen encounter_month=month(enrol_date)
drop if encounter_yr >2014 |encounter_yr <2010
gen source_form="adult enrolment"

label variable age "client's age"
label variable dob "client's date of birth"
label variable gender "client's sex"
label variable cd4 "CD4 result"
label variable psycho_soc "psychosocial support"
label variable referrals_made "referrals made by the clinician"
label variable arv_eligible "is the clients eligible for ARVs in this visit"
label variable tb_stat "TB status from the ICF tool"
label variable patid "client's ID"
label variable source_form "the form in which the data was "
label variable   supptgrp "is client member of a support group"
label variable   s_supptgrp "is the support group facility or community"
label variable   who "WHO stage in this visit"
label variable   source "form version"
label variable   past_arv "has client been on ARVs before enrolment"
label variable   treated_tb "has client been treated for TB before enrolment"
label variable encounter_yr "year of encounter"
label variable  encounter_month "month of encounter"

label define months 1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" 8 "aug" /*
*/ 9 "sep" 10 "oct" 11 "nov" 12 "dec" 
label define sex1 1 "female" 2 "male"
label define yesno1 1 "yes" 2 "no"
label define tbstat1 1 "no signs" 2 "tb suspect" 3 "tb treatment"
save adultenrolment_Gift.dta,replace

*to get a report on completeness;
mvpatterns


use C:\Users\lnguti\Desktop\NNPGH\DATA\RAW\TBHIVAdultFollowUp_v5_v6.dta, clear
keep follup_date gender disclosure disclosure_who supptgrp s_supptgrp bmi cd4 /*
*/ who tb_stat height miss_drugs reason_miss_drug smed_assist adherence1 adherence2/*
*/ adherence3 reasons someone  psyco_soc psyco_suppt  patid arv_eligible/*
*/ weight source med_assist
*discontinu3  discontinu2 discontinu1
/*rename discontinu1 discontinued1
rename discontinu2 discontinued2
rename discontinu3 discontinued3*/
gen isadult=1
gen source_form="adult follow up"
replace source="v6.1" if source=="fup v6.1"  
gen encounter_date=follup_date

gen encounter_yr=year(follup_date)
gen encounter_month=month(follup_date)

*drop medi_assist
gen medi_assist =1 if someone==1|med_assist==1
replace medi_assist=2 if someone==2|med_assist==2

drop if encounter_yr >2014  |encounter_yr <2010
sort patid 

save adultFollup_Gift.dta,replace


clear
use C:\Users\lnguti\Desktop\NNPGH\DATA\RAW\Reception_Enrolment_131014.dta 
sort patid
merge patid using adultFollup_Gift.dta
keep if _merge==3
*drop years_in_care
gen years_in_care=0
replace years_in_care=(follup_date-regdate)/365.25
drop if years_in_care < 0
gen current_age=years_in_care+age
keep if current_age >= 10 & current_age <=19
 
drop regdate years_in_care age 
rename current_age age
drop _merge
*to fill in missing gender;
gen sex2=1
replace sex2=2 if sex=="M"
replace sex2=. if sex=="9"  
replace gender=sex2 if gender ==.  
drop sex sex2
save adult_adole_Gift.dta,replace

*PEDIATRICS
clear
use C:\Users\lnguti\Desktop\NNPGH\DATA\RAW\Paed_fup6_1.dta 
keep patid age follup_date dob gender c_disclosure c_hiv level_of_disclosure disclosure_date /*
*/ m_children_club club height weight bmi cd4 drtesting drt_date arv_eligible psycho_soc/*
*/ referrals_made app_date tb_stat  who arv_eligible 
keep if age >= 10 & age <=19
gen source="v6.1"
gen isadult=0
gen source_form="peds follow up"
gen encounter_date=follup_date
gen encounter_yr=year(follup_date)
gen encounter_month=month(follup_date)
drop if encounter_yr >2014 |encounter_yr <2010
tostring(psycho_soc),gen(psycho_soc2)
drop psycho_soc
rename psycho_soc2 psycho_soc
save peds_adole_v6.dta,replace

clear
use C:\Users\lnguti\Desktop\NNPGH\DATA\RAW\Paed_fup_v5.dta 
keep patid  age follup_date dob gender disclosure c_hiv  supportgrp club height /*
*/ weight bmi cd4    psycho_soc  tb_stat  who 
 *drop age1
destring(age), gen(age1) force 
gen age_calc=(follup_date-dob)/365.25
replace age_calc= age1 if age_calc< 1
 drop age1 age
keep if age_calc >= 10 & age_calc <= 19
gen source="v5"
gen isadult=0
gen source_form="peds follow up"
gen encounter_date=follup_date
gen encounter_yr=year(follup_date)
gen encounter_month=month(follup_date)
drop if encounter_yr >2014 |encounter_yr <2010
rename age_calc age
save peds_adole_v5.dta,replace
mvpatterns


*MERGE THE 4 DATASETS TO MAKE ONE ADOLESCENTS DATASET
*1. merging the adults data
use adultenrolment_Gift.dta, clear
append using adult_adole_Gift.dta
save adults_all.dta,replace
*2. merging the pediatric datasets
use  peds_adole_v6.dta,clear
append using peds_adole_v5.dta
save peds_all.dta,replace
*3.append the adults dataset with the pediatrics
use adults_all.dta , clear
tostring (disclosure), gen(disclosure2)
drop disclosure
rename disclosure2 disclosure
append using peds_all.dta
save adolescents_101214.dta,replace
*overall completeness reports 
tab source_form source 
tab source
tab isadult



use adolescents_101214.dta,clear

label variable age "client's age"
label variable dob "client's date of birth"
label variable gender "client's sex"
label variable c_disclosure "who in child's family knows the status"
label variable c_hiv "has HIV status been disclosed to child"
label variable disclosure_date "date HIV status disclosed to child"
label variable level_of_disclosure "level of disclosure to child"
label variable cd4 "CD4 result"
label variable drtesting "drug resistance test requested"
label variable drt_date "date drug resistance test requested"
label variable psycho_soc "psychosocial support"
label variable referrals_made "referrals made by the clinician"
label variable app_date "date of next appointment"
label variable arv_eligible "is the clients eligible for ARVs in this visit"
label variable m_children_club "Is the child in childrens club"
label variable club "Is the club facility or community based"
label variable tb_stat "TB status from the ICF tool"
label variable patid "client's ID"
label variable isadult "is the client over 14yrs"
label variable source_form "the form in which the data was "
label variable encounter_yr "year of encounter"
label variable  encounter_month "month of encounter"
label variable  disclosure "has adult client disclosed status"
label variable   disclosure_who "to whom has adult client disclosed status"
label variable   supptgrp "is client member of a support group"
label variable   s_supptgrp "is the support group facility or community"
label variable   who "WHO stage in this visit"
*label variable   discontinued1 "reason for regimen discontinuation"
*label variable   discontinued2 "reason for regimen discontinuation"
*label variable   miss_drugs "has the client missed drugs"
*label variable   reason_miss_drug "reason the client missed drugs"
label variable   smed_assist "does someone assist client in taking drugs "
label variable   source "form version"
label variable   past_arv "has client been on ARVs before enrolment"
label variable   treated_tb "has client been treated for TB before enrolment"

label define months 1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" 8 "aug" /*
*/ 9 "sep" 10 "oct" 11 "nov" 12 "dec" 
label define sex1 1 "female" 2 "male"
label define yesno1 1 "yes" 2 "no"
label define tbstat1 1 "no signs" 2 "tb suspect" 3 "tb treatment"

label values encounter_month months 
label values gender sex1 
label values tb_stat tbstat1 




save adolescents_101214.dta,replace
*to subset data
use adolescents_final.dta,clear
*Reports ***written 22/10/14
*1 age groups
*drop age_group
use adolescents_101214.dta,clear
gen age2=age
if age==. replace age2=(encounter_date-dob)/365.25
gen age_group=0
replace age_group=1 if age2 >=9 & age2 <=13
replace age_group=2 if age2 >13 & age2 <=16
replace age_group=3 if age2 >16 & age2 <=19
drop age

label define age_group1 1 "early(9-13 yrs)" 2 "mid(13-16 yrs)" 3 "late(16-19 yrs)"
label values age_group age_group1 
tab age_group,m

*2: number of adolescents in dataset
label define sex1 1 "female" 2 "male"
label values gender sex1 
by patid, sort:gen nvals=_n==1
tab gender if nvals==1,m
tab age_group gender if nvals==1,m

keep if encounter_date > d(01oct2013) & encounter_date < d(01oct2014)
keep if nvals==1

gen support_group=0
replace support_group=1 if supptgrp==1
replace support_group=1 if m_children_club==1

tab support_group
*supptgrp m_children_club

*3 to recode disclosure into one variable
gen disclosure_all=0
replace disclosure_all=1 if disclosure==1
replace disclosure_all=1 if c_hiv==1

tab disclosure_all if age_group==1
tab disclosure_all if age_group==2
tab disclosure_all if age_group==3









