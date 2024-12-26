# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_UART_Avalon.vhd
vcom -93 DE10_Lite_UART_Avalon_TEST_BENCH.vhdl

# Simulation
vsim test_bench_DE10_Lite_UART_Avalon_entity

# Visualisation
view signals
add wave /test_bench_DE10_Lite_UART_Avalon_entity/dut/SIGNAL_Etape
add wave *
add wave /test_bench_DE10_Lite_UART_Avalon_entity/dut/signal_data_reg
add wave /test_bench_DE10_Lite_UART_Avalon_entity/dut/SIGNAL_Load_Save
add wave /test_bench_DE10_Lite_UART_Avalon_entity/dut/signal_etape_lecture
add wave /test_bench_DE10_Lite_UART_Avalon_entity/dut/SIGNAL_Data_Rx

run 1000 us 
#run -all 
wave zoom full