# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_Servomoteur.vhd
vcom -93 DE10_Lite_Servomoteur_TEST_BENCH.vhdl

# Simulation
vsim test_bench_DE10_Lite_Servomoteur_entity

# Visualisation
view signals
add wave *

run 350 ms 
#run -all 
wave zoom full