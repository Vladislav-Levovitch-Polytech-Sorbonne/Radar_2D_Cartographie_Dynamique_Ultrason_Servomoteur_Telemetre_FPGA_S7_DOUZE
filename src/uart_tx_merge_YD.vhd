library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_merge_YD is
    port 
    (
        Clk    : in std_logic;              -- Horloge (par exemple, 50 MHz)
        Reset  : in std_logic;              -- Reinitialisation
        -- LD     : in std_logic;              -- Signal de chargement pour UART_TX
        Din    : in std_logic_vector(7 downto 0); -- Donnée à transmettre
        Tx     : out std_logic              -- Sortie UART (TX)
    );
end entity;

architecture Behavioral of uart_tx_merge_YD is

    -- Signals
    signal Tick       : std_logic;
    signal Tick_half  : std_logic;
    signal Tx_Busy    : std_logic;
    signal Counter    : unsigned(24 downto 0) := (others => '0'); -- Compteur pour 1 seconde
    signal LD_Auto    : std_logic := '0'; -- Signal automatique de LD

begin

    -- Instanciation du diviseur d'horloge FDIV
    FDIV_inst : entity work.fdiv_YD
        port map 
        (
            Clk => Clk,
            Reset => Reset,
            Tick => Tick,
            Tick_half => Tick_half
        );

    -- Instanciation du module UART_TX
    UART_TX_inst : entity work.UART_TX_YD
        port map (
            Clk => Clk,
            Reset => Reset,
            LD => LD_Auto,
            Din => Din,
            Tick => Tick,
            Tx_Busy => Tx_Busy,
            Tx => Tx
        );

    -- Processus pour générer LD_Auto toutes les 1 seconde si LD n'est pas activé
    process(Clk, Reset)
    begin
        if rising_edge(Clk) then
            -- Incrémentation du compteur pour atteindre 1 seconde
            if Tick = '1' then
                if Counter = 8000000 / 434 - 1 then -- 50 MHz / Tick frequency
                    Counter <= (others => '0');
                    LD_Auto <= '1'; -- Générer un signal LD pendant un Tick
                else
                    Counter <= Counter + 1;
                    LD_Auto <= '0'; -- LD_Auto revient à 0
                end if;
            end if;
        end if;
    end process;
end architecture;

-- Code assemblé de Yann Douze et GPT modifié
