/* 
simcombine: read and combine all simulation results
*! v0.1.1 IW 22jan2021
11jun2020: added genid option
*/

prog def simcombine
syntax, SETtings(name) PROGram(name) [FOLDer(passthru) GENid(name)]

`program' ?
local inputs = r(inputs)
local outputs = r(outputs)

di as txt "Files to be read:"
simrun_readsettings, settings(`settings') program(`program') `folder'
l
local n = _N
di as txt "Reading `n' files" _c
forvalues i=1/`n' {
	local postfile = postfilename[`i']
	cap append using `postfile'
	if _rc di as error "File `postfile' not found"
	di "." _c
}
qui drop in 1/`n'
keep `inputs' `outputs'
sort `inputs', stable
if !mi("`genid'") by `inputs': gen `genid' = _n
di "done"
end
