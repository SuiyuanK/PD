calibre -hier -drc -turbo 4 -hyper -64 ./drc.cmd | tee drc.log
grep -v "NOT EXECUTED" ./drc.rpt | grep -v "TOTAL Result Count = 0" >! ./drc.rpt.sum 
grep RULECHECK ./drc.rpt.sum >! ./drc.CHECKRULE.sum.sort

calibre -hier -drc -turbo 4 -hyper -64 ./ant.cmd | tee ant.log
grep -v "NOT EXECUTED" ./ant.rpt | grep -v "TOTAL Result Count = 0" >! ./ant.rpt.sum 
grep RULECHECK ./ant.rpt.sum >! ./ant.CHECKRULE.sum.sort
