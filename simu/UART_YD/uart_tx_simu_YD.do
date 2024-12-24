vlib work

vcom -93 ../../src/FDIV_YD.vhd
vcom -93 ../../src/uart_tx_YD.vhd
vcom -93 uart_tx_tb_YD.vhd

vsim uart_tx_tb_YD(Bench)

view signals
add wave *


run -all
wave zoom full