local name eval2_simrun
* argument: #reps
confirm integer number `1'

* define and save the sim settings
pda
clear
input pc null
.2 0
.1 0
.4 0
.2 1
end
gen run=_n
expand 7
sort run
by run: gen or=(_n+1)/10
drop run
gen reps = `1'
set seed 45
gen seed = ceil(runiform()*10000)
save simsettings, replace

* do the simulation
* each run approx 40 minutes for 100k reps
simrun, settings(simsettings) program(eval2mysim) folder(resultfiles)

// THAT'S THE END. NOW DESCRIBE THE RESULTS

* summarise simulation
simcombine, settings(simsettings) program(eval2mysim) folder(resultfiles)

* Wald results
simsum b, se(se) bsims sesims power mcse by(pc or null n) 

* LRT results
gen sig_x2 = p_x2<0.05 if !mi(p_x2)
gen sig_lr = p_lr<0.05 if !mi(p_lr)
gen sig_wald = chi2tail(1,(b/se)^2)<0.05 if se>0
replace sig_wald = 9 if se==0
label def msg 9 "missing"
label val sig* msg
bysort pc or null n: table sig*, col row


/*
LRT is slightly anticonservative
e.g. for pc=0.2, type 1 error rate = 5.18% (5.04-5.32%)
adjusting for this (i.e. declaring significance at p<5th centile=0.0481 rather than p<0.05)
	reduces power 
		at or=0.2 from 92.9% to 92.4%
		at or=0.3 from 91.7% to 91.6%

forvalues or=.2(.1).8 {
	di as txt "OR=`or'"
	centile p_lr if null & or==float(`or'), centile(5)
	local crt=r(c_1)
	count if p_lr<.05 & !null & or==float(`or') & pc==float(0.2)
	count if p_lr<`crt' & !null & or==float(`or') & pc==float(0.2)
}
*/
