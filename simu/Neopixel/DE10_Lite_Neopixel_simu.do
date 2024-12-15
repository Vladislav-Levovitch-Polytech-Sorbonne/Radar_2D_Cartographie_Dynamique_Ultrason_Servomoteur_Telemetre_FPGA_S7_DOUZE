# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_Neopixel.vhd
vcom -93 DE10_Lite_Neopixel_TEST_BENCH.vhdl

# Simulation
vsim DE10_Lite_Neopixel_TEST_BENCH_entity

# Visualisation
view signals
add wave *

run 300 us 
#run -all 
wave zoom full