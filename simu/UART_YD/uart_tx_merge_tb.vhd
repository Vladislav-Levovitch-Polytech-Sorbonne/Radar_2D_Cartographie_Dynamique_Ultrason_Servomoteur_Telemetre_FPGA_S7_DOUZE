library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_tx_merge_tb is
end uart_tx_merge_tb;

architecture Bench of uart_tx_merge_tb is
    signal Clk         : std_logic := '0';
    signal Reset       : std_logic := '0';
    signal Data        : std_logic_vector(7 downto 0) := (others => '0');
    signal Tx          : std_logic;
    signal Reg         : std_logic_vector(9 downto 0) := (others => '0');
begin

process
begin
    Clk <= '0';
    wait for 10 ns;
    Clk <= '1';
    wait for 10 ns;
end process;

    Reg <= '1' & Data & '0';

process
begin
    report "Starting UART Tx testbench ...";

    Reset <= '1';
    wait for 10 ns;

    Reset <= '0';

    wait for 90 us;
    Data <= "10011001";

    for i in 0 to Reg'length - 1 loop
        wait for 8680.6 ns;
    end loop;

    wait for 10 us; 

    Data <= "10101010";
    for i in 0 to Reg'length - 1 loop
        wait for 8680.6 ns;
    end loop;

    wait for 10 us; 

    Data <= "11001100";

    for i in 0 to Reg'length - 1 loop
        wait for 8680.6 ns;
    end loop;

    wait for 20 ms;
    for i in 0 to Reg'length - 1 loop
        wait for 8680.6 ns;
    end loop;
    wait;
end process;

UART_TX_merged: entity work.uart_tx_merge_YD
    port map (
        Clk    => Clk,
        Reset  => Reset,
        -- LD  => LD,         
        Din    => Data,         
        Tx     => Tx      
    );

end Bench;
-- Code de Yann Douze 