clear all
cd "C:\Users\sanja\Documents\2nd Year LSE MT\EC2C1"

cap log close
log using EC2C1EmpiricalProject.log, replace text

use BNPT_small, replace

describe
summarize
ssc install outreg2

*histogram to prove no manipulation in population estimate
histogram pop, xline(10189) xline(13585) xline(16091) xline(23773) xline(30565) xline(37357) xline(44149) width(300) freq title("Manipulation of Running Variable") 

*balance checks
rdplot literacy popnorm, c(0) p(1) h(4000) graph_options(legend(off)) xtitle(Normalised Population) ytitle("Literacy") title("Balance Checks: Literacy")
xi: ivregress 2sls literacy popnorm (fpm=fpm_hat) i.term,r cluster(city)

rdplot urb popnorm, c(0) p(1) h(4000) graph_options(legend(off))
xi: ivregress 2sls urb popnorm (fpm=fpm_hat) i.term,r cluster(city)

rdplot income popnorm, c(0) p(1) h(4000) graph_options(legend(off))
xi: ivregress 2sls income popnorm (fpm=fpm_hat) i.term,r cluster(city)

*first stage
xi:regress fpm fpm_hat pop i.term,r cluster(city),if (pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))

*first stage with state fixed effects
xi:regress fpm fpm_hat pop i.term i.state,r cluster(city), if (pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))


/*
threshold1=10189
threshold2=13585
threshold3=16091
threshold4=23773
threshold5=30565
threshold6=37357
threshold7=44149
*/


//CORRUPTION RESULTS

//fraction narrow
*fraction narrow doesn't let the size of each munipality affect too much, heterogenous treatment effects avoided. so don't use interaction terms.???/

*1200 bandwidth
xi: ivregress 2sls fraction_narrow pop (fpm=fpm_hat) i.term,r cluster(city), if (pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349)) 
outreg2 fpm using CORRUPTION.doc, bdec(3) keep(fpm) nocons tex(nopretty)replace

*1600 BANDWIDTH
xi: ivregress 2sls fraction_narrow pop (fpm=fpm_hat) i.term,r cluster(city), if (pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749))
outreg2 fpm using CORRUPTION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append

*2000 BANDWIDTH
xi: ivregress 2sls fraction_narrow pop (fpm=fpm_hat) i.term,r cluster(city) , if (pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))
outreg2 fpm using CORRUPTION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append

xi: ivregress 2sls fraction_narrow pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city) 

//NARROW DUMMY

*1200 bandwidth
xi: ivregress 2sls narrow pop (fpm=fpm_hat) i.term,r cluster(city), if (pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349))

*1600 BANDWIDTH
xi: ivregress 2sls narrow pop (fpm=fpm_hat) i.term,r cluster(city), if (pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749))

*2000 BANDWIDTH
xi: ivregress 2sls narrow pop (fpm=fpm_hat) i.term,r cluster(city) , if (pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))

xi: ivregress 2sls narrow pop pop_2 pop_3 (fpm=fpm_hat) i.term ,r cluster(city) 

//REELECTION

*additional federal transfers on the re-election of incumbent mayors 
*restrict to cities where the mayor reran and eligible

*rdplot to justify 3rd order polynomial
rdplot reelected popnorm, c(0) p(3) h(2000) graph_options(legend(off)), if noneligible==0&rerun==1

*1200
xi: ivregress 2sls reelected pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city) first, if (noneligible==0)&(rerun==1)&(pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349))
outreg2 fpm using REELECTION.doc, bdec(3) keep (fpm) nocons tex(nopretty)replace

*1600
xi: ivregress 2sls reelected pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city) , if (noneligible==0)&(rerun==1)&(pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749)) 
outreg2 fpm using REELECTION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append


*2000
xi: ivregress 2sls reelected pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city) , if (noneligible==0)&(rerun==1)&(pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))
outreg2 fpm using REELECTION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append

xi: ivregress 2sls reelected pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city), if noneligible==0&rerun==1

//following regressions to show not robust to changes in polynomial

*1200
xi: ivregress 2sls reelected pop pop_2 (fpm=fpm_hat) i.term,r cluster(city) , if (noneligible==0)&(rerun==1)&(pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349))

*1600
xi: ivregress 2sls reelected pop pop_2 (fpm=fpm_hat) i.term,r cluster(city) , if (noneligible==0)&(rerun==1)&(pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749)) 


*2000
xi: ivregress 2sls reelected pop pop_2 (fpm=fpm_hat) i.term,r cluster(city) , if (noneligible==0)&(rerun==1)&(pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))


*not particuarly robus to pop and pop_2 as we get negative results. (run the regs). but since we pool it and are looking for an averga eeffect, and the rdplot shows nice fitting of 3rd order arund 2000, i think it's a fair choice. 

xi: ivregress 2sls reelected pop pop_2 pop_3 (fpm=fpm_hat) i.term ,r cluster(city), if noneligible==0&rerun==1
xi: ivregress 2sls reelected pop pop_2 (fpm=fpm_hat) i.term,r cluster(city), if noneligible==0&rerun==1
xi: ivregress 2sls reelected pop  (fpm=fpm_hat) i.term,r cluster(city), if noneligible==0&rerun==1

//EDUCATION

*transfers on education of political challengers
*fraction of opps w/ college degree
*avg years of schooling also doesn't say much bc ppl do different length - retake years etc. w+w/0 college degree is perhaps a better measure. since question is on education and not skill, we can assume those with college degree are more educated than those without. 
*control for literacy rate? literacy rate is possible confounder

rdplot opp_college popnorm, c(0) p(2) h(2000) graph_options(legend(off))

xi: ivregress 2sls opp_college pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city)

*1200
xi: ivregress 2sls opp_college pop (fpm=fpm_hat) i.term,r cluster(city) , if(pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349))
outreg2 fpm using EDUCATION.doc, bdec(3) keep (fpm) nocons tex(nopretty)replace

*1600
xi: ivregress 2sls opp_college pop (fpm=fpm_hat) i.term,r cluster(city), if (noneligible==0)&(rerun==1)&(pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749)) 
outreg2 fpm using EDUCATION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append


*2000
xi: ivregress 2sls opp_college pop (fpm=fpm_hat) i.term,r cluster(city), if(pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))
outreg2 fpm using EDUCATION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append

//college is ROBUST TO different polynomials AND bandwidths
*1200
xi: ivregress 2sls opp_college pop pop_2 (fpm=fpm_hat) i.term,r cluster(city) , if(pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349))


*1600
xi: ivregress 2sls opp_college pop pop_2 (fpm=fpm_hat) i.term,r cluster(city), if (noneligible==0)&(rerun==1)&(pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749)) 


*2000
xi: ivregress 2sls opp_college pop pop_2 (fpm=fpm_hat) i.term,r cluster(city), if(pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))
outreg2 fpm using EDUCATION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append

*1200
xi: ivregress 2sls opp_college pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city) , if(pop >= (8989) & pop < (11389)) | (pop >= (12385) & pop < (14785)) | (pop >= (14891) & pop < (17291)) | (pop >= (22573) & pop < (24973)) | (pop >= (29365) & pop < (31765)) | (pop >= (36157) & pop < (38557)) | (pop >= (42949) & pop < (45349))


*1600
xi: ivregress 2sls opp_college pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city), if (noneligible==0)&(rerun==1)&(pop >= (8589) & pop < (11789)) | (pop >= (11985) & pop < (15185)) | (pop >= (14491) & pop < (17691)) | (pop >= (22173) & pop < (25373)) | (pop >= (28965) & pop < (32165)) | (pop >= (35757) & pop < (38957)) | (pop >= (42549) & pop < (45749)) 


*2000
xi: ivregress 2sls opp_college pop pop_2 pop_3 (fpm=fpm_hat) i.term,r cluster(city), if(pop >= (8189) & pop < (12189)) | (pop >= (11585) & pop < (15585)) | (pop >= (14091) & pop < (18091)) | (pop >= (21773) & pop < (25773)) | (pop >= (28565) & pop < (32565)) | (pop >= (35357) & pop < (39357)) | (pop >= (42149) & pop < (46149))
outreg2 fpm using EDUCATION.doc, bdec(3) keep (fpm) nocons tex(nopretty)append


*DID

*parallel trends

reg fraction_narrow fpm i.term if cnobs==2, cluster(cityr) absorb(cityr)
outreg2 fpm using DD.doc, bdec(3) keep (fpm) nocons tex(nopretty)replace

reg reelected fpm i.term if (cnobs==2)&(noneligible==0)&(rerun==1), cluster(cityr) absorb(cityr)
outreg2 fpm using DD.doc, bdec(3) keep (fpm) nocons tex(nopretty)append

reg opp_college fpm i.term if cnobs==2, cluster(cityr) absorb(cityr)
outreg2 fpm using DD.doc, bdec(3) keep (fpm) nocons tex(nopretty)append



log close 
