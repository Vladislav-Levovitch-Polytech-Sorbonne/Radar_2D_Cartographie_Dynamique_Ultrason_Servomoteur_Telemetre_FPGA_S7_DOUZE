# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_UART_tx_YD.vhd
vcom -93 DE10_Lite_UART_tx_TEST_BENCH.vhdl

# Simulation
vsim test_bench_DE10_Lite_UART_tx_YD_entity

# Visualisation
view signals
add wave *

run 800 us 
#run -all 
wave zoom full