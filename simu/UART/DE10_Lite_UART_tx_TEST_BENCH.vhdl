library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_bench_DE10_Lite_UART_tx_YD_entity is
end entity;

architecture Behavioral of test_bench_DE10_Lite_UART_tx_YD_entity is

    -- Signal
    signal SIGNAL_Test_Bench_UART_tx_clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_UART_tx_reset_n    : std_logic := '1';
    signal SIGNAL_Test_Bench_UART_tx_load       : std_logic := '0';
    signal SIGNAL_Test_Bench_UART_tx_ascii      : std_logic_vector(7 downto 0) := (others => '0');

    signal SIGNAL_Test_Bench_UART_tx_uart_tx    : std_logic;

    -- Constants for clock generation
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock

    -- Content
begin

    -- Instance of the entity under test
    DUT: entity work.DE10_Lite_UART_tx_YD
        port map (
            Clk      => SIGNAL_Test_Bench_UART_tx_clk,
            Reset_n  => SIGNAL_Test_Bench_UART_tx_reset_n,
            Load     => SIGNAL_Test_Bench_UART_tx_load,
            Ascii    => SIGNAL_Test_Bench_UART_tx_ascii,
            
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

        -- Test case 1: Transmit first data (ASCII 'A', 8'h41)
        SIGNAL_Test_Bench_UART_tx_ascii <= "01000001"; -- ASCII 'A'
        SIGNAL_Test_Bench_UART_tx_load <= '1'; -- Trigger the load signal
        wait for 600*CLK_PERIOD;
        SIGNAL_Test_Bench_UART_tx_load <= '0'; -- Deactivate load
        wait for 130 us; -- Wait for the data to transmit completely (including stop bit)

        -- Test case 2: Transmit second data (ASCII 'B', 8'h42)
        SIGNAL_Test_Bench_UART_tx_ascii <= "01000010"; -- ASCII 'B'
        SIGNAL_Test_Bench_UART_tx_load <= '1'; -- Trigger the load signal
        wait for 600*CLK_PERIOD;
        SIGNAL_Test_Bench_UART_tx_load <= '0'; -- Deactivate load
        wait for 90 us; -- Wait for the data to transmit completely

        -- Test case 3: Transmit third data (ASCII 'C', 8'h43)
        SIGNAL_Test_Bench_UART_tx_ascii <= "01000011"; -- ASCII 'C'
        SIGNAL_Test_Bench_UART_tx_load <= '1'; -- Trigger the load signal
        wait for 600*CLK_PERIOD;
        SIGNAL_Test_Bench_UART_tx_load <= '0'; -- Deactivate load
        wait for 120 us; -- Wait for the data to transmit completely

        SIGNAL_Test_Bench_UART_tx_reset_n <= '0';
        wait for 70 us;

        SIGNAL_Test_Bench_UART_tx_load <= '1';
        wait for 70 us;

        SIGNAL_Test_Bench_UART_tx_reset_n <= '1';
        -- End simulation
        wait;
    end process;

end architecture;
