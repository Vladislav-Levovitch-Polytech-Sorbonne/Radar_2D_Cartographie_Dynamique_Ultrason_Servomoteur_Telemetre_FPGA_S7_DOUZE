library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_bench_DE10_Lite_Servomoteur_entity is
end test_bench_DE10_Lite_Servomoteur_entity;

architecture test_bench_DE10_Lite_Servomoteur_architecture of test_bench_DE10_Lite_Servomoteur_entity is

    -- Signal
    signal SIGNAL_Test_Bench_Servomoteur_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_Servomoteur_reset_n    : std_logic := '1';
    signal SIGNAL_Test_Bench_Servomoteur_position   : std_logic_vector(9 downto 0) := ( others => '0' );

    signal SIGNAL_Test_Bench_Servomoteur_commande   : std_logic;

    -- Component Declaration
    component DE10_Lite_Servomoteur
        Port (
            clk         : In    std_logic;
            reset_n     : In    std_logic;
            position    : In    std_logic_vector(9 downto 0);
            commande    : Out   std_logic
        );
    end component;

begin

    -- Instanciation
    DUT : entity work.DE10_Lite_Servomoteur
        Port map (
            clk         => SIGNAL_Test_Bench_Servomoteur_clk,
            reset_n     => SIGNAL_Test_Bench_Servomoteur_reset_n,
            position    => SIGNAL_Test_Bench_Servomoteur_position,
            commande    => SIGNAL_Test_Bench_Servomoteur_commande
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_Servomoteur_clk <= '0';
        wait for 10 ns;
        SIGNAL_Test_Bench_Servomoteur_clk <= '1';
        wait for 10 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        SIGNAL_Test_Bench_Servomoteur_reset_n <= '0';
        wait for 200 ns;
        SIGNAL_Test_Bench_Servomoteur_reset_n <= '1';

        SIGNAL_Test_Bench_Servomoteur_position <= "1110000100";
        wait for 10 ms;

        SIGNAL_Test_Bench_Servomoteur_position <= "0111000010"; -- >> 1 div 900 par 2 = 450 * 0.1° = 45°
        wait for 10 ms;

        SIGNAL_Test_Bench_Servomoteur_position <= ( others => '0' );
        wait for 10 ms;
        --assert SIGNAL_Test_Bench_telemetre_Dist_cm = "0000000011" report "Test 3cm" severity error;

        wait for 30ms;
        wait;
    end process;
end test_bench_DE10_Lite_Servomoteur_architecture;
