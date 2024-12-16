	component Neopixel is
		port (
			clk_clk                                 : in  std_logic                    := 'X';             -- clk
			neopixel_alone_output_commande_neopixel : out std_logic;                                       -- commande_neopixel
			neopixel_alone_output_nb_led            : in  std_logic_vector(7 downto 0) := (others => 'X'); -- nb_led
			reset_reset_n                           : in  std_logic                    := 'X'              -- reset_n
		);
	end component Neopixel;

	u0 : component Neopixel
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                   clk.clk
			neopixel_alone_output_commande_neopixel => CONNECTED_TO_neopixel_alone_output_commande_neopixel, -- neopixel_alone_output.commande_neopixel
			neopixel_alone_output_nb_led            => CONNECTED_TO_neopixel_alone_output_nb_led,            --                      .nb_led
			reset_reset_n                           => CONNECTED_TO_reset_reset_n                            --                 reset.reset_n
		);

