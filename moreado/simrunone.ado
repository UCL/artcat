/* 
simrunone: Find a simulation to run, and run it 
*! v0.1.1 IW 22jan2021
	handle user break
		requires user program to handle it too (see mysim.ado for example)
19jan2021: add delete option
*/

prog def simrunone, sclass
syntax, SETtings(name) PROGram(name) [FOLDer(passthru) DELete]

`program' ?
local inputs = r(inputs)
local outputs = r(outputs)

simrun_readsettings, settings(`settings') program(`program') `folder' `delete'

qui drop if max(0,donereps)>=reps

if _N==0 {
	sreturn local stop stop
	exit
}
tempvar origorder
gen `origorder' = _n
gen fracdone=max(0,donereps)/reps
sort fracdone `origorder'
drop `origorder'
local i 1 /* just do the first - most needy - setting */
local postfile = postfilename[`i']
local args = args[`i']
local reps = reps[`i']
if !mi(donereps[`i']) {
	local replace replace
	local create replace
}
else local create create
cap postclose simrun
postfile simrun `inputs' `outputs' using `postfile', `replace'
cap confirm var seed
if !_rc {
	local seed =seed[`i']
	di as txt _new "Setting seed to `seed'" _c
	set seed `seed'
}
di as txt _new "Running `reps' replicates to `create' file `postfile':"
foreach parm of local inputs {
	local parmvalue = `parm'[`i']
	local postin `postin' (`parmvalue')
}
dotter reset
forvalues rep=1/`reps' {
	dotter `rep' `reps'
	cap `program', `args' 
	if _rc exit 1 // responds to user break
	local postout
	foreach parm of local outputs {
		local parmvalue = r(`parm')
		local postout `postout' (`parmvalue')
	}
	post simrun `postin' `postout'
}
postclose simrun
di as txt "Simulation complete, file `create'd."

* check results
use `postfile', clear
local maxnmiss 0
local n=_N
foreach output of local outputs {
	qui count if mi(`output')
	if r(N)>`maxnmiss' {
		local maxnmiss = r(N)
		local badvar `output'
	}
}
if `maxnmiss'==`n' {
	di as error "Variable `badvar' is wholly missing"
	exit 498
}
else if `maxnmiss'>0 {
	di as txt "Variable `badvar' is missing in `maxnmiss'/`n'"
}

* finish
sreturn local stop continue

end


*! version 0.3   13nov2006:   enable -dotter reset-
prog def dotter
version 8
args i imax
if "`i'"=="reset" {
   global DOTTER
   exit
}
local header 0%.........20%.........40%.........60%.........80%.........100%
if `i'==1 & "$DOTTER"!="0" {
    di as text "`header'"
    global DOTTER 0
}
cap confirm integer number $DOTTER
if _rc==0 {
   local newdots = int((`i'/`imax') * length("`header'")) - $DOTTER
   if `newdots'>0 {
       di as result _dup(`newdots') "." _c
       global DOTTER=$DOTTER+`newdots'
   }
   if `i'>=`imax' {
       di
       global DOTTER
   }
}
end
