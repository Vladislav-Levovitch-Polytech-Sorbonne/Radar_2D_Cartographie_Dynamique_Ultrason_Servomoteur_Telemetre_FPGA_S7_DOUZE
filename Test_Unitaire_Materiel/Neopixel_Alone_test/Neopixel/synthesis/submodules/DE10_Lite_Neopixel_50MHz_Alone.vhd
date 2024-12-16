library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE10_Lite_Neopixel_50MHz_Alone_mode is
    port (
        clk         : in  std_logic;       -- Horloge Version Alone 50 MHz
        reset_n     : in  std_logic;       -- Reset actif bas
        nb_led      : in  std_logic_vector (7 downto 0); -- Nombre de LEDs

        commande    : out std_logic        -- Signal WS2812
    );
end entity;

architecture RTL of DE10_Lite_Neopixel_50MHz_Alone_mode is

-- Signals
    -- Donnees initiales pour tester les LEDs GRB
    signal Couleur_0   : std_logic_vector(23 downto 0) := "110101011111111101001111";  -- Couleur 0 : Orange Peche
    signal Couleur_1   : std_logic_vector(23 downto 0) := "111101111101101010100110";  -- Couleur 1 : Vert Pomme
    signal Couleur_2   : std_logic_vector(23 downto 0) := "000101111111111101000100";  -- Couleur 2 : Rose Baiser
    signal Couleur_3   : std_logic_vector(23 downto 0) := "111111111111111111111111";  -- Couleur 3 : Blanc

    signal bit_counter : std_logic_vector(4 downto 0)  := (others => '0');  -- Compteur pour les bits (0 a 24)
    signal led_index   : std_logic_vector(15 downto 0) := (others => '0');  -- Index des LEDs
    signal timer       : std_logic_vector(15 downto 0) := (others => '0');  -- Compteur pour les cycles
    signal state       : std_logic := '0';                        -- Etat FSM (0 = haut, 1 = bas)
    signal reset_done  : std_logic := '0';                        -- Reset termine
    signal current_bit : std_logic := '0';                        -- Bit actuel en cours de transmission
    signal signal_nb_led      : std_logic_vector (7 downto 0) := (others => '0');

    signal data        : std_logic_vector(23 downto 0);           -- Donnees pour LED en cours

    -- Compteur pour le cycle des couleurs
    signal global_counter : integer := 0;                        -- Compteur global pour les 100 000 000 cycles
    signal current_color_cycle : std_logic_vector(1 downto 0) := "00"; -- Indicateur de couleur impaire

    -- Ajout pour la pause de 50 µs
    signal pause_counter : integer := 0;                        -- Compteur pour la pause de 50 µs
    signal pause_done    : std_logic := '0';                    -- Indique si la pause est terminee

begin

-- Content
process(clk, reset_n, signal_nb_led)
begin
    if reset_n = '0' then
        -- Reinitialisation des signaux
        timer        <= (others => '0');
        bit_counter  <= (others => '0');
        led_index    <= (others => '0');
        state        <= '0';
        reset_done   <= '0';
        commande     <= '0';
        global_counter <= 0;
        current_color_cycle <= "00";
        pause_counter <= 0;
        pause_done <= '0';
        signal_nb_led <= (others => '0');

    elsif rising_edge(clk) then
        -- Increment du compteur global pour alterner les couleurs
        signal_nb_led <= nb_led and "00000111";
        if global_counter = 10000000 then
            global_counter <= 0;
            if current_color_cycle = "00" then
                current_color_cycle <= "01";
            elsif current_color_cycle = "01" then
                current_color_cycle <= "10";
            else
                current_color_cycle <= "00";
            end if;
        else
            global_counter <= global_counter + 1;
        end if;

        -- Gestion de la pause de 50 µs
        if pause_done = '0' then
            if pause_counter < 2500 then  -- 50 µs = 2500 cycles @ 50 MHz
                pause_counter <= pause_counter + 1;
                commande <= '0';  -- Ligne maintenue basse
            else
                pause_counter <= 0;
                pause_done <= '1';  -- Pause terminee
            end if;

        -- Selection des donnees en fonction de l index des LEDs
        elsif reset_done = '0' then
            if unsigned(timer) < "100111000100" then -- Reset = 50 us soit 5000 cycles Clk_50_MHz 
                timer <= std_logic_vector(unsigned(timer) + 1);
                commande <= '0';  -- Maintenir le reset
            else
                timer <= (others => '0');
                reset_done <= '1';  -- Reset termine
            end if;

        else
            -- Selection des donnees en fonction de l index
            if (unsigned(led_index) mod 2) = 0 then
                data <= Couleur_3;  -- LEDs paires : Blanc
            else
                case current_color_cycle is
                    when "00" => data <= Couleur_0;  -- Couleur 0
                    when "01" => data <= Couleur_1;  -- Couleur 1
                    when "10" => data <= Couleur_2;  -- Couleur 2
                    when others => data <= Couleur_3;  -- Blanc par defaut
                end case;
            end if;

            -- Transmission des donnees
            if state = '0' then
                -- Etat haut
                if current_bit = '1' then
                    if unsigned(timer) <= "01000110" then -- T1H = 700 ns soit 35 cycles Clk_50_MHz 
                        commande <= '1';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '1';  -- Passer a l etat bas
                        timer <= (others => '0');
                    end if;
                else
                    if unsigned(timer) <= "00100111" then -- T0H = 350 ns soit 17 cycles Clk_50_MHz 
                        commande <= '1';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '1';  -- Passer a l etat bas
                        timer <= (others => '0');
                    end if;
                end if;

            else
                -- Etat bas
                if current_bit = '1' then
                    if unsigned(timer) <= "01111010" then -- T1L = 600 ns soit 30 cycles Clk_50_MHz
                        commande <= '0';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '0';  -- Retourner a l etat haut
                        timer <= (others => '0');
                        bit_counter <= std_logic_vector(unsigned(bit_counter) + 1);
                    end if;
                else
                    if unsigned(timer) <= "10011100" then -- T0L = 800 ns soit 40 cycles Clk_50_MHz 
                        commande <= '0';
                        timer <= std_logic_vector(unsigned(timer) + 1);
                    else
                        state <= '0';  -- Retourner a l etat haut
                        timer <= (others => '0');
                        bit_counter <= std_logic_vector(unsigned(bit_counter) + 1);
                    end if;
                end if;
            end if;

            -- Translation du bit courant
            if unsigned(bit_counter) < 24 then
                current_bit <= data(23 - to_integer(unsigned(bit_counter)));
            else
                bit_counter <= (others => '0');
                if ((unsigned(led_index) < unsigned(signal_nb_led) - 1) and (unsigned(led_index) < 12)) then
                    led_index <= std_logic_vector(unsigned(led_index) + 1);
                else
                    led_index <= (others => '0');
                    reset_done <= '0';  -- Redemarrer avec le reset
                    pause_done <= '0';  -- Ajouter la pause
                end if;
            end if;
        end if;
    end if;
end process;
end architecture;
-- Co ecrit avec Chat GPT pour aide a la comprehension du neopixel
-- Participation avec Ayoub LADJiCi et Daniel FERREIRA LARA
