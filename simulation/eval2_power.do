// calculate powers by artbin and artcat and store in `name'
* vars: pc or n str20(method) power

local name eval2_power

* setup
cap postclose summ
postfile summ pc or n str20 method power using `name', replace

foreach pc in .2 .1 .4 {
	forvalues or=.2(.1).8 {
		local pe = `pc'*`or'/(1-`pc'+`pc'*`or')
		* assert reldif(logit(`pe')-logit(`pc'),log(`or'))<1E-6

		* run artcat
		artbin, pr(`pc' `pe') power(.9) distant(1)
		local n=r(n)
		local i 0
		artbin, pr(`pc' `pe') n(`n')
		post summ (`pc') (`or') (`n') ("`++i'. artbin local") (r(power))
		artbin, pr(`pc' `pe') n(`n') distant(1)
		post summ (`pc') (`or') (`n') ("`++i'. artbin distant") (r(power))

		local or = (`pe'/(1-`pe')) / (`pc'/(1-`pc'))
		artcat, pc(`pc') or(`or') n(`n') whitehead 
		post summ (`pc') (`or') (`n') ("`++i'. whitehead") (r(power_whitehead))
		artcat, pc(`pc') or(`or') n(`n') ologit 
		foreach type in NN NA AA {
			post summ (`pc') (`or') (`n') ("`++i'. ologit `type'") (r(power_ologit_`type'))
		}

	}
}

postclose summ

