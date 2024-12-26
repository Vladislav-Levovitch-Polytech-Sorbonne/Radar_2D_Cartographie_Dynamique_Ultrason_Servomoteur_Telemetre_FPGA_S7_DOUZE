library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_bench_DE10_Lite_UART_Avalon_entity is
end entity;

architecture Behavioral of test_bench_DE10_Lite_UART_Avalon_entity is

    -- Signal
    signal SIGNAL_Test_Bench_UART_Clk        : std_logic := '0';
    signal SIGNAL_Test_Bench_UART_Reset_n    : std_logic := '1';
    signal SIGNAL_Test_Bench_UART_Address    : std_logic_vector(1  downto 0) := "00";
    signal SIGNAL_Test_Bench_UART_Read_n     : std_logic := '0';
    signal SIGNAL_Test_Bench_UART_WriteData  : std_logic_vector(31 downto 0) := (others => '0');
    signal SIGNAL_Test_Bench_UART_Write_n    : std_logic := '0';

    
    signal SIGNAL_Test_Bench_UART_ReadData   : std_logic_vector(31 downto 0);

    signal SIGNAL_Test_Bench_UART_Rx         : std_logic := '1';
    signal SIGNAL_Test_Bench_UART_Tx         : std_logic;

    -- Constants for clock generation
    constant CLK_PERIOD : time := 10 ns; -- 50*2 MHz clock

    -- Content
begin

    -- Instance of the entity under test
    DUT: entity work.DE10_Lite_UART_Avalon
        port map (
            Clk       => SIGNAL_Test_Bench_UART_Clk,
            Reset_n   => SIGNAL_Test_Bench_UART_Reset_n,
            Address   => SIGNAL_Test_Bench_UART_Address,
            Read_n    => SIGNAL_Test_Bench_UART_Read_n,
            WriteData => SIGNAL_Test_Bench_UART_WriteData,
            Write_n   => SIGNAL_Test_Bench_UART_Write_n,

            ReadData  => SIGNAL_Test_Bench_UART_ReadData,

            Uart_Rx   => SIGNAL_Test_Bench_UART_Rx,
            Uart_Tx   => SIGNAL_Test_Bench_UART_Tx
        );

    -- Clock generation
    process
    begin
        while true loop
            SIGNAL_Test_Bench_UART_Clk <= '0';
            wait for CLK_PERIOD / 2;
            SIGNAL_Test_Bench_UART_Clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test process
    process
    begin
        -- Initial reset
        SIGNAL_Test_Bench_UART_Reset_n <= '0';
        wait for 50 ns;
        SIGNAL_Test_Bench_UART_Reset_n <= '1';
        wait for 50 ns;
    
    -- Test Transmit
        -- Test case 1 : Transmit first data (ASCII 'V')
        SIGNAL_Test_Bench_UART_Read_n    <= '1';
        SIGNAL_Test_Bench_UART_Address   <= "01"; -- ASCii_input 
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000001010110"; -- ASCII 'V'     -ladislav
        wait for CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Address   <= "00"; -- Load_input 
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 600*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000000"; -- Disable load
        wait for CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Read_n    <= '0';
        SIGNAL_Test_Bench_UART_Write_n   <= '1';
        SIGNAL_Test_Bench_UART_Address   <= "10"; -- Open Read
        wait for 130 us; -- Wait for the data to transmit completely (including stop bit)




        -- Test case 2 : Transmit second data (ASCII 'L')
        SIGNAL_Test_Bench_UART_Address   <= "01"; -- ASCii_input 
        SIGNAL_Test_Bench_UART_Read_n    <= '1';
        SIGNAL_Test_Bench_UART_Write_n   <= '0';
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000001001100"; -- ASCII 'L'     -evovitch
        wait for CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Address   <= "00"; -- Load_input 
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 600*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000000"; -- Disable load
        wait for CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Read_n    <= '0';
        SIGNAL_Test_Bench_UART_Write_n   <= '1';
        SIGNAL_Test_Bench_UART_Address   <= "10"; -- Open Read
        wait for 130 us; -- Wait for the data to transmit completely (including stop bit)

        -- Test case 3 : Transmit interrupted third data (ASCII 'B')
        SIGNAL_Test_Bench_UART_Address   <= "01"; -- ASCii_input 
        SIGNAL_Test_Bench_UART_Read_n    <= '1';
        SIGNAL_Test_Bench_UART_Write_n   <= '0';
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000001000010"; -- ASCII 'B'     -ALAYAN
        wait for CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Address   <= "00"; -- Load_input 
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 600*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000000"; -- Disable load
        wait for CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Read_n    <= '0';
        SIGNAL_Test_Bench_UART_Write_n   <= '1';
        SIGNAL_Test_Bench_UART_Address   <= "10"; -- Open Read
        wait for 70 us; -- Wait for the data to transmit completely (including stop bit)

    -- Test Reset
        SIGNAL_Test_Bench_UART_Reset_n <= '0';
        wait for 70 us;

        SIGNAL_Test_Bench_UART_Read_n    <= '1';
        SIGNAL_Test_Bench_UART_Write_n   <= '0';
        SIGNAL_Test_Bench_UART_Address   <= "00"; -- Load_input 
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000001"; -- Trigger the load signal
        wait for 20 us;
        SIGNAL_Test_Bench_UART_Read_n    <= '0';
        SIGNAL_Test_Bench_UART_Write_n   <= '1';
        SIGNAL_Test_Bench_UART_Address   <= "10"; -- Open Read
        if (SIGNAL_Test_Bench_UART_Tx = '1') then
            report "UART Rx testbench Reset passed" severity note;
        else
            report "UART Rx testbench Reset failed" severity error;
        end if;
        wait for 50 us;

        SIGNAL_Test_Bench_UART_Reset_n <= '1';
        
        SIGNAL_Test_Bench_UART_Read_n    <= '1';
        SIGNAL_Test_Bench_UART_Write_n   <= '0';
        SIGNAL_Test_Bench_UART_Address   <= "00"; -- Load_input 
        wait for 20 us;
        SIGNAL_Test_Bench_UART_WriteData <= "00000000000000000000000000000000"; -- Disable load
        wait for 20 us;
        SIGNAL_Test_Bench_UART_Read_n    <= '0';
        SIGNAL_Test_Bench_UART_Write_n   <= '1';
        SIGNAL_Test_Bench_UART_Address   <= "10"; -- Open Read

    -- Test Read
        wait for 130 us;
        SIGNAL_Test_Bench_UART_Address   <= "10"; -- Read Rx_Data 

        -- Test case 0 : Read random data (ASCII ?)
        SIGNAL_Test_Bench_UART_Rx <= '0';
        wait for 434*4*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Rx <= '1';
        wait for 70 us;

        if (SIGNAL_Test_Bench_UART_ReadData = "00000000000000000000000011111000") then
            report "UART Rx testbench random passed" severity note;
        else
            report "UART Rx testbench random failed" severity error;
        end if;

        -- Test case 1 : Read data (ASCII 'v') - Byte binary code STOP_1 01110110 START_0
        SIGNAL_Test_Bench_UART_Rx <= '0';
        wait for 434*2*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Rx <= '1';
        wait for 434*2*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Rx <= '0';
        wait for 434*1*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Rx <= '1';
        wait for 434*3*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Rx <= '0';
        wait for 434*1*CLK_PERIOD*2;
        SIGNAL_Test_Bench_UART_Rx <= '1';
        wait for 30 us;

        if (SIGNAL_Test_Bench_UART_ReadData = "00000000000000000000000001110110") then
            report "UART Rx testbench ASCII 'v' passed" severity note;
        else
            report "UART Rx testbench ASCII 'v' failed" severity error;
        end if;

        -- End simulation
        wait;
    end process;

end architecture;
