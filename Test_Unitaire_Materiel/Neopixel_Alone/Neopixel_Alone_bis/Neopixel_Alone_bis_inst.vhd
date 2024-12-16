	component Neopixel_Alone_bis is
		port (
			clk_clk                                 : in  std_logic := 'X'; -- clk
			neopixel_alone_output_commande_neopixel : out std_logic;        -- commande_neopixel
			reset_reset_n                           : in  std_logic := 'X'  -- reset_n
		);
	end component Neopixel_Alone_bis;

	u0 : component Neopixel_Alone_bis
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                   clk.clk
			neopixel_alone_output_commande_neopixel => CONNECTED_TO_neopixel_alone_output_commande_neopixel, -- neopixel_alone_output.commande_neopixel
			reset_reset_n                           => CONNECTED_TO_reset_reset_n                            --                 reset.reset_n
		);

