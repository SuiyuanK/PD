cd hvt
source apldi.cmd &
cd ../lvt
source apldi.cmd &
cd ../rvt
source apldi.cmd &
wait
cd ../
echo "APLDI for all corners completed."
mkdir -p ./outputs
cp -v ./hvt/*.cdev ./outputs/
cp -v ./hvt/*.pwcdev ./outputs/
cp -v ./hvt/*.current ./outputs/
cp -v ./lvt/*.cdev ./outputs/
cp -v ./lvt/*.pwcdev ./outputs/
cp -v ./lvt/*.current ./outputs/
cp -v ./rvt/*.cdev ./outputs/
cp -v ./rvt/*.pwcdev ./outputs/
cp -v ./rvt/*.current ./outputs/
echo "All output files have been copied to the outputs directory."