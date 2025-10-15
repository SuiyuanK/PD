#! /bin/csh -f
setenv metal_stack   1P7M_1MTT_ALPA2
rm -rf   lib db lef milkyway ndm_mcmm verilog others
mkdir -p lib db lef milkyway ndm_mcmm verilog others
echo "move lib ..."
cd lib 
mv ../orig/*/*.lib .
cd ..

echo "move db ..."
cd db
mv ../orig/*/*.db .
cd ..

echo "move verilog ..."
cd verilog
mv ../orig/*/*.v .
cd ..

echo "move lef ..."
cd lef
mv ../orig/*/*.lef .
mv ../orig/*/*.clf .
cd ..

echo "process others ..."
echo "metal stack is $metal_stack ..."
cd milkyway
mkdir -p $metal_stack 
cd ..

cd ndm_mcmm
mkdir -p $metal_stack
cd ..

cd others
mv ../orig/* .
cd ..

