# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_Telemetre_us_to_cm.vhd
vcom -93 DE10-Lite_Telemetre_us_to_cm_TEST_BENCH.vhdl

# Simulation
vsim test_bench_DE10_Lite_Telemetre_us_to_cm_entity

# Visualisation
view signals
add wave *

run 350 ms 
#run -all 
wave zoom full