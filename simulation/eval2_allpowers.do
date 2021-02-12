/* eval2_allpowers
vars: pc or n str20(method) power power_mcse
*/
local name eval2_allpowers
* load powers by simulation (made by eval2_simrun)
simcombine, settings(simsettings) program(eval2mysim) folder(resultfiles)

* Wald N/A
gen waldna = se==0
table or null pc, c(mean waldna)
drop waldna

gen sig_x2 = p_x2<0.05 if !mi(p_x2)
gen sig_lr = p_lr<0.05 if !mi(p_lr)
gen sig_wald = chi2tail(1,(b/se)^2)<0.05 if se>0
*bysort pc or: ci proportion sig_*

collapse (mean) sig* (count) nsim_x2=sig_x2 nsim_lr=sig_lr nsim_wald=sig_wald, by(pc null or n)
reshape long sig nsim, i(pc null or n) j(method) string
replace method = "3. Pearson" if method=="_x2"
replace method = "2. LRT" if method=="_lr"
replace method = "1. Wald" if method=="_wald"
replace method = "8."+method+" sim" if !null
replace method = "9."+method+" null" if null
gen power=sig
gen power_mcse=sqrt(sig*(1-sig)/nsim)
drop sig nsim null

// appends powers by calculation 
append using eval2_power
sort pc or n method
format power* %6.3f
l, sepby(pc or)
save `name'_out, replace

// summary output
use `name'_out, clear
drop if method=="3. whitehead"
drop if method=="8.2. LRT sim"
drop if method=="9.2. LRT null"
replace power=100*power
replace power_mcse=100*power_mcse
format power* %6.1f
tabdisp or method if pc==float(.2), c(power power_mcse)

// LaTeX output
encode method, gen(mm)
drop method
drop power_mcse
tab mm
reshape wide power, i(pc or n) j(mm)
gen gap = .
listtex or n power1-power2 gap power3-power5 gap power6-power7 gap power8-power9 using `name'_out.tex if pc==float(0.2), type rs(tabular) replace

