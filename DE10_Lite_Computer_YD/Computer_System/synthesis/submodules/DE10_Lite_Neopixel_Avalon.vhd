library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_Avalon is
    port (
        clk         : in  std_logic;       -- horloge 100 MHz
        reset_n     : in  std_logic;       -- reset actif bas
        chipselect  : In  std_logic;       -- Avalon CS
        write_n     : In  std_logic;       -- Avalon WE (NOT)
        WriteData   : In  std_logic_vector(31 downto 0);    -- Nb leds to turn ON  

        commande    : out std_logic        -- signal WS2812
    );
end entity;

architecture RTL of DE10_Lite_Neopixel_Avalon is
-- Signals
    -- Donnees initiales pour tester les LEDs GRB
    signal Couleur_0   : std_logic_vector(23 downto 0) := "000101111111111101000100";  -- Couleur 0 : Rose Baiser
    signal Couleur_1   : std_logic_vector(23 downto 0) := "011111111111111100000000";  -- Couleur 1 : Orange 
    signal Couleur_2   : std_logic_vector(23 downto 0) := "110000101000101101001010";  -- Couleur 2 : Vert Pomme
    signal Couleur_3   : std_logic_vector(23 downto 0) := "111111111111111111111111";  -- Couleur 3 : Blanc
    signal Couleur_4   : std_logic_vector(23 downto 0) := "111111110000000011111111";  -- Couleur 4 : Cyan
    signal Couleur_5   : std_logic_vector(23 downto 0) := "111111111111111100000000";  -- Couleur 5 : Jaune
    signal Couleur_X   : std_logic_vector(23 downto 0) := "000000000000000000000000";  -- Couleur X : Reset Noir

    signal N_SIGNAL_bit_counter : std_logic_vector(4 downto 0)  := (others => '0');  -- Compteur pour les bits (0 a 24)
    signal N_SIGNAL_led_index   : std_logic_vector(3 downto 0)  := (others => '0');  -- Index des LEDs (0, 1, 2)
    signal N_SIGNAL_timer       : std_logic_vector(15 downto 0) := (others => '0');  -- Compteur pour les cycles
    signal N_SIGNAL_state       : std_logic := '0';                        -- Etat FSM (0 = haut, 1 = bas)
    signal N_SIGNAL_reset_done  : std_logic := '0';                        -- Reset termine
    signal N_SIGNAL_current_bit : std_logic := '0';                        -- Bit actuel en cours de transmission
    signal N_SIGNAL_current_led : std_logic_vector(3 downto 0)  := "0000";

    signal N_SIGNAL_led_nb      : std_logic_vector(31 downto 0) := (others => '0');
    signal N_SIGNAL_led_bis     : std_logic_vector(31 downto 0) := (others => '0');

    signal N_SIGNAL_data        : std_logic_vector(23 downto 0);           -- Donnees pour LED en cours

begin

-- Content

Process( reset_n, chipselect, Clk )
Begin
    If ( reset_n = '0' ) Then
        N_SIGNAL_led_bis <= ( others => '0' );
    ElsIf Rising_Edge( clk ) Then
        If ( write_n = '0' and chipselect = '1' ) Then
            N_SIGNAL_led_bis <= WriteData; -- MAJ nb_led_stockage
        End If;
    End If;
End Process;

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
        N_SIGNAL_current_led  <= "0000";
        commande <= '0';
    elsif rising_edge(clk) and reset_n = '1' then
        -- Selection des donnees en fonction de l index des LEDs
        case N_SIGNAL_led_index is
            when "0000" | "0001" | "0010" | "0011" | "0100" => N_SIGNAL_data <= Couleur_2;  -- Led 0 to 4 Bleu_Green
            when "0101" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "0110" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "0111" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "1000" => N_SIGNAL_data <= Couleur_1;      -- Led 5 to 8 Orange
            when "1001" => N_SIGNAL_data <= Couleur_0;      -- Led 9 to 10 Pink
            when "1010" => N_SIGNAL_data <= Couleur_0;      -- Led 9 to 10 Pink

				when "1110" => N_SIGNAL_data <= "000000001111111100000000"; -- Red leds New clean
            when "1111" => N_SIGNAL_data <= Couleur_X;       -- Cleaning leds
            when others => N_SIGNAL_data <= (others => '1'); -- Led else ( 11 ) white
        end case;

        -- Securite Maj apres pause
        if N_SIGNAL_reset_done = '0' then
            -- Masque AND 4 bits pour N_SIGNAL_led_nb
            N_SIGNAL_led_nb <= N_SIGNAL_led_bis and "00000000000000000000000000001111";

            -- Verifier si N_SIGNAL_led_nb > 12
            if unsigned(N_SIGNAL_led_nb) > 12 then
                N_SIGNAL_led_nb <= "00000000000000000000000000001100";
            end if;
        end if;

        if N_SIGNAL_led_nb = "00000000000000000000000000000000" then
            N_SIGNAL_data <= Couleur_X;
        end if;

        -- gestion du reset
        if N_SIGNAL_reset_done = '0' then
            if unsigned(N_SIGNAL_timer) < "0001001110001000" then -- Reset = 50 us soit 5 ooo cycles Clk_100_MHz 
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
                    if unsigned(N_SIGNAL_timer) <= "01000110" then -- T1H = 7oo ns soit 70 cycles Clk_100_MHz 
                        commande <= '1';
                        N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                    else
                        N_SIGNAL_state <= '1';  -- passer a l etat bas
                        N_SIGNAL_timer <= (others => '0');
                    end if;
                else
                    -- bit "0"
                    if unsigned(N_SIGNAL_timer) <= "00100011" then -- T0H = 350 ns soit 35 cycles Clk_100_MHz 
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
                    if unsigned(N_SIGNAL_timer) <= "00111100" then -- T1L = 6oo ns soit 60 cycles Clk_100_MHz
                        commande <= '0';
                        N_SIGNAL_timer <= std_logic_vector(unsigned(N_SIGNAL_timer) + 1);
                    else
                        N_SIGNAL_state <= '0';  -- retourner a l etat haut
                        N_SIGNAL_timer <= (others => '0');
                        N_SIGNAL_bit_counter <= std_logic_vector(unsigned(N_SIGNAL_bit_counter) + 1);
                    end if;
                else
                    -- bit "0"
                    if unsigned(N_SIGNAL_timer) <= "01010000" then -- T0L = 8oo ns soit 80 cycles Clk_100_MHz 
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
                if unsigned(N_SIGNAL_current_led) < 11 then
                    N_SIGNAL_current_led <= std_logic_vector(unsigned(N_SIGNAL_current_led) + 1);
                    if unsigned(N_SIGNAL_current_led) + 2 > unsigned(N_SIGNAL_led_nb) then
                        N_SIGNAL_led_index   <= "1110";
                    else
                        N_SIGNAL_led_index   <= std_logic_vector(unsigned(N_SIGNAL_led_index) + 1);
                    end if;
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