library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_50MHz_Alone is
    port (
        clk         : in  std_logic;       -- horloge Version Alone 50 MHz
        reset_n     : in  std_logic;       -- reset actif bas
        nb_led      : in  std_logic_vector(7 downto 0);

        commande    : out std_logic        -- signal WS2812
    );
end entity;

architecture RTL of DE10_Lite_Neopixel_50MHz_Alone is

-- Signals
    -- Donnees initiales pour tester les LEDs GRB
    signal Couleur_0   : std_logic_vector(23 downto 0) := "000101111111111101000100";  -- Couleur 0 : Rose Baiser
    signal Couleur_1   : std_logic_vector(23 downto 0) := "011111111111111100000000";  -- Couleur 1 : Orange 
    signal Couleur_2   : std_logic_vector(23 downto 0) := "110000101000101101001010";  -- Couleur 2 : Vert Pomme
    signal Couleur_3   : std_logic_vector(23 downto 0) := "111111111111111111111111";  -- Couleur 3 : Blanc
    signal Couleur_4   : std_logic_vector(23 downto 0) := "111111110000000011111111";  -- Couleur 4 : Cyan
    signal Couleur_5   : std_logic_vector(23 downto 0) := "111111111111111100000000";  -- Couleur 5 : Jaune

    signal N_SIGNAL_bit_counter : std_logic_vector(4 downto 0)  := (others => '0');  -- Compteur pour les bits (0 a 24)
    signal N_SIGNAL_led_index   : std_logic_vector(3 downto 0)  := (others => '0');  -- Index des LEDs (0, 1, 2)
    signal N_SIGNAL_timer       : std_logic_vector(15 downto 0) := (others => '0');  -- Compteur pour les cycles
    signal N_SIGNAL_state       : std_logic := '0';                        -- Etat FSM (0 = haut, 1 = bas)
    signal N_SIGNAL_reset_done  : std_logic := '0';                        -- Reset termine
    signal N_SIGNAL_current_bit : std_logic := '0';                        -- Bit actuel en cours de transmission
    signal N_SIGNAL_current_led : std_logic_vector(3 downto 0)  := (others => '0');

    signal N_SIGNAL_led_nb : std_logic_vector(7 downto 0) := (others => '0');

    signal N_SIGNAL_data        : std_logic_vector(23 downto 0);           -- Donnees pour LED en cours

begin

-- Content

process(clk, reset_n)
begin
    if reset_n = '0' then
        N_SIGNAL_current_bit  <= '0';
        N_SIGNAL_timer        <= (others => '0');
        N_SIGNAL_bit_counter  <= (others => '0');
        N_SIGNAL_led_index    <= "0000";
        N_SIGNAL_state        <= '0';
        N_SIGNAL_reset_done   <= '0';
        N_SIGNAL_data         <= (others => '0');
        commande <= '0';
    elsif rising_edge(clk) and reset_n = '1' then
        -- Selection des donnees en fonction de l index des LEDs
        case N_SIGNAL_led_index is
            when "0000" => N_SIGNAL_data <= Couleur_2;      -- Led 0 to 4 Bleu_Green
            when "0001" => N_SIGNAL_data <= Couleur_2;      -- Led 0 to 4 Bleu_Green
            when "0010" => N_SIGNAL_data <= Couleur_2;      -- Led 0 to 4 Bleu_Green
            when "0011" => N_SIGNAL_data <= Couleur_2;      -- Led 0 to 4 Bleu_Green
            when "0100" => N_SIGNAL_data <= Couleur_2;      -- Led 0 to 4 Bleu_Green
            when "0101" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "0110" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "0111" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "1000" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "1001" => N_SIGNAL_data <= Couleur_0;      -- Led 9 to 10 Pink
            when "1010" => N_SIGNAL_data <= Couleur_0;      -- Led 9 to 10 Pink

            when others => N_SIGNAL_data <= (others => '1'); -- Led else ( 11 ) white
        end case;

        -- Securite Maj apres pause
        if N_SIGNAL_reset_done = '0' then
            -- Masque AND 4 bits pour N_SIGNAL_led_nb
            N_SIGNAL_led_nb <= nb_led and "00001111";

            -- Verifier si N_SIGNAL_led_nb > 12
            if unsigned(N_SIGNAL_led_nb) > 12 then
                N_SIGNAL_led_nb <= "00001100";
            end if;
        end if;

        -- gestion du reset
        if N_SIGNAL_reset_done = '0' then
            if unsigned(N_SIGNAL_timer) < "0000100111000100" then -- Reset = 50 us soit 10 ooo cycles Clk_50_MHz 
                N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                commande <= '0';  -- maintenir le reset
            else
                N_SIGNAL_timer <= (others => '0');
                N_SIGNAL_reset_done <= '1';  -- le reset est termine
            end if;

        else
            -- transmission des donnees
            if N_SIGNAL_state = '0' then
                -- etat haut
                if N_SIGNAL_current_bit = '1' then
                    -- bit "1"
                    if unsigned(N_SIGNAL_timer) <= "00100011" then -- T1H = 7oo ns soit 140 cycles Clk_50_MHz 
                        commande <= '1';
                        N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                    else
                        N_SIGNAL_state <= '1';  -- passer a l etat bas
                        N_SIGNAL_timer <= (others => '0');
                    end if;
                else
                    -- bit "0"
                    if unsigned(N_SIGNAL_timer) <= "00010001" then -- T0H = 350 ns soit 70 cycles Clk_50_MHz 
                        commande <= '1';
                        N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                    else
                        N_SIGNAL_state <= '1';  -- passer a l etat bas
                        N_SIGNAL_timer <= (others => '0');
                    end if;
                end if;

            else
                -- etat bas
                if N_SIGNAL_current_bit = '1' then
                    -- bit "1"
                    if unsigned(N_SIGNAL_timer) <= "00011110" then -- T1L = 6oo ns soit 120 cycles Clk_50_MHz
                        commande <= '0';
                        N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                    else
                        N_SIGNAL_state <= '0';  -- retourner a l etat haut
                        N_SIGNAL_timer <= (others => '0');
                        N_SIGNAL_bit_counter <= std_logic_vector(unsigned(N_SIGNAL_bit_counter) + 1);
                    end if;
                else
                    -- bit "0"
                    if unsigned(N_SIGNAL_timer) <= "00101000" then -- T0L = 8oo ns soit 160 cycles Clk_50_MHz 
                        commande <= '0';
                        N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                    else
                        N_SIGNAL_state <= '0';  -- retourner a l etat haut
                        N_SIGNAL_timer <= (others => '0');
                        N_SIGNAL_bit_counter <= std_logic_vector(unsigned(N_SIGNAL_bit_counter) + 1);
                    end if;
                end if;
            end if;

            -- mise a jour du bit et de l index LED
            if unsigned(N_SIGNAL_bit_counter) < 24 then
                N_SIGNAL_current_bit <= N_SIGNAL_data(23 - to_integer(unsigned(N_SIGNAL_bit_counter)));
            else
                N_SIGNAL_bit_counter <= (others => '0');
                if unsigned(N_SIGNAL_current_led) < unsigned(N_SIGNAL_led_nb) then
                    N_SIGNAL_current_led <= std_logic_vector(unsigned(N_SIGNAL_current_led) + 1);
                    N_SIGNAL_led_index   <= std_logic_vector(unsigned(N_SIGNAL_led_index) + 1);     -- Redondant mais pourquoi pas subdiviser en deux le presque meme parametre
                else
                    N_SIGNAL_led_index   <= (others => '0');
                    N_SIGNAL_current_led <= (others => '0');
                    N_SIGNAL_reset_done  <= '0';  -- redemarrer avec le reset
                end if;
            end if;
        end if;
    end if;
end process;

end architecture;
-- Co ecrit avec Chat GPT pour aide a la comprehension du neopixel
-- Participation avec Ayoub LADJiCi et Daniel FERREIRA LARA