/* 
artactor_test.do
simple test script for artcator.ado
IW 2dec2024
*/
prog drop _all
set linesize 98
cd c:\ian\git\artcat\artcator
log using artactor_test, replace nomsg text

artcator, pc(.018 .036 .156 .141 .390 .259) n(322) unfav 
artcator, pc(.018 .036 .156 .141 .390 .259) n(322) fav 
artcator, pc(.018 .036 .156 .141 .390 .259) n(322) margin(1.2) unfav 
artcator, pc(.018 .036 .156 .141 .390 .259) n(322) margin(1.2) fav 

log close
