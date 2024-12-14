library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_bench_DE10_Lite_Telemetre_us_to_cm_Avalon_entity is
end test_bench_DE10_Lite_Telemetre_us_to_cm_Avalon_entity;

architecture test_bench_DE10_Lite_Telemetre_us_to_cm_Avalon_architecture of test_bench_DE10_Lite_Telemetre_us_to_cm_Avalon_entity is

-- Signal
    signal SIGNAL_Test_Bench_telemetre_Avalon_clk         : std_logic := '0';
    signal SIGNAL_Test_Bench_telemetre_Avalon_Rst_n       : std_logic := '1';
    signal SIGNAL_Test_Bench_telemetre_Avalon_echo        : std_logic := '0';
    signal SIGNAL_Test_Bench_telemetre_Avalon_chipselect  : std_logic := '0';
    signal SIGNAL_Test_Bench_telemetre_Avalon_read_n      : std_logic := '0';

    signal SIGNAL_Test_Bench_telemetre_Avalon_trig        : std_logic;
    signal SIGNAL_Test_Bench_telemetre_Avalon_Dist_cm     : std_logic_vector(9 downto 0);
    signal SIGNAL_Test_Bench_telemetre_Avalon_readdata    : std_logic_vector(31 downto 0);

-- Content
begin

    -- Instanciation
    DUT : entity work.DE10_Lite_Telemetre_us_Avalon
        Port map (
            clk     => SIGNAL_Test_Bench_telemetre_Avalon_clk,
            Rst_n   => SIGNAL_Test_Bench_telemetre_Avalon_Rst_n,
            echo    => SIGNAL_Test_Bench_telemetre_Avalon_echo,
            chipselect => SIGNAL_Test_Bench_telemetre_Avalon_chipselect,
            read_n  => SIGNAL_Test_Bench_telemetre_Avalon_read_n,
            trig    => SIGNAL_Test_Bench_telemetre_Avalon_trig,
            Dist_cm => SIGNAL_Test_Bench_telemetre_Avalon_Dist_cm,
            readdata => SIGNAL_Test_Bench_telemetre_Avalon_readdata
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_telemetre_Avalon_clk <= '0';
        wait for 5 ns;
        SIGNAL_Test_Bench_telemetre_Avalon_clk <= '1';
        wait for 5 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        SIGNAL_Test_Bench_telemetre_Avalon_Rst_n <= '0';
        wait for 2 ns;
        SIGNAL_Test_Bench_telemetre_Avalon_Rst_n <= '1';

        -- Test Calcule distance simple apres 1er trig
        assert SIGNAL_Test_Bench_telemetre_Avalon_readdata = "00000000000000000000000000000000" report "Etat init" severity error;
        wait until SIGNAL_Test_Bench_telemetre_Avalon_trig = '1';
        wait for 2 ms;

        -- Activation chipselect pour le peripherique
        SIGNAL_Test_Bench_telemetre_Avalon_chipselect <= '1'; -- Ecriture ON
        SIGNAL_Test_Bench_telemetre_Avalon_echo <= '1';
        assert SIGNAL_Test_Bench_telemetre_Avalon_readdata = "00000000000000000000000000000000" report "Ecriture 0 + MAJ 0 Lecture 1" severity error;

        wait for 2 ms; -- 
        SIGNAL_Test_Bench_telemetre_Avalon_echo <= '0';
        wait for 3 ms;
        SIGNAL_Test_Bench_telemetre_Avalon_read_n <= '1';  -- Operation d ecriture
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Avalon_Dist_cm = "0000100001" report "Test 33cm" severity error;
        assert SIGNAL_Test_Bench_telemetre_Avalon_readdata = "00000000000000000000000000100001" report "Ecriture 1 + MAJ 1 Lecture 2" severity error;

        -- Test Calcule distance avant RESET 
        wait until SIGNAL_Test_Bench_telemetre_Avalon_trig = '1';
        wait for 2 ms;

        SIGNAL_Test_Bench_telemetre_Avalon_echo <= '1';
        wait for 5 ms; -- 
        SIGNAL_Test_Bench_telemetre_Avalon_echo <= '0';
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Avalon_Dist_cm = "0001010011" report "Test 82cm" severity error;
        assert SIGNAL_Test_Bench_telemetre_Avalon_readdata = "00000000000000000000000000100001" report "Ecriture 1 + sans MAJ Lecture 3" severity error;

        -- Test interruption avec RESET
        SIGNAL_Test_Bench_telemetre_Avalon_Rst_n <= '0';
        wait for 200 ns;
        SIGNAL_Test_Bench_telemetre_Avalon_Rst_n <= '1';

        -- Test Calcule distance post RESET 
        wait until SIGNAL_Test_Bench_telemetre_Avalon_trig = '1';
        wait for 2 ms;
        
        SIGNAL_Test_Bench_telemetre_Avalon_echo <= '1';
        wait for 17 ms; -- 
        SIGNAL_Test_Bench_telemetre_Avalon_echo <= '0';
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Avalon_Dist_cm = "0100011010" report "Test 281cm" severity error;

        -- Test de lecture (read_n = '0')
        SIGNAL_Test_Bench_telemetre_Avalon_read_n <= '0';  -- Lecture
        wait for 10 ms;
        assert SIGNAL_Test_Bench_telemetre_Avalon_readdata = "00000000000000000000000100011010" report "Lecture distance" severity error;
        
        -- Fin du test
        wait for 30 ms;
        wait;
    end process;

end test_bench_DE10_Lite_Telemetre_us_to_cm_Avalon_architecture;
