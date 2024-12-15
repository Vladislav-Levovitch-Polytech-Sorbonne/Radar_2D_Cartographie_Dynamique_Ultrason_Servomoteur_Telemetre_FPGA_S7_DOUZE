library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_50MHz_Alone_mode is
    port (
        clk         : in  std_logic;       -- horloge Version Alone 50 MHz
        reset_n     : in  std_logic;       -- reset actif bas


        commande    : out std_logic        -- signal WS2812
    );
end entity;

architecture RTL of DE10_Lite_Neopixel_50MHz_Alone_mode is

-- Signals
    -- Donnees initiales pour tester les LEDs GRB
    signal Couleur_0   : std_logic_vector(23 downto 0) := "110101011111111101001111";  -- Couleur 0 : Orange Peche
    signal Couleur_1   : std_logic_vector(23 downto 0) := "111101111101101010100110";  -- Couleur 1 : Vert Pomme
    signal Couleur_2   : std_logic_vector(23 downto 0) := "000101111111111101000100";  -- Couleur 2 : Rose Baiser
    signal Couleur_3   : std_logic_vector(23 downto 0) := "111111111111111111111111";  -- Couleur 3 : Blanc
    signal Couleur_4   : std_logic_vector(23 downto 0) := "111111110000000011111111";  -- Couleur 4 : Cyan
    signal Couleur_5   : std_logic_vector(23 downto 0) := "111111111111111100000000";  -- Couleur 5 : Jaune

    signal bit_counter : std_logic_vector(4 downto 0)  := (others => '0');  -- compteur pour les bits (0 a 24)
    signal led_index   : std_logic_vector(1 downto 0)  := (others => '0');  -- index des LEDs (0, 1, 2)
    signal timer       : std_logic_vector(15 downto 0) := (others => '0');  -- compteur pour les cycles
    signal state       : std_logic := '0';                        -- etat FSM (0 = haut, 1 = bas)
    signal reset_done  : std_logic := '0';                        -- reset termine
    signal current_bit : std_logic := '0';                        -- bit actuel en cours de transmission

    signal data        : std_logic_vector(23 downto 0);           -- donnees pour LED en cours

begin

-- Content
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
            when "00" => data <= Couleur_1;
            when "01" => data <= Couleur_2;
            when "10" => data <= Couleur_0;
            when others => data <= (others => '0');
        end case;

        -- gestion du reset
        if reset_done = '0' then
            if unsigned(timer) < unsigned("0000100111000100") then -- Reset = 50 us soit 10 ooo cycles Clk_50_MHz 
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
                    if unsigned(timer) <= unsigned("00100011") then -- T1H = 7oo ns soit 140 cycles Clk_50_MHz 
                        commande <= '1';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '1';  -- passer a l etat bas
                        timer <= (others => '0');
                    end if;
                else
                    -- bit "0"
                    if unsigned(timer) <= unsigned("00010001") then -- T0H = 350 ns soit 70 cycles Clk_50_MHz 
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
                    if unsigned(timer) <= unsigned("00011110") then -- T1L = 6oo ns soit 120 cycles Clk_50_MHz
                        commande <= '0';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '0';  -- retourner a l etat haut
                        timer <= (others => '0');
                        bit_counter <= std_logic_vector(unsigned(bit_counter) + 1);
                    end if;
                else
                    -- bit "0"
                    if unsigned(timer) <= unsigned("00101000") then -- T0L = 8oo ns soit 160 cycles Clk_50_MHz 
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
-- Co ecrit avec Chat GPT pour aide a la comprehension du neopixel
-- Participation avec Ayoub LADJiCi et Daniel FERREIRA LARA
