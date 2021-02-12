/* 
simrun: main program
	List the simulations requested, and run all that need running .
*! v0.1.1 IW 22jan2021
	changed variable name _donereps to donereps
	added some documentation
Structure of package:
	User-facing programs:
		simrun.ado     			- do simulations
		simcombine.ado 			- load all simulation results
	Utilities:
		simrun_readsettings.ado - called by all
		simrunone.ado 			- called by simrun
	Examples:
		simrun.do - define DG parameters and run simple simulation using mysim.ado
		mysim.ado - define DG model, estimands and analyses
To do
	If seed is stored in settings file, should it be included in results file name?
	Use partial results
		easy without reproducibility
		otherwise requires storage of seed after each rep
*/

prog def simrun
syntax, SETtings(name) PROGram(name) [FOLDer(passthru) DELete]

`program' ?
local inputs = r(inputs)
local outputs = r(outputs)

simrun_readsettings, settings(`settings') program(`program') `folder' `delete'
l `inputs' reps donereps postfilename
cap assert max(0,donereps)>=reps 
if !_rc {
	di as txt "Nothing to do"
	exit
}
while 1 {
	simrunone, settings(`settings') program(`program') `folder' 
	if s(stop)=="stop" continue, break
}
end	
	
	
