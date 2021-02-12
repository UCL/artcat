/*
eval2_n
Basic calc for eval2 and table 3
*/

local name eval2_n
local power 0.9
cap postclose summ
postfile summ pc pe or str20 method n using `name'_postfile, replace
foreach pc in 0.02 0.1 0.2 0.4 {
	forvalues or=.2(.1).8 {
		local pe = `pc'*`or' / (1-`pc'+`pc'*`or')
		local i 0

		power twoproportions `pc' `pe', power(`power')
		post summ (`pc') (`pe') (`or') ("`++i'. power") (r(N))

		artbin, pr(`pc' `pe') power(`power')
		post summ (`pc') (`pe') (`or') ("`++i'. artbin local") (r(n))

		artbin, pr(`pc' `pe') power(`power') distant(1)
		post summ (`pc') (`pe') (`or') ("`++i'. artbin distant") (r(n))

		artcat, pc(`pc') or(`or') power(`power') whitehead
		post summ (`pc') (`pe') (`or') ("`++i'. whitehead") (r(n_whitehead))

		artcat, pc(`pc') or(`or') power(`power') ologit
		foreach type in NN NA AA {
			post summ (`pc') (`pe') (`or') ("`++i'. ologit `type'") (r(n_ologit_`type'))
		}

	}
}
postclose summ
use `name'_postfile, clear
assert !mi(n)
l, sepby(pc pe or)

replace method=strtoname(method)
reshape wide n, i(pc pe or) j(method) string
foreach nvar of varlist n* {
	local newvar=substr("`nvar'",6,.)
	rename `nvar' `newvar'
}
l, sepby(pc) abb(15)

// OUTPUT RESULTS FOR TABLE 3: SAMPLE SIZES FOR PC=0.2 OR 0.02

gsort -pc or
format or %3.1f
format pc %4.2f
local vars pc or power artbin_local artbin_distant gap whitehead ologit_NN ologit_NA ologit_AA
gen gap = .
listtex `vars' using `name'_out1.tex if pc==float(0.2), rstyle(tabular) replace type
listtex `vars' using `name'_out2.tex if pc==float(0.02), rstyle(tabular) replace type
