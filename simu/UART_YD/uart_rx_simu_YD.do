vlib work

vcom -93 ../../src/fdiv_YD.vhd
vcom -93 ../../src/uart_tx_YD.vhd
vcom -93 ../../src/uart_rx_YD.vhd
vcom -93 uart_rx_tb_YD.vhd

vsim uart_rx_tb_YD(Bench)

view signals
add wave *


run -all
wave zoom full