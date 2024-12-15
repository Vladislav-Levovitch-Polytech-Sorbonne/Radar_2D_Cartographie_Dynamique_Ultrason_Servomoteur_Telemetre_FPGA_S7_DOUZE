library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_TEST_BENCH_entity is
end DE10_Lite_Neopixel_TEST_BENCH_entity;

architecture test_bench_DE10_Lite_Neopixel_architecture of DE10_Lite_Neopixel_TEST_BENCH_entity is

    -- Signal
    signal SIGNAL_Test_Bench_Neopixel_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_Neopixel_reset_n    : std_logic := '1';
    -- signal SIGNAL_Test_Bench_Neopixel_position   : std_logic_vector(9 downto 0) := ( others => '0' );

    signal SIGNAL_Test_Bench_Neopixel_commande   : std_logic;

    -- Component Declaration
    component DE10_Lite_Neopixel
        Port (
            clk         : In    std_logic;
            reset_n     : In    std_logic;
            -- position    : In    std_logic_vector(9 downto 0);
            commande    : Out   std_logic
        );
    end component;

begin

    -- Instanciation
    DUT : entity work.DE10_Lite_Neopixel
        Port map (
            clk         => SIGNAL_Test_Bench_Neopixel_clk,
            reset_n     => SIGNAL_Test_Bench_Neopixel_reset_n,
            -- position    => SIGNAL_Test_Bench_Neopixel_position,
            commande    => SIGNAL_Test_Bench_Neopixel_commande
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_Neopixel_clk <= '0';
        wait for 5 ns;
        SIGNAL_Test_Bench_Neopixel_clk <= '1';
        wait for 5 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        SIGNAL_Test_Bench_Neopixel_reset_n <= '0';
        wait for 500 ns;
        SIGNAL_Test_Bench_Neopixel_reset_n <= '1';
        wait;
    end process;
end test_bench_DE10_Lite_Neopixel_architecture;
