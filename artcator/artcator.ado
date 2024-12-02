/*
*! v0.1 IW 2dec2024
Find OR from n and power
Can't use Whitehead or other formulae as n depends on OR in a complex way
Instead, iterate 
Examples of syntax:
	artcator, pc(.018 .036 .156 .141 .390 .259) n(322) unfav
	artcator, pc(.018 .036 .156 .141 .390 .259) n(322) fav
(note these are different!)
*/

prog def artcator
syntax, n(integer) [power(real 0.8) tol(int 6) start(real 0.1) noRound maxiter(int 10) FAVourable UNFavourable noLog margin(real 1) *]
* noround is ignored
local logmargin = log(`margin')
if !mi("`favourable'") local logor = `logmargin' + abs(`start')
else if !mi("`unfavourable'") local logor = `logmargin' - abs(`start')
else {
	di "artcator: please specify favourable or unfavourable"
	exit 198
}
if !mi("`favourable'") & !mi("`unfavourable'") {
	di "artcator: please don't specify both favourable and unfavourable"
	exit 198
}
if !mi("`log'") local qui qui
local options `options' `favourable' `unfavourable' margin(`margin')
// END OF PARSING

di as text "Seeking OR to give power " as result `power' as text " with sample size " as result `n'

// PERFORM ITERATION
local converge 1
local stop 0
local i 0
while !`stop' {
	local ++i
	qui artcat, or(exp(`logor')) power(`power') `options' noround
	local logornew = `logmargin' + (`logor'-`logmargin')*sqrt(r(n)/`n')
	local stop = abs(`logornew'-`logor')< 1E-`tol' 
	`qui' di as text "Iteration " as result `i' as text ": OR = " as result exp(`logornew') _c
	if `stop' `qui' di as text ": stopping"
	else if `i'>=`maxiter' {
		`qui' di as text ": failed to converge, but still hoping..."
		local converge 0
		local stop 1
	}
	else `qui' di
	local logor `logornew'
}

// CHECK AND OUTPUT
artcat, or(exp(`logor')) n(`n') `options'
cap assert abs(`power' - r(power)) < 1E-3
if _rc {
	di "Something went wrong: didn't achieve target power"
	exit 498
}
else if !`converge' di as text "Power is sufficiently accurate, despite failure to converge"
end

