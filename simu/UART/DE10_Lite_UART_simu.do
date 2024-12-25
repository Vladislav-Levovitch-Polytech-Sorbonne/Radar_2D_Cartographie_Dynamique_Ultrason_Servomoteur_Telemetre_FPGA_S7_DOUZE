# Creation de la lirairie de travail
vlib work

# Compilation
vcom -93 ../../src/DE10_Lite_UART.vhd
vcom -93 DE10_Lite_UART_TEST_BENCH.vhdl

# Simulation
vsim test_bench_DE10_Lite_UART_entity

# Visualisation
view signals
add wave /test_bench_DE10_Lite_UART_entity/dut/SIGNAL_Etape
add wave *
add wave /test_bench_de10_lite_uart_entity/dut/signal_data_reg
add wave /test_bench_de10_lite_uart_entity/dut/signal_etape_lecture
add wave /test_bench_de10_lite_uart_entity/dut/SIGNAL_Data_Rx

run 900 us 
#run -all 
wave zoom full