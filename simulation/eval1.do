/*
eval1.do
1st evaluation for paper
Data based on FLU-IVIG
OR varies from 0.2 to 0.8
Choose n for 90% power by Whitehead method
Compare powers by various methods and by simulation

v1 13may2020
	just the simulation, results listed not output to latex

v2 4feb2021
	both tables
	results output to latex

require adopath setup
argument: #reps
*/

confirm integer number `1'
local dir resultfiles\ // folder for results files
local name eval1
local resname = "`dir'"+"`name'"
prog drop _all
postutil clear
which artcat
cap mkdir `dir'

* setup
local pc1 .018
local pc2 .036
local pc3 .156
local pc4 .141
local pc5 .39
local pc `pc1' `pc2' `pc3' `pc4' `pc5'
local cats 6
local orlist .2 .3 .4 .5 .6 .7 .8
local nsims `1'
local run 1
local artcatopts unfavourable noheader noprobtable
set seed 58610506

// Table 1: SS by various methods
if `run' {
	dicmd postfile n or str10 method n using `resname'_n_postfile, replace
	foreach or of local orlist {
		foreach method in whitehead ologit(NN) ologit(NA) ologit(AA) {
			artcat, pc(`pc') or(`or') power(.9) `method' `artcatopts'
			post n (`or') ("`method'") (r(n))
		}
	}
	postclose n
}
dicmd use `resname'_n_postfile, clear
sencode method, gen(methnum)
tabdisp or methnum, c(n)
drop method
reshape wide n, i(or) j(methnum)
format or %6.1f
listtex or n1-n4 using `name'_n_out.tex, type rs(tabular) replace


// Table 2: power by various methods and simulation, with Whitehead SS

* simulate data
if `run' {
	postfile power or n str10 method power using `resname'_power_postfile, replace
	postfile sim or n i b se using `resname'_sim_postfile, replace
	foreach or of local orlist {
		di as input "OR = `or'"
		* run artcat
		artcat, pc(`pc') or(`or') power(.9) whitehead `artcatopts'
		local n=r(n)
		foreach method in whitehead ologit(NN) ologit(NA) ologit(AA) {
			artcat, pc(`pc') or(`or') n(`n') `method' `artcatopts'
			post power (`or') (`n') ("`method'") (r(power))
		}
		drop _all
		set obs `n'
		gen trt = mod(_n,2)
		di as input "Simulating for OR=`or'"
		local catsm1=`cats'-1
		forvalues i=1/`nsims' {
			dotter `i' `nsims'
			keep trt
			gen u = runiform()
			qui replace u = (u/`or') / (1-u+u/`or') if trt
			qui gen y = `cats'
			forvalues r=1/`catsm1' {
				gen thisp = `pc`r''
				qui replace y = `r' if u < thisp & u >= 0
				qui replace u = u - thisp
				drop thisp
			}
			assert !mi(y)

			cap ologit y trt
			if _rc==1 exit 1
			if !_rc post sim (`or') (`n') (`i') (_b[trt]) (_se[trt])
			else post sim (`or') (`n') (`i') (.) (.)
		}
	}
	postclose power
	postclose sim
}

* summarise simulation
use `resname'_sim_postfile, clear
simsum b, se(se) bsims sesims power mcse by(or) dropbig 
simsum b, se(se) power mcse by(or) dropbig clear
gen method = "Simulation"
rename b power
keep or method power 
save `resname'_sim_out, replace

* summarise n's
use `resname'_power_postfile, clear
keep if method=="whitehead"
keep or n
rename n power
gen method="Sample"
save `resname'_power_n, replace

* summarise calculated powers
use `resname'_power_postfile, clear
replace power=100*power
keep or method power 
save `resname'_power_out, replace

* combine
use  `resname'_power_n, clear
append using `resname'_power_out
append using `resname'_sim_out
sencode method, gen(methnum)
format power %6.1f
tabdisp or methnum, c(power)
drop method
reshape wide power, i(or) j(methnum)
format or %6.1f
rename power1 n
format n %6.0f
listtex or n power* using `name'_power_out.tex, type rs(tabular) replace
