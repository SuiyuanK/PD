setup analysis_mode signalEM
import gsr ./image_icb.gsr
setup design
perform pwrcalc
perform extraction -signal 
perform analysis -signalEM  
perform emcheck  
explore design








