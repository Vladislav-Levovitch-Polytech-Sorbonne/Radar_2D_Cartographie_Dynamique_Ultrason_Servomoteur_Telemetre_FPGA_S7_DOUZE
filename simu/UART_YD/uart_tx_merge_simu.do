vlib work

vcom -93 ../../src/FDIV_YD.vhd
vcom -93 ../../src/uart_tx_YD.vhd
vcom -93 ../../src/uart_tx_merge_YD.vhd
vcom -93 uart_tx_merge_tb.vhd

vsim uart_tx_merge_tb(Bench)

view signals
add wave *

run 700 us 
wave zoom full