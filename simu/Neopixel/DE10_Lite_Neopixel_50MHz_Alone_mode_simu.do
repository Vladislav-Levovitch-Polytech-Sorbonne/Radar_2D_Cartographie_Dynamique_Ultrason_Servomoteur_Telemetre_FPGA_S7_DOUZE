# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_Neopixel_50MHz_Alone.vhd
vcom -93 DE10_Lite_Neopixel_50MHz_Alone_TEST_BENCH.vhdl

# Simulation
vsim DE10_Lite_Neopixel_50MHz_Alone_TEST_BENCH_entity

# Visualisation
view signals
add wave *

run 40 ms 
#run -all 
wave zoom full