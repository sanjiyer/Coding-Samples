clear all

*import csv file and tell stata to treat first row as variable names
import delimited "data\raw\school_data.csv", varnames(1)

*just checking data
describe

*replace csv file with dta file
save "data\raw\school_data.dta", replace
use "data\raw\school_data.dta", clear

*converting submissiondate from string to Stata date format to allow for easier manipulation to get variables such as WeekDummy and QuarterDummy
gen submission_date_stata = date(submissiondate, "DMY", 2020)
format submission_date_stata %td

*having inspected the data, this one school wrote math instead of Matheatics, hard coded to edit.
replace curriculumchange1 = "Mathematics" if schoolid == 3751768 & curriculumchange1 == "Math"

*schoolid 24740 has scores in 10,000s instead of 100s- divide through all score by 100 assuming error. 
foreach year of numlist 2000/2019 {
    replace mathematicsscore`year' = mathematicsscore`year' / 100 if schoolid == 24740
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

*I MANIPULATION

//////////////////////////////////////////////////////////////////////////////////////////////////////////////


*sort dataset by schoolid in ascending order of submissiondate,earlier submissions will come first.
sort schoolid curriculumchange1 submission_date_stata

*Drop duplicates, keeping the last observation for each school
bysort schoolid (submission_date_stata): keep if _n == _N

*create long format of curriculum changes so each curriculum change has it's own row,  ease of aggregation.
*convert all 3 curriculum changes into a single variable (curriculumchange) with multiple rows per school using the reshape command
reshape long curriculumchange, i(schoolid) j(change_num)

*drop the rows with 'None', to eliminate no curriculum change
drop if curriculumchange == "None" | missing(curriculumchange)

*use bysort command to group data by district, districtcode and curriculum change. Schools which is the count of unique schools in each district-subject combination, and gives count of reported changes.
bysort district curriculumchange: gen Schools = _N


*stores variable of the earliest submission date of a curriculum change for each group. 
bysort district districtcode curriculumchange (submission_date_stata): gen InitialChange = submission_date_stata[1]

/*
WeekDummy: whether the closest subsequent curriculum change happened less than 7 days after the first curriculum change
*/

* calculate days since InitialChange for each subsequent date within the same group
bysort district districtcode curriculumchange (submission_date_stata): gen DaysSinceInitial = submission_date_stata - InitialChange

* the closest subsequent change within 7 days (excluding InitialChange itself)
bysort district districtcode curriculumchange: gen WeekDummy = DaysSinceInitial > 0 & DaysSinceInitial <= 7

/*
QuarterDummy: whether the median curriculum change happened less than 90 days after the first curriculum change. 
*/

*median date of curriculum changes in each district-subject group.
bysort district districtcode curriculumchange (submission_date_stata): egen MedianChange = median(submission_date_stata)

*difference between the median change date and the initial change date (InitialChange)
bysort district districtcode curriculumchange: gen QuarterDummy = (MedianChange - InitialChange) < 90

/*
Some discrict names correspond to more than 1 district id. Chosen to address by keeping the districtid that appears most frequently for each districtname
*/

*times each districtcode appears for each districtname
bysort district districtcode: gen districtcode_count = _N

*identify and select districtcode with the maximum occurrence for each districtname
bysort district (districtcode_count): gen max_occurrence = districtcode_count[_N]
bysort district: gen most_frequent_districtcode = districtcode if districtcode_count == max_occurrence

*keep only the row with the most frequent districtcode for each districtname
bysort district: keep if districtcode == most_frequent_districtcode

*Inspect the results for a specific districtname: list district most_frequent_districtcode if district == "Cross Roads Independent School District"

*counting the total number of curriculum changes for each district-subject group
bysort district curriculumchange: gen TotalChanges = _N

*collapse the data so that each row represents district-districtcode-CurriculumSubject combination.
collapse (count) Schools (count) TotalChanges (min) InitialChange (max) WeekDummy (max) QuarterDummy, by(district districtcode curriculumchange)

* Format the new initialchange variable to display as a readable date, not stata date format.
format InitialChange %td

* Keep only the variables for the new dataset
keep districtcode district curriculumchange Schools TotalChanges InitialChange WeekDummy QuarterDummy

* Rename variables for clarity
rename districtcode DistrictID
rename district DistrictName
rename curriculumchange CurriculumSubject

export delimited using "data\processed\school_data_processed.csv", replace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

*II VISUALISATION

//////////////////////////////////////////////////////////////////////////////////////////////////////////////


use "data\raw\school_data.dta", clear

*converting submissiondate from string to Stata date format to allow for easier manipulation to get variables such as WeekDummy and QuarterDummy
gen submission_date_stata = date(submissiondate, "DMY", 2020)
format submission_date_stata %td

*having inspected the data, this one school wrote math instead of Matheatics, hard coded to edit.
replace curriculumchange1 = "Mathematics" if schoolid == 3751768 & curriculumchange1 == "Math"

*schoolid 24740 has scores in 10,000s instead of 100s- divide through all score by 100 assuming error. 
foreach year of numlist 2000/2019 {
    replace mathematicsscore`year' = mathematicsscore`year' / 100 if schoolid == 24740
}

*sort by schoolid and drop duplicates.
sort schoolid 
duplicates drop schoolid, force

*binary variable whether a school had a math curriculum change
gen math_change = 0
replace math_change = 1 if curriculumchange1 == "Mathematics" | curriculumchange2 == "Mathematics" | curriculumchange3 == "Mathematics"

*wide to long for easier manipulation (one observation per school-year)
reshape long mathematicsscore, i(schoolid) j(year)

*average scores
bysort year math_change: egen mean_score = mean(mathematicsscore)

*standard deviation
bysort year math_change: egen sd_score = sd(mathematicsscore)

*standard error
bysort year math_change: gen se = sd_score / sqrt(_N)


*confidence intervals
bysort year math_change: gen ci_lower = mean_score - 1.96 * se
bysort year math_change: gen ci_upper = mean_score + 1.96 * se

*graphing
twoway (rcap ci_lower ci_upper year if math_change == 1, lcolor(blue) lwidth(medium) ///
        legend(label(1 "With Change"))) ///
       (line mean_score year if math_change == 1, lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (scatter mean_score year if math_change == 1, msymbol(x) mcolor(blue) msize(medium)) /// 
       (rcap ci_lower ci_upper year if math_change == 0, lcolor(red) lwidth(medium) ///
        legend(label(2 "No Change"))) ///
       (line mean_score year if math_change == 0, lcolor(red) lwidth(medium) lpattern(solid)) ///
       (scatter mean_score year if math_change == 0, msymbol(x) mcolor(red) msize(medium)), ///
       title("Average Math Scores by Curriculum Change (2000-2019)") ///
       legend(order(2 "With Change" 5 "No Change") colfirst) /// 
       ytitle("Average Math Score") xtitle("Year") /// 
       ylabel(200(100)800) yscale(range(200 800))

* Export the graph to PNG format
graph export "figures\math_score.png", as(png) replace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

*III ANALYSIS

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

*clean household income variables
gen income2005_clean = subinstr(subinstr(householdincome2005, "$", "", .), ",", "", .)
gen income2015_clean = subinstr(subinstr(householdincome2015, "$", "", .), ",", "", .)
destring income2005_clean, replace force
destring income2015_clean, replace force
gen income2005_int = round(income2005_clean)
gen income2015_int = round(income2015_clean)

*log transformation to mathematicsscore for percentage change interpretation
gen ln_mathematicsscore = ln(mathematicsscore)

*variables for Difference-in-Differences 
gen post2010 = year >= 2010  //post-2010
gen treat = math_change  //treatment (math curriculum change dummy)
gen treat_post2010 = treat * post2010  // interaction term for DiD
gen income_change = income2015_int - income2005_int  // change in household income

*Regression 1: basic difference-in-differences regression on log-transformed score, without fixed effects
regress ln_mathematicsscore treat post2010 treat_post2010 income2005_int income2015_int income_change, robust

*export the first regression results
outreg2 using "tables/regression_results.tex", replace /// 
    ctitle("Basic DiD (Log of Math Score)") /// 
    keep(treat_post2010) label /// 
    dec(4)

*Regression 2: Fixed Effects DiD regression on log-transformed math scores with school fixed effects
xtset schoolid year  //   panel data structure
xtreg ln_mathematicsscore treat post2010 treat_post2010 income2005_int income2015_int income_change, fe robust cluster(schoolid)

*add the second regression results to the same document
outreg2 using "tables/regression_results.tex", append /// 
    ctitle("Fixed Effects DiD (Log of Math Score)") /// 
    keep(treat_post2010) label /// 
    dec(4)