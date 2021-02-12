/*
Master file for evaluations for artcat paper
IRW 8feb2021
Performs all calculations and outputs results as latex files
Requires:
	artcat
	artbin
	simrun (my suite, incl dotter)
	dolog
Note: use of simrun means that if you press break while running the simulation, 
	later you can just run this file again
Note: #reps is set by argument in eval1.do and eval2_simrun.do 
	is 100000 for paper
	this takes >24 hours
Note: large simulation results files are stored in subfolder resultfiles 
	which is not included in the repo
*/


// SETUP
prog drop _all
adopath ++ ../moreado
adopath ++ ../package


// EVALUATION 1

// Run all and write Tables 1 and 2.
dolog eval1 100000


// EVALUATION 2

// Sample size calculations. Use to write Table 3.
dolog eval2_n

// Powers by simulation (calls eval2mysim.ado)
dolog eval2_simrun 100000

// Powers by calculation
dolog eval2_power

// Combine powers and write Table 4
dolog eval2_allpowers
