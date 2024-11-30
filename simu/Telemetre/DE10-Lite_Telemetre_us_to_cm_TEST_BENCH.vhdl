library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_bench_DE10_Lite_Telemetre_us_to_cm_entity is
end test_bench_DE10_Lite_Telemetre_us_to_cm_entity;

architecture test_bench_DE10_Lite_Telemetre_us_to_cm_architecture of test_bench_DE10_Lite_Telemetre_us_to_cm_entity is

    -- Signal
    signal SIGNAL_Test_Bench_telemetre_clk         : std_logic := '0';
    signal SIGNAL_Test_Bench_telemetre_Rst_n       : std_logic := '1';
    signal SIGNAL_Test_Bench_telemetre_echo        : std_logic := '0';
    signal SIGNAL_Test_Bench_telemetre_trig        : std_logic;
    signal SIGNAL_Test_Bench_telemetre_Dist_cm     : std_logic_vector(9 downto 0);

    -- Component Declaration
    component DE10_Lite_Telemetre_us_to_cm
        Port (
            clk         : In    std_logic;
            Rst_n       : In    std_logic;
            echo        : In    std_logic;
            trig        : Out   std_logic;
            Dist_cm     : Out   std_logic_vector(9 downto 0)
        );
    end component;

begin

    -- Instanciation
    DUT : DE10_Lite_Telemetre_us_to_cm
        Port map (
            clk     => SIGNAL_Test_Bench_telemetre_clk,
            Rst_n   => SIGNAL_Test_Bench_telemetre_Rst_n,
            echo    => SIGNAL_Test_Bench_telemetre_echo,
            trig    => SIGNAL_Test_Bench_telemetre_trig,
            Dist_cm => SIGNAL_Test_Bench_telemetre_Dist_cm
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_telemetre_clk <= '0';
        wait for 10 ns;
        SIGNAL_Test_Bench_telemetre_clk <= '1';
        wait for 10 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        SIGNAL_Test_Bench_telemetre_Rst_n <= '0';
        wait for 200 ns;
        SIGNAL_Test_Bench_telemetre_Rst_n <= '1';

        -- Test Calcule distance simple apres 1er trig
        wait until SIGNAL_Test_Bench_telemetre_trig = '1';
        wait until SIGNAL_Test_Bench_telemetre_trig = '0';

        wait for 1 ms;
        SIGNAL_Test_Bench_telemetre_echo <= '1';
        wait for 2 ms; -- 
        SIGNAL_Test_Bench_telemetre_echo <= '0';
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Dist_cm = "0000000011" report "Test 3cm" severity error;

        -- Test Calcule distance avant REST 
        wait until SIGNAL_Test_Bench_telemetre_trig = '1';
        wait for 1 ms;
        SIGNAL_Test_Bench_telemetre_echo <= '1';
        wait for 5 ms; -- 
        SIGNAL_Test_Bench_telemetre_echo <= '0';
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Dist_cm = "0000001000" report "Test 8cm" severity error;

        -- Test interruption avec RESET
        SIGNAL_Test_Bench_telemetre_Rst_n <= '0';
        wait for 200 ns;
        SIGNAL_Test_Bench_telemetre_Rst_n <= '1';

        -- Test Calcule distance post REST 
        wait until SIGNAL_Test_Bench_telemetre_trig = '1';
        wait for 9 ms;
        SIGNAL_Test_Bench_telemetre_echo <= '1';
        wait for 17 ms; -- 
        SIGNAL_Test_Bench_telemetre_echo <= '0';
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Dist_cm = "0000011100" report "Test 28cm" severity error;

        wait for 30ms;
        wait;
    end process;

end test_bench_DE10_Lite_Telemetre_us_to_cm_architecture;
