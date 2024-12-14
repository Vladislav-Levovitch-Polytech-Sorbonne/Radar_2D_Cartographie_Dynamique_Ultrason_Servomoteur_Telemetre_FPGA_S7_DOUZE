library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity test_bench_DE10_Lite_Servomoteur_Avalon_entity is
end test_bench_DE10_Lite_Servomoteur_Avalon_entity;

architecture test_bench_DE10_Lite_Servomoteur_architecture of test_bench_DE10_Lite_Servomoteur_Avalon_entity is

    -- Signal
    signal SIGNAL_Test_Bench_Servomoteur_Avalon_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_Servomoteur_Avalon_reset_n    : std_logic := '1';
    signal SIGNAL_Test_Bench_Servomoteur_Avalon_chipselect : std_logic := '1';
    signal SIGNAL_Test_Bench_Servomoteur_Avalon_write_n    : std_logic := '0';
    signal SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData  : std_logic_vector(15 downto 0) := ( others => '0' );

    signal SIGNAL_Test_Bench_Servomoteur_Avalon_commande   : std_logic;

    -- Component Declaration
    component DE10_Lite_Servomoteur_Avalon
        Port (
            -- Host Side
            clk         : In    std_logic;                       -- 50MHz -- Rectification en fait c est 100MHz et non 50MHz
            reset_n     : In    std_logic;                       -- Reset in low state
            chipselect  : In    std_logic;                       -- Avalon CS
            write_n     : In    std_logic;                       -- Avalon WE (NOT)
            WriteData   : In    std_logic_vector(15 downto 0);   -- Position in 0.1°  

            commande    : Out   std_logic   
        );
    end component;

begin

    -- Instanciation
    DUT : entity work.DE10_Lite_Servomoteur_Avalon
        Port map (
            clk         => SIGNAL_Test_Bench_Servomoteur_Avalon_clk,
            reset_n     => SIGNAL_Test_Bench_Servomoteur_Avalon_reset_n,
            chipselect  => SIGNAL_Test_Bench_Servomoteur_Avalon_chipselect,
            write_n     => SIGNAL_Test_Bench_Servomoteur_Avalon_write_n,
            WriteData   => SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData,
            commande    => SIGNAL_Test_Bench_Servomoteur_Avalon_commande
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_Servomoteur_Avalon_clk <= '0';
        wait for 5 ns;
        SIGNAL_Test_Bench_Servomoteur_Avalon_clk <= '1';
        wait for 5 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        SIGNAL_Test_Bench_Servomoteur_Avalon_reset_n <= '0';
        wait for 200 ns;
        SIGNAL_Test_Bench_Servomoteur_Avalon_reset_n <= '1';
-- Test Position caracteristique de T_commande, peridode de commande connues 
        -- Position 900 * 0.1° = 90°
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= "0000001110000100";
        wait for 1 ms;
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait for 5 ms;

        -- Position 45 * 0.1° = 45°
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= "0000000111000010"; -- >> 1 div 900 par 2 = 450 * 0.1° = 45°
        wait for 1 ms;
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait for 5 ms;

        -- Position 0 * 0.1° = 0°
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= ( others => '0' );
        wait for 1 ms;
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait for 5 ms;

-- Test Position angulaire a decimale de T_commande 
        wait for 5 ms;
        -- Position 324 * 0.1° = 32,5°
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= "0000000101000101";
        wait for 1 ms;
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait for 0.5 ms; -- 0 ° = 0,5ms 
        wait for 305 us; -- 325 * 0,94us = 305,5us
        assert SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1' report "32,4°" severity error;
        wait for 1 us; -- 325 * 0,94us = 305,5us
        assert SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0' report "32,4°" severity error;

-- Test Reset not
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait for 1 ms;
        SIGNAL_Test_Bench_Servomoteur_Avalon_reset_n <= '0'; -- Interruption Commande
        wait for 3 ms;
        SIGNAL_Test_Bench_Servomoteur_Avalon_reset_n <= '1'; -- Fin d interruption Commande

        wait for 20ms;
-- Test du plafond de verre
        -- Position 900> * 0.1° = 90°
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= ( others => '1' );
        wait for 1 ms;
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait for 5 ms;

-- Test ChipSelect 
        -- CS = 0 devant reset a 0 la commande
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande
        wait for 900 us; -- Attendre juste avant la fin de T_min en cas de commande
        SIGNAL_Test_Bench_Servomoteur_Avalon_chipselect <= '0';
        wait for 10 ms;
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= ( others => '0' );
        wait for 20 ms;
        assert SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0' report "CS°" severity error;

        -- CS = 1 retour precedente commande
        SIGNAL_Test_Bench_Servomoteur_Avalon_chipselect <= '1';

        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait for 5 ms;

-- Test Write_NOT
        SIGNAL_Test_Bench_Servomoteur_Avalon_write_n <= '1';
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= "0000000111000010";
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait for 5 ms;
        SIGNAL_Test_Bench_Servomoteur_Avalon_WriteData <= "0010100111000010";
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '1'; -- Debut commande 
        wait until SIGNAL_Test_Bench_Servomoteur_Avalon_commande = '0'; -- Fin commande 
        wait;
    end process;
end test_bench_DE10_Lite_Servomoteur_architecture;
-- Certaine valeurs du TestBench releve encore du modele 90°