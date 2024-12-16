
module Neopixel (
	clk_clk,
	neopixel_alone_output_commande_neopixel,
	neopixel_alone_output_nb_led,
	reset_reset_n);	

	input		clk_clk;
	output		neopixel_alone_output_commande_neopixel;
	input	[7:0]	neopixel_alone_output_nb_led;
	input		reset_reset_n;
endmodule
