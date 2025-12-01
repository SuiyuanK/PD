# Last updated on Feb 2016
# collect all dmp logs in dmp_logs.zip

rm -rf dmp_logs/
mkdir dmp_logs
mkdir dmp_logs/.dmp
echo "gathering file - *gsr"
cp *gsr dmp_logs/
echo "gathering file - *tcl"
cp *tcl dmp_logs/
echo "gathering file - *cmd"
cp *cmd dmp_logs/
echo "gathering file - runme"
cp runme* dmp_logs/
echo "gathering file - *cfg"
cp *cfg dmp_logs/
echo "gathering file - dmpConfig*"
cp dmpConfig* dmp_logs/
echo "gathering file - dmp.*job.log"
cp dmp.*job.log dmp_logs/
echo "gathering file - .run.setting*"
cp .run.setting* dmp_logs/
echo "gathering file - adsRpt*/redhawk.log"
cp --parent adsRpt*/redhawk.log dmp_logs/
echo "gathering file - adsRpt*/*.trace"
cp --parent adsRpt*/*.trace dmp_logs/
echo "gathering file - adsRpt*/nwopt_apache*"
cp --parent adsRpt*/nwopt_apache* dmp_logs/
echo "gathering file - adsPower*/.*log*"
cp --parent adsPower*/.*log* dmp_logs/
echo "gathering file - .apache*/.nx.log"
cp --parent .apache*/.nx.log dmp_logs/
echo "gathering file - .apache*/.debug.*"
cp --parent .apache*/.debug.* dmp_logs/
echo "gathering file - .apache*/.*statistic*"
cp --parent .apache*/.*statistic* dmp_logs/
echo "gathering file - .dmp/*.log*"
#cp --parent .dmp/*.log* dmp_logs/
#echo "gathering file - .dmp/*.err*"
#cp --parent .dmp/*.err* dmp_logs/
#echo "gathering file - .dmp/*launch*"
#cp --parent .dmp/*launch* dmp_logs/
#echo "gathering file - nwopt_apache*/nwopt*"
cp --parent nwopt_apache*/nwopt* dmp_logs/
echo "gathering file - nwopt_apache*/p_*/nwopt*"
cp --parent nwopt_apache.*.*/p_*/nwopt* dmp_logs/
echo "gathering file - *_nwopt_apache*/sp*/.log"
cp --parent *nwopt_apache*/sp*/.log dmp_logs/
echo "gathering file - *_nwopt_apache_*/sp_0/.debug.*"
cp --parent *nwopt_apache*/sp*/.debug.* dmp_logs/
echo "gathering file - *_nwopt_apache_*/sp*/nwopt.log"
cp --parent *nwopt_apache*/sp*/nwopt.log dmp_logs/
echo "gathering file - adsRpt*/power_summary.rpt"
cp --parent adsRpt*/power_summary.rpt dmp_logs/
echo "gathering dir - adsRpt/FDR"
cp -rf adsRpt/FDR/ dmp_logs/adsRpt
echo "gathering directory .dmp"
cp -rf .dmp/ dmp_logs/
echo "creating zip file dmp_logs.zip"
zip -r dmp_logs.zip dmp_logs/
