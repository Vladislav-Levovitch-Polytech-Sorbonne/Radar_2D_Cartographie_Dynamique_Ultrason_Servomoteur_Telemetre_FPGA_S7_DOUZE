library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX_YD is
    port (
        Clk   : in std_logic;
        Reset : in std_logic;
        LD    : in std_logic;
        Din   : in std_logic_vector(7 downto 0);
        Tick  : in std_logic;
        Tx_Busy  : out std_logic;
        Tx    : out std_logic
    );
end entity;

architecture RTL of UART_TX_YD is
    type StateType is (E1,E2,E3,E4,E5); 
    signal State : StateType; 
    signal reg : std_logic_vector(9 downto 0); 
    signal i : integer range 0 to 15; 

begin
 process(clk, reset)
 begin
    if reset = '1' then
        reg <= (others => '0'); 
        i <= 0; 
        State <= E1; 
        Tx <= '1'; 
        Tx_Busy <= '0'; 
    elsif rising_edge(clk) then
        case State is 
            when E1 => 
                if LD = '1' then 
                    reg <= '1' & Din & '0'; 
                    Tx_Busy <= '1'; 
                    i <= 0; 
                    State <= E2; 
                end if; 
            when E2 => 
                if Tick = '1' then 
                    State <= E3; 
                    Tx <= reg(i); 
                end if; 
            when E3 => 
                STate <= E4; 
                i <= i + 1; 
            when E4 => 
                if i = 10 then 
                    STate <= E5; 
                    i <= 0; 
                elsif Tick = '1' then 
                    State <= E3; 
                    Tx <= reg(i); 
                end if; 
            when E5 => 
                if Tick = '1' then 
                    State <= E1; 
                    TX_Busy <= '0'; 
                end if; 
            when others => State <= E1; 
            end case; 
 
    end if;
 end process;

end architecture;
-- Code de Yann Douze 