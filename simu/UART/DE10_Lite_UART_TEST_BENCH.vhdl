library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_bench_DE10_Lite_UART_entity is
end entity;

architecture Behavioral of test_bench_DE10_Lite_UART_entity is

    -- Signal
    signal SIGNAL_Test_Bench_UART_tx_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_UART_tx_reset_n    : std_logic := '1';
    signal SIGNAL_Test_Bench_UART_tx_load       : std_logic_vector(31 downto 0) := (others => '0');
    signal SIGNAL_Test_Bench_UART_tx_ascii      : std_logic_vector(31 downto 0) := (others => '0');
    signal SIGNAL_Test_Bench_uart_rx            : std_logic := '1';

    signal SIGNAL_Test_Bench_UART_Rx_Data       : std_logic_vector(31 downto 0);
    signal SIGNAL_Test_Bench_UART_tx_uart_tx    : std_logic;

    -- Constants for clock generation
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock

    -- Content
begin

    -- Instance of the entity under test
    DUT: entity work.DE10_Lite_UART
        port map (
            Clk      => SIGNAL_Test_Bench_UART_tx_clk,
            Reset_n  => SIGNAL_Test_Bench_UART_tx_reset_n,
            Load     => SIGNAL_Test_Bench_UART_tx_load,
            Ascii    => SIGNAL_Test_Bench_UART_tx_ascii,
            Uart_Rx  => SIGNAL_Test_Bench_uart_rx,
            
            Rx_Data  => SIGNAL_Test_Bench_UART_Rx_Data,
            Uart_Tx  => SIGNAL_Test_Bench_UART_tx_uart_tx
        );

    -- Clock generation
    process
    begin
        while true loop
            SIGNAL_Test_Bench_UART_tx_clk <= '0';
            wait for CLK_PERIOD / 2;
            SIGNAL_Test_Bench_UART_tx_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test process
    process
    begin
        -- Initial reset
        SIGNAL_Test_Bench_UART_tx_reset_n <= '0';
        wait for 50 ns;
        SIGNAL_Test_Bench_UART_tx_reset_n <= '1';
        wait for 50 ns;
    
    -- Test Transmit
        -- Test case 1 : Transmit first data (ASCII 'V')
        SIGNAL_Test_Bench_UART_tx_ascii <= "00000000000000000000000001010110"; -- ASCII 'V'     -ladislav
        SIGNAL_Test_Bench_UART_tx_load <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 600*CLK_PERIOD;
        SIGNAL_Test_Bench_UART_tx_load <= "00000000000000000000000000000000"; -- Disable load
        wait for 130 us; -- Wait for the data to transmit completely (including stop bit)

        -- Test case 2 : Transmit second data (ASCII 'L')
        SIGNAL_Test_Bench_UART_tx_ascii <= "00000000000000000000000001001100"; -- ASCII 'L'     -evovitch
        SIGNAL_Test_Bench_UART_tx_load <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 600*CLK_PERIOD;
        SIGNAL_Test_Bench_UART_tx_load <= "00000000000000000000000000000000"; -- Disable load
        wait for 100 us; -- Wait for the data to transmit completely

        -- Test case 3 : Transmit interrupted third data (ASCII 'B')
        SIGNAL_Test_Bench_UART_tx_ascii <= "00000000000000000000000001000010"; -- ASCII 'B'     -ALAYAN
        SIGNAL_Test_Bench_UART_tx_load  <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 600*CLK_PERIOD;
        SIGNAL_Test_Bench_UART_tx_load  <="00000000000000000000000000000000"; -- Disable load
        wait for 70us;

        SIGNAL_Test_Bench_UART_tx_reset_n <= '0';
        wait for 70 us;

        SIGNAL_Test_Bench_UART_tx_load <= "00000000000000000000000000000001";
        wait for 70 us;

        SIGNAL_Test_Bench_UART_tx_reset_n <= '1';

    -- Test Read
        wait for 160 us;
        SIGNAL_Test_Bench_UART_tx_load <= "00000000000000000000000000000000";
        wait for 10 us;

        -- Test case 0 : Read random data (ASCII '?')
        SIGNAL_Test_Bench_uart_rx <= '0';
        wait for 434*4*CLK_PERIOD;
        SIGNAL_Test_Bench_uart_rx <= '1';
        wait for 70 us;

        -- Test case 1 : Read data (ASCII 'v') - Byte binary code STOP_1 01110110 START_0
        SIGNAL_Test_Bench_uart_rx <= '0';
        wait for 434*2*CLK_PERIOD;
        SIGNAL_Test_Bench_uart_rx <= '1';
        wait for 434*2*CLK_PERIOD;
        SIGNAL_Test_Bench_uart_rx <= '0';
        wait for 434*1*CLK_PERIOD;
        SIGNAL_Test_Bench_uart_rx <= '1';
        wait for 434*3*CLK_PERIOD;
        SIGNAL_Test_Bench_uart_rx <= '0';
        wait for 434*1*CLK_PERIOD;
        SIGNAL_Test_Bench_uart_rx <= '1';
        wait for 30 us;


        -- End simulation
        wait;
    end process;

end architecture;
