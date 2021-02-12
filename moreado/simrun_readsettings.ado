/* 
simrun_readsettings: utility to read simulation settings from file
*! v0.1.1 IW 22jan2021
19jan2021: added delete and folder options
*/

prog def simrun_readsettings
syntax, SETtings(name) PROGram(name) [FOLDer(string) DELete]
`program' ?
local inputs = r(inputs)
local outputs = r(outputs)

use `settings', clear
cap isid `inputs'
if _rc {
	di as error "Error in data `settings': variables `inputs' do not uniquely identify the observations"
	exit _rc
}
qui gen donereps=.
qui gen str20 postfilename = "`program'"
if !mi("`folder'") qui replace postfilename = "`folder'/" + postfilename
qui gen str20 args = ""
foreach input of local inputs {
	local format : format `input'
	qui replace postfilename = postfilename + "_" + "`input'" + string(`input',"`format'")
	qui replace args = args + " `input'(" + string(`input',"`format'") + ")"
}
qui replace postfilename = postfilename + ".dta"

forvalues i=1/`=_N' {
	local postfilename = postfilename[`i']
	cap confirm file `postfilename'
	if _rc qui replace donereps=. in `i'
	else {
		if mi("`delete'") {
			qui desc using `postfilename'
			qui replace donereps=r(N) in `i'
		}
		else {
			erase `postfilename'
			di "`postfilename' deleted"
			qui replace donereps=. in `i'
		}
	}
}

end
