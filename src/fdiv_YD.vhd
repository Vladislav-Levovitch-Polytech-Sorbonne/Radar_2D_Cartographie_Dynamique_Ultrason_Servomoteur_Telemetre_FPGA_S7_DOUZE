library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fdiv_YD is
    port (
        Clk       : in std_logic;          -- Horloge d'entrée
        Reset     : in std_logic;          -- Réinitialisation asynchrone
        Tick      : out std_logic;         -- Signal Tick pour UART
        Tick_half : out std_logic          -- Optionnel : Tick à demi-fréquence
    );
end entity;

architecture RTL of fdiv_YD is
    --constant DIV_FACTOR : integer := 868; -- Division pour une fréquence UART standard (par exemple 115200 bauds avec horloge 100 MHz)
    constant DIV_FACTOR : integer := 434; -- Division pour une fréquence UART standard (par exemple 115200 bauds avec horloge 50 MHz)
    --constant DIV_FACTOR : integer := 5208; -- 9600 bauds avec horloge 50 MHz
    --constant DIV_FACTOR : integer := 10417; -- 9600 bauds avec horloge 100 MHz
    signal Counter : unsigned(13 downto 0) := (others => '0'); -- Compteur pour la division
begin

    process (Clk, Reset)
    begin
        if Reset = '1' then
            Counter <= (others => '0');
            Tick <= '0';
            Tick_half <= '0';
        elsif rising_edge(Clk) then
            if Counter = DIV_FACTOR - 1 then
                Counter <= (others => '0'); -- Remise à zéro du compteur
                Tick <= '1';               -- Génération du signal Tick
            else
                Counter <= Counter + 1;
                Tick <= '0';               -- Tick reste à '0'
            end if;

            -- Tick_half est activé au milieu du cycle
            if Counter = (DIV_FACTOR / 2) then
                Tick_half <= '1';
            else
                Tick_half <= '0';
            end if;
        end if;
    end process;

end architecture;

-- Code de Yann Douze 