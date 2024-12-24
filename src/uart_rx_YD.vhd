library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX_YD is
    port (
        Clk          : in std_logic;
        Reset        : in std_logic;
        Rx           : in std_logic;
        Tick_halfbit : in std_logic;
        Clear_fdiv   : out std_logic;
        DAV          : out std_logic; 
        Err          : out std_logic;
        Data        : out std_logic_vector(7 downto 0)
    );
end UART_RX_YD;

architecture RTL of UART_RX_YD is
    type StateTYpe is (E0,E1,E2, E3, E4, E5, E6, E7, E8, E9, E10, Erreur); 
    signal State : StateType;
    signal i : integer range 0 to 15; 
    signal reg : std_logic_vector(7 downto 0); 
    signal Rxr, Rxrr : std_logic; 
begin
process(clk, reset)
begin
    if reset = '1' then
        State <= E0; 
        i <= 0; 
        reg <= (others => '0'); 
        Rxr <= '0'; 
        Rxrr <= '0';
        Clear_Fdiv <= '0'; 
        DAV <= '0'; 
        Err <= '0'; 
        Data <= (others => '0'); 
    elsif rising_edge(clk) then
        -- resynchornisation de l'entre asynchrone Rx
        Rxr <= Rx; -- 1ere bascule Dff
        Rxrr <= Rxr; -- 2eme bascule Dff

        case STate is 
            when E0 => 
                if Rxrr = '0' then 
                    Clear_fdiv <= '1'; 
                    i <= 0; 
                    State <= E1; 
                end if; 
            when E1 => 
                State <= E2; 
                Clear_fdiv <= '0';
            when E2 => 
                if Tick_halfbit = '1' then 
                    State <= E3; 
                end if; 
            when E3 => 
                if Rxrr = '0' then 
                    State <= E4; 
                elsif Rxrr = '1' then 
                    State <= Erreur; 
                    Err <= '1'; 
                end if; 
            when E4 => 
                if Tick_halfbit = '1' then 
                    State <= E5; 
                end if; 
            when E5 => 
                if Tick_halfbit = '1' then 
                    State <= E6;
                    reg(i) <= Rxrr;  
                end if; 
            When E6 => 
                if Tick_halfbit = '1' then 
                    State <= E7; 
                    i <= i + 1; 
                end if; 
            when E7 => 
                if i = 8 then 
                    State <= E8; 
                elsif Tick_halfbit = '1' then 
                    State <= E6; 
                    reg(i) <= Rxrr; 
                end if; 
            when E8 => 
                if Tick_halfbit = '1' then 
                    State <= E9; 
                end if; 
            when E9 => 
                if Rxrr= '0' then 
                    State <= Erreur; 
                    Err <= '1'; 
                elsif Rxrr = '1' then 
                    State <= E10; 
                    Data <= reg; 
                    DAV <= '1'; 
                end if; 
            when E10 => 
                State <= E0; 
                DAV <= '0'; 
                i <= 0; 
            when Erreur => 
                State <= E0; 
                Err <= '0'; 
            when others => State <= E0; 
        end case; 
    end if;
end process;

end RTL;

-- Code de Yann Douze 