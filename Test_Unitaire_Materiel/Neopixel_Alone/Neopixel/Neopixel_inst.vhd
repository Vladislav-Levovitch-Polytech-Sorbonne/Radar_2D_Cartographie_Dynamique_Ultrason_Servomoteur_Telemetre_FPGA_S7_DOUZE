	component Neopixel is
		port (
			clk_clk                                 : in  std_logic := 'X'; -- clk
			reset_reset_n                           : in  std_logic := 'X'; -- reset_n
			neopixel_alone_output_commande_neopixel : out std_logic         -- commande_neopixel
		);
	end component Neopixel;

	u0 : component Neopixel
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                   clk.clk
			reset_reset_n                           => CONNECTED_TO_reset_reset_n,                           --                 reset.reset_n
			neopixel_alone_output_commande_neopixel => CONNECTED_TO_neopixel_alone_output_commande_neopixel  -- neopixel_alone_output.commande_neopixel
		);

