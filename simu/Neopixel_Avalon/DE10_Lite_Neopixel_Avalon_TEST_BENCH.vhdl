library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_Avalon_TEST_BENCH_entity is
end DE10_Lite_Neopixel_Avalon_TEST_BENCH_entity;

architecture DE10_Lite_Neopixel_Avalon_TEST_BENCH_architecture of DE10_Lite_Neopixel_Avalon_TEST_BENCH_entity is

    -- Signal
    signal SIGNAL_Test_Bench_Neopixel_Avalon_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_Neopixel_Avalon_reset_n    : std_logic := '1';
    -- Signal SIGNAL_Test_Bench_Neopixel_nb_led     : std_logic_vector(7 downto 0) := ( others => '0' );
    signal SIGNAL_Test_Bench_Neopixel_Avalon_chipselect : std_logic := '1';
    signal SIGNAL_Test_Bench_Neopixel_Avalon_write_n    : std_logic := '0';
    signal SIGNAL_Test_Bench_Neopixel_Avalon_WriteData  : std_logic_vector(7 downto 0) := ( others => '0' );


    signal SIGNAL_Test_Bench_Neopixel_Avalon_commande   : std_logic;

    -- Component Declaration
    component DE10_Lite_Neopixel_Avalon
        Port 
        (
            clk         : In    std_logic;
            reset_n     : In    std_logic;
            chipselect  : In    std_logic;                       -- Avalon CS
            write_n     : In    std_logic;                       -- Avalon WE (NOT)
            WriteData   : In    std_logic_vector(7 downto 0);    -- Nb leds to turn ON  

            commande    : Out   std_logic
        );
    end component;

begin

    -- Instanciation
    DUT : entity work.DE10_Lite_Neopixel_Avalon
        Port map 
        (
            clk         => SIGNAL_Test_Bench_Neopixel_Avalon_clk,
            reset_n     => SIGNAL_Test_Bench_Neopixel_Avalon_reset_n,
            chipselect  => SIGNAL_Test_Bench_Neopixel_Avalon_chipselect,
            write_n     => SIGNAL_Test_Bench_Neopixel_Avalon_write_n,
            WriteData   => SIGNAL_Test_Bench_Neopixel_Avalon_WriteData,

            commande    => SIGNAL_Test_Bench_Neopixel_Avalon_commande
        );

    -- Clock generation
    clk_process : process
    begin
        SIGNAL_Test_Bench_Neopixel_Avalon_clk <= '0';
        wait for 5 ns;
        SIGNAL_Test_Bench_Neopixel_Avalon_clk <= '1';
        wait for 5 ns;
    end process;

    -- Test process
    Test_bench : process
    begin
        -- Reset
        SIGNAL_Test_Bench_Neopixel_Avalon_WriteData <= "00000011";
        SIGNAL_Test_Bench_Neopixel_Avalon_reset_n <= '0';
        wait for 500 ns;
        SIGNAL_Test_Bench_Neopixel_Avalon_reset_n <= '1';

        wait for 550 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_WriteData <= "00000111";
        wait for 350 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_reset_n <= '0';
        wait for 500 ns;
        SIGNAL_Test_Bench_Neopixel_Avalon_reset_n <= '1';
        
        wait for 1000 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_WriteData <= "11111111";
        SIGNAL_Test_Bench_Neopixel_Avalon_chipselect<= '0';
        wait for 150 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_WriteData <= "00000001";
        wait for 150 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_chipselect<= '1';
        wait for 150 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_write_n<= '0';
        wait for 150 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_WriteData <= "00000011";
        wait for 300 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_write_n<= '1';
        wait for 450 us;
        SIGNAL_Test_Bench_Neopixel_Avalon_WriteData <= "00000010";
        wait;
    end process;
end;
