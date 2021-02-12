prog def eval2mysim, rclass
/*
eval2 sim: simulate binary data and evaluate power
v2 13may2020: add in LRT alongside Wald
v4 19jan2021: also add Pearson X2. artbin distant.
*/
local inputs pc or null
local outputs n b se p_x2 p_lr
if "`0'"=="?" {
	return local inputs `inputs'
	return local outputs `outputs'
	exit
}
syntax, pc(real) or(real) null(int) [seed(int -1)]

if `seed' != -1 set seed `seed'

local pe = `pc'*`or'/(1-`pc'+`pc'*`or')
* assert reldif(logit(`pe')-logit(`pc'),log(`or'))<1E-6

* run artcat
qui artbin, pr(`pc' `pe') power(.9) distant(1)
local n=r(n)

* null?
if `null' local pe `pc'

* simulate data
clear
set obs `n'
gen trt = mod(_n,2)

gen u = runiform()
qui gen y = runiform()<cond(trt,`pe',`pc')
assert !mi(y)

qui tab y trt, chi2 lrchi2
local p_x2 = r(p) // Pearson
local p_lr = r(p_lr) // LRT
cap logit y trt // for Wald
if !_rc {
	local b  = _b[trt]
	local se = _se[trt]
}
else if _rc==1 exit 1
else {
	local b  .
	local se .
}
foreach output of local outputs {
	return scalar `output' = ``output''
}
end
