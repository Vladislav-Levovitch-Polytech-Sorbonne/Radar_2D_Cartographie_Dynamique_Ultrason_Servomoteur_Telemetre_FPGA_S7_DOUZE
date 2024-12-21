	Computer_System u0 (
		.arduino_gpio_export                      (<connected-to-arduino_gpio_export>),                      //              arduino_gpio.export
		.arduino_reset_n_export                   (<connected-to-arduino_reset_n_export>),                   //           arduino_reset_n.export
		.avalon_neopixel_output_commande_neopixel (<connected-to-avalon_neopixel_output_commande_neopixel>), //    avalon_neopixel_output.commande_neopixel
		.avalon_servomoteur_output_commande       (<connected-to-avalon_servomoteur_output_commande>),       // avalon_servomoteur_output.commande
		.avalon_telemetre_output_trig             (<connected-to-avalon_telemetre_output_trig>),             //   avalon_telemetre_output.trig
		.avalon_telemetre_output_echo             (<connected-to-avalon_telemetre_output_echo>),             //                          .echo
		.avalon_telemetre_output_dist_cm          (<connected-to-avalon_telemetre_output_dist_cm>),          //                          .dist_cm
		.hex3_hex0_export                         (<connected-to-hex3_hex0_export>),                         //                 hex3_hex0.export
		.hex5_hex4_export                         (<connected-to-hex5_hex4_export>),                         //                 hex5_hex4.export
		.leds_export                              (<connected-to-leds_export>),                              //                      leds.export
		.pushbuttons_export                       (<connected-to-pushbuttons_export>),                       //               pushbuttons.export
		.sdram_addr                               (<connected-to-sdram_addr>),                               //                     sdram.addr
		.sdram_ba                                 (<connected-to-sdram_ba>),                                 //                          .ba
		.sdram_cas_n                              (<connected-to-sdram_cas_n>),                              //                          .cas_n
		.sdram_cke                                (<connected-to-sdram_cke>),                                //                          .cke
		.sdram_cs_n                               (<connected-to-sdram_cs_n>),                               //                          .cs_n
		.sdram_dq                                 (<connected-to-sdram_dq>),                                 //                          .dq
		.sdram_dqm                                (<connected-to-sdram_dqm>),                                //                          .dqm
		.sdram_ras_n                              (<connected-to-sdram_ras_n>),                              //                          .ras_n
		.sdram_we_n                               (<connected-to-sdram_we_n>),                               //                          .we_n
		.sdram_clk_clk                            (<connected-to-sdram_clk_clk>),                            //                 sdram_clk.clk
		.slider_switches_export                   (<connected-to-slider_switches_export>),                   //           slider_switches.export
		.system_pll_ref_clk_clk                   (<connected-to-system_pll_ref_clk_clk>),                   //        system_pll_ref_clk.clk
		.system_pll_ref_reset_reset               (<connected-to-system_pll_ref_reset_reset>),               //      system_pll_ref_reset.reset
		.vga_CLK                                  (<connected-to-vga_CLK>),                                  //                       vga.CLK
		.vga_HS                                   (<connected-to-vga_HS>),                                   //                          .HS
		.vga_VS                                   (<connected-to-vga_VS>),                                   //                          .VS
		.vga_BLANK                                (<connected-to-vga_BLANK>),                                //                          .BLANK
		.vga_SYNC                                 (<connected-to-vga_SYNC>),                                 //                          .SYNC
		.vga_R                                    (<connected-to-vga_R>),                                    //                          .R
		.vga_G                                    (<connected-to-vga_G>),                                    //                          .G
		.vga_B                                    (<connected-to-vga_B>),                                    //                          .B
		.video_pll_ref_clk_clk                    (<connected-to-video_pll_ref_clk_clk>),                    //         video_pll_ref_clk.clk
		.video_pll_ref_reset_reset                (<connected-to-video_pll_ref_reset_reset>)                 //       video_pll_ref_reset.reset
	);

