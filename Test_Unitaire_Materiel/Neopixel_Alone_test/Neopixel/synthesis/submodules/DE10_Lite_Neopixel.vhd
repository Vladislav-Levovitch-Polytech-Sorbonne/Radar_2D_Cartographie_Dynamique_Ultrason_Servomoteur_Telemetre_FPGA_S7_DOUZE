library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel is
    port (
        clk         : in  std_logic;       -- horloge 100 MHz
        reset_n     : in  std_logic;       -- reset actif bas


        commande    : out std_logic        -- signal WS2812
    );
end entity;

architecture RTL of DE10_Lite_Neopixel is

    -- Constantes pour les timings (basee sur 100 MHz)
    constant T0H_CYCLES : std_logic_vector(7 downto 0) := "00100011";  -- T0H = 0.35us @ 100 MHz (35 cycles)
    constant T0L_CYCLES : std_logic_vector(7 downto 0) := "01010000";  -- T0L = 0.8 us @ 100 MHz (80 cycles)
    constant T1H_CYCLES : std_logic_vector(7 downto 0) := "01000110";  -- T1H = 0.7 us @ 100 MHz (70 cycles)
    constant T1L_CYCLES : std_logic_vector(7 downto 0) := "00111100";  -- T1L = 0.6 us @ 100 MHz (60 cycles)
    constant RESET_CYCLES : std_logic_vector(15 downto 0) := "0001001110001000";  -- Reset = 50 us @ 100 MHz (5000 cycles)

    -- Donnees initiales pour tester les LEDs (GRB)
    signal data_1 : std_logic_vector(23 downto 0) := "111111110000000011111111";  -- LED 1 : Magenta
    signal data_2 : std_logic_vector(23 downto 0) := "111111111111111100000000";  -- LED 2 : Jaune
    signal data_3 : std_logic_vector(23 downto 0) := "111111111111111111111111";  -- LED 3 : Blanc

    -- Signaux internes
    signal bit_counter : std_logic_vector(4 downto 0) := "00000";  -- compteur pour les bits (0 a 24)
    signal led_index   : std_logic_vector(1 downto 0) := "00";     -- index des LEDs (0, 1, 2)
    signal timer       : std_logic_vector(15 downto 0) := (others => '0');  -- compteur pour les cycles
    signal state       : std_logic := '0';                        -- etat FSM (0 = haut, 1 = bas)
    signal reset_done  : std_logic := '0';                        -- reset termine
    signal current_bit : std_logic := '0';                        -- bit actuel en cours de transmission

    signal data        : std_logic_vector(23 downto 0);           -- donnees pour LED en cours

begin

process(clk, reset_n)
begin
    if reset_n = '0' then
        -- reinitialisation des signaux
        timer        <= (others => '0');
        bit_counter  <= (others => '0');
        led_index    <= "00";
        state        <= '0';
        reset_done   <= '0';
        commande     <= '0';

    elsif rising_edge(clk) then
        -- selection des donnees en fonction de l index des LEDs
        case led_index is
            when "00" => data <= data_1;
            when "01" => data <= data_2;
            when "10" => data <= data_3;
            when others => data <= (others => '0');
        end case;

        -- gestion du reset
        if reset_done = '0' then
            if unsigned(timer) < unsigned(RESET_CYCLES) then
                timer <= std_logic_vector(unsigned(timer) + 1);
                commande <= '0';  -- maintenir le reset
            else
                timer <= (others => '0');
                reset_done <= '1';  -- le reset est termine
            end if;

        else
            -- transmission des donnees
            if state = '0' then
                -- etat haut
                if current_bit = '1' then
                    -- bit "1"
                    if unsigned(timer) <= unsigned(T1H_CYCLES) then
                        commande <= '1';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '1';  -- passer a l etat bas
                        timer <= (others => '0');
                    end if;
                else
                    -- bit "0"
                    if unsigned(timer) <= unsigned(T0H_CYCLES) then
                        commande <= '1';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '1';  -- passer a l etat bas
                        timer <= (others => '0');
                    end if;
                end if;

            else
                -- etat bas
                if current_bit = '1' then
                    -- bit "1"
                    if unsigned(timer) <= unsigned(T1L_CYCLES) then
                        commande <= '0';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '0';  -- retourner a l etat haut
                        timer <= (others => '0');
                        bit_counter <= std_logic_vector(unsigned(bit_counter) + 1);
                    end if;
                else
                    -- bit "0"
                    if unsigned(timer) <= unsigned(T0L_CYCLES) then
                        commande <= '0';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '0';  -- retourner a l etat haut
                        timer <= (others => '0');
                        bit_counter <= std_logic_vector(unsigned(bit_counter) + 1);
                    end if;
                end if;
            end if;

            -- mise a jour du bit et de l index LED
            if unsigned(bit_counter) < 24 then
                current_bit <= data(23 - to_integer(unsigned(bit_counter)));
            else
                bit_counter <= (others => '0');
                if unsigned(led_index) < 2 then
                    led_index <= std_logic_vector(unsigned(led_index) + 1);
                else
                    led_index <= "00";
                    reset_done <= '0';  -- redemarrer avec le reset
                end if;
            end if;
        end if;
    end if;
end process;

end architecture;
