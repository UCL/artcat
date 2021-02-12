program define dolog
/*
 Execute a do-file `1', outputting to `1'.log,
 with the option of passing parameters.
 Adapted from an example called dofile, given in net course 151,
 and installed at the KCL site by Jonathan Sterne.
*! Author: Roger Newson
*! Date: 04 August 2009
 
modified by Ian White, 17sep2010: doesn't create log file if do file doesn't exist
modified by Ian White,  2dec2010: handles file name with spaces
modified by Ian White,  9mar2012: version 12
modified by Ian White, 19sep2016: no version number
*! IW 2dec2020
	respect logtype
*/
if mi("`1'") {
	di as error "File not specified"
	exit 498
}
if substr("`1'",length("`1'")-2,3)==".do" local filename = substr("`1'",1,length("`1'")-3)
else local filename "`1'"
confirm file `"`filename'.do"'
local log = cond(c(logtype)=="text","log","smcl")
capture log close
log using `"`filename'.`log'"', replace
capture noisily do `0'
log close
end
