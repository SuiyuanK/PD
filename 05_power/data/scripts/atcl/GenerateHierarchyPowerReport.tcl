
proc GenerateHierarchyPowerReport {} {
	set design [ query top -name ]
	exec  cat ./adsRpt/$design.power.rpt | awk {
	BEGIN{
	print "#<instance_name> <cell_name> <Freq> <toggle_rate> <leakage_power> <switching_power> <internal_power + clk_pin_power> <tota l_power > <X in um> <Y in um> <VDD domain> <[source for leakage]_[source for int pwr]> <1: non-multi-rail power domain; 2: multi- rail VDD domain; 0: multi-rail VSS domain> <leakage current> <total current> <library> <cell P/G pin>"
	}

	{

		if ($1 !~/#/)
		{
			$1 = "Top_level/"$1
			b =  split($1,a,"/")
			for (i=1;i<=b;i++)
			{
				name = name"/"a[i]
				instance_name[name,$11] = name
				leakage_power[name,$11] = leakage_power[name,$11] + $5
				switching_power[name,$11] = switching_power[name,$11] + $6
				internal_power_clk_pin_power[name,$11] = internal_power_clk_pin_power[name,$11] + $7
				total_power[name,$11] = total_power[name,$11] + $8
				VDD_domain[name,$11] = $11
				leakage_current[name,$11] = leakage_current[name,$11] + $14
				total_current[name,$11] = total_current[name,$11] + $15
				if (i == b)
				{
					cell_name[name,$11] = $2
					Freq[name,$11] = $3
					toggle_rate[name,$11] = $4
					X_in_um[name,$11] = $9
					Y_in_um[name,$11] = $10
					source_for_leakage_source_for_int_pwr[name,$11] = $12
					rail[name,$11] = $13
					library[name,$11] = $16
					cell_PG_pin[name,$11] = $17
				}
				else
				{
					cell_name[name,$11] = "NA"
					Freq[name,$11] = "NA"
					toggle_rate[name,$11] = "NA"
					X_in_um[name,$11] = "NA"
					Y_in_um[name,$11] = "NA"
					source_for_leakage_source_for_int_pwr[name,$11] = "NA"
					rail[name,$11] = "NA"
					library[name,$11] = "NA"
					cell_PG_pin[name,$11] = "NA"
				}
				line[name,$11] = instance_name[name,$11]" "cell_name[name,$11]" "Freq[name,$11] " "toggle_rate[name,$11]" "leakage_power[name,$11]" "switching_power[name,$11]" "internal_power_clk_pin_power[name,$11]" "total_power[name,$11]" "X_in_um[name,$11]" "Y_in_um[name,$11]" "VDD_domain[name,$11]" "source_for_leakage_source_for_int_pwr[name,$11]" "rail[name,$11]" "leakage_current[name,$11]" "total_current[name,$11]" "library[name,$11]" "cell_PG_pin[name,$11]
			}       
			name = ""
		}
	}
	END{
		for ( x in line ) 
		{
			print line[x]
		}
	}

} > Hierarchy_Power_Report
}

