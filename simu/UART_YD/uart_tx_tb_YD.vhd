library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX_tb_YD is
end UART_TX_tb_YD;

architecture Bench of UART_TX_tb_YD is
    signal Clk         : std_logic := '0';
    signal Reset       : std_logic := '0';
    signal Go          : std_logic := '0';
    signal Data        : std_logic_vector(7 downto 0) := (others => '0');
    signal Tick        : std_logic := '0';
    signal Tx, TxBusy  : std_logic;
    signal Reg         : std_logic_vector(9 downto 0) := (others => '0');
    signal OK          : boolean := TRUE;
begin

process
begin
    while (now <= 300 us) loop
        Clk <= '0';
        wait for 10 ns;
        Clk <= '1';
        wait for 10 ns;
    end loop;
    wait;
end process;

    Reg <= '1' & Data & '0';

process
begin
    report "Starting UART Tx testbench...";

    Reset <= '1';
    wait for 10 ns;

    Reset <= '0';

    Data <= "10011001";
    Go <= '1';

    wait until Tick = '1';
    wait for 30 ns;

    Go <= '0';

    for i in 0 to Reg'length - 1 loop
        if (Tx /= Reg(i)) then
            report "There is a problem with the Tx waveform 1" severity error;
            OK <= FALSE;
        end if;
        wait for 8680.6 ns;
    end loop;

    if (OK) then
        report "UART Tx testbench passed" severity note;
    else
        report "UART Tx testbench failed" severity error;
    end if;

    wait for 10 us; 

    Data <= "10101010";
    Go <= '1';

    wait until Tick = '1';
    wait for 30 ns;

    Go <= '0';

    for i in 0 to Reg'length - 1 loop
        if (Tx /= Reg(i)) then
            report "There is a problem with the Tx waveform 2" severity error;
            OK <= FALSE;
        end if;
        wait for 8680.6 ns;
    end loop;

    if (OK) then
        report "UART Tx testbench passed" severity note;
    else
        report "UART Tx testbench failed" severity error;
    end if;

    wait for 10 us; 

    Data <= "11001100";
    Go <= '1';

    wait until Tick = '1';
    wait for 30 ns;

    Go <= '0';

    for i in 0 to Reg'length - 1 loop
        if (Tx /= Reg(i)) then
            report "There is a problem with the Tx waveform 3" severity error;
            OK <= FALSE;
        end if;
        wait for 8680.6 ns;
    end loop;

    if (OK) then
        report "UART Tx testbench passed" severity note;
    else
        report "UART Tx testbench failed" severity error;
    end if;

    wait;
end process;

fdiv: entity work.FDIV
    port map (
        Clk       => Clk,
        Reset     => Reset,
        Tick      => open,
        Tick_half => Tick
    );

UART_TX: entity work.UART_TX
    port map (
        Clk   => Clk,
        Reset => Reset,
        LD    => Go,
        Din  => Data,
        Tick  => Tick,
        Tx_Busy => TxBusy, 
        Tx    => Tx
    );

end Bench;
-- Code de Yann Douze 