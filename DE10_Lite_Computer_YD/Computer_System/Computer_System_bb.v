
module Computer_System (
	arduino_gpio_export,
	arduino_reset_n_export,
	avalon_neopixel_output_commande_neopixel,
	avalon_servomoteur_output_commande,
	avalon_telemetre_output_trig,
	avalon_telemetre_output_echo,
	avalon_telemetre_output_dist_cm,
	avalon_uart_output_uart_rx,
	avalon_uart_output_uart_tx,
	hex3_hex0_export,
	hex5_hex4_export,
	leds_export,
	pushbuttons_export,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	sdram_clk_clk,
	slider_switches_export,
	system_pll_ref_clk_clk,
	system_pll_ref_reset_reset,
	vga_CLK,
	vga_HS,
	vga_VS,
	vga_BLANK,
	vga_SYNC,
	vga_R,
	vga_G,
	vga_B,
	video_pll_ref_clk_clk,
	video_pll_ref_reset_reset);	

	inout	[15:0]	arduino_gpio_export;
	output		arduino_reset_n_export;
	output		avalon_neopixel_output_commande_neopixel;
	output		avalon_servomoteur_output_commande;
	output		avalon_telemetre_output_trig;
	input		avalon_telemetre_output_echo;
	output	[9:0]	avalon_telemetre_output_dist_cm;
	input		avalon_uart_output_uart_rx;
	output		avalon_uart_output_uart_tx;
	output	[31:0]	hex3_hex0_export;
	output	[15:0]	hex5_hex4_export;
	output	[9:0]	leds_export;
	input	[1:0]	pushbuttons_export;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		sdram_clk_clk;
	input	[9:0]	slider_switches_export;
	input		system_pll_ref_clk_clk;
	input		system_pll_ref_reset_reset;
	output		vga_CLK;
	output		vga_HS;
	output		vga_VS;
	output		vga_BLANK;
	output		vga_SYNC;
	output	[3:0]	vga_R;
	output	[3:0]	vga_G;
	output	[3:0]	vga_B;
	input		video_pll_ref_clk_clk;
	input		video_pll_ref_reset_reset;
endmodule
