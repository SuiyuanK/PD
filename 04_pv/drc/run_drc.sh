calibre -hier -drc -turbo 4 -hyper -64 ./drc.cmd 
grep -v "NOT EXECUTED" ./drc.rpt | grep -v "TOTAL Result Count = 0" >! ./drc.rpt.sum
grep RULECHECK ./drc.rpt >! ./drc.CHECKRULE.sum.sort
