library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_50MHz_Alone_TEST_BENCH_entity is
end DE10_Lite_Neopixel_50MHz_Alone_TEST_BENCH_entity;

architecture test_bench_DE10_Lite_Neopixel_50MHz_Alone_architecture of DE10_Lite_Neopixel_50MHz_Alone_TEST_BENCH_entity is

    -- Signal
    signal SIGNAL_Test_Bench_Neopixel_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_Neopixel_reset_n    : std_logic := '1';
    -- signal SIGNAL_Test_Bench_Neopixel_nb_led     : std_logic_vector(7 downto 0) := ( others => '0' );

    signal SIGNAL_Test_Bench_Neopixel_commande   : std_logic;

    -- Component Declaration
    component DE10_Lite_Neopixel
        Port (
            clk         : In    std_logic;
            reset_n     : In    std_logic;
            -- nb_led      : In    std_logic_vector(7 downto 0);

            commande    : Out   std_logic
        );
    end component;

begin

    -- Instanciation
    DUT : entity work.DE10_Lite_Neopixel_50MHz_Alone
        Port map (
            clk         => SIGNAL_Test_Bench_Neopixel_clk,
            reset_n     => SIGNAL_Test_Bench_Neopixel_reset_n,
            -- nb_led      => SIGNAL_Test_Bench_Neopixel_nb_led,

            commande    => SIGNAL_Test_Bench_Neopixel_commande
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_Neopixel_clk <= '0';
        wait for 10 ns;
        SIGNAL_Test_Bench_Neopixel_clk <= '1';
        wait for 10 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        -- SIGNAL_Test_Bench_Neopixel_nb_led <= "00000011";
        SIGNAL_Test_Bench_Neopixel_reset_n <= '0';
        wait for 500 ns;
        SIGNAL_Test_Bench_Neopixel_reset_n <= '1';

        wait for 2 ms;
        -- SIGNAL_Test_Bench_Neopixel_nb_led <= "00000111";
        wait;
    end process;
end test_bench_DE10_Lite_Neopixel_50MHz_Alone_architecture;
