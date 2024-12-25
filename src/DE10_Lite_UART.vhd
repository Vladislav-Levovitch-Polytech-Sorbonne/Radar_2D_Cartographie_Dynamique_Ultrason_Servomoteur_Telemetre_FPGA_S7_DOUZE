library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DE10_Lite_UART is
    port 
    (
        Clk      : in std_logic;                     -- Horloge principale
        Reset_n  : in std_logic;                     -- Reset actif bas

        Load     : in std_logic_vector(31 downto 0); -- IO WRite + 0 Signal de chargement
        Ascii    : in std_logic_vector(31 downto 0); -- IO WRite + 1 Donnee ASCii a transmettre
        Uart_Rx  : in std_logic;                     -- Entree UART rx

        Rx_Data  : out std_logic_vector(31 downto 0);-- IO ReaD Lecture data transmise
        Uart_Tx  : out std_logic                     -- Sortie UART tx
    );
end entity;

architecture Behavioral of DE10_Lite_UART is

    -- Etats des FSM = Machines a etats
    type StateType_TX is (Waiting_step, Wait_Release, Load_Reg, Start_Bit, Send_Bits, Stop_Bit);
    type StateType_RX is (Waiting_Start_Bit, Load_Data, Check_Stop_Bit, Refresh_Data ); -- On pourrait mettre State_error si on commence la lecture ailleurs qu en attente de 0 ( si on lit un 0 alors qu on devait etre en 1 par exemple ) ou encore si les transitions de l entree sont pas de periode T_Tick standard
    signal SIGNAL_Etape        : StateType_TX := Waiting_step;
    signal SIGNAL_Etape_Lecture: StateType_RX := Waiting_Start_Bit;

    -- Registre interne pour les donnees
    signal SIGNAL_Data_Reg     : std_logic_vector(9 downto 0) := (others => '0'); -- 1 bit start, 8 bits data, 1 bit stop
    signal SIGNAL_Bit_Index_Tx : integer range 0 to 9 := 0; -- Index des bits en cours d envoi
    signal SIGNAL_Bit_Index_Rx : integer range 0 to 9 := 0; -- Index des bits en cours de lecture
    signal SIGNAL_Load_Save    : std_logic := '0';          -- Recopie de Load

    -- SIGNAL_Tick interne pour la gestion du timing
    constant DIV_FACTOR : integer := 434; -- Division pour une horloge de 50 MHz et un baud rate de 115200
    signal SIGNAL_Counter      : unsigned(13 downto 0) := (others => '0'); -- Compteur pour le diviseur
    signal SIGNAL_Tick         : std_logic := '0'; -- Signal Tick

    -- Copie locale de la donnee
    signal SIGNAL_Data_Tx   : std_logic_vector(7 downto 0) := (others => '0');
    -- Sauvegarde courrante de la donnee a charger en lecture
    signal SIGNAL_Data_Rx   : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- Diviseur d horloge pour generer le signal Tick
    process (Clk, Reset_n)
    begin
        if Reset_n = '0' then
            SIGNAL_Counter <= (others => '0');
            SIGNAL_Tick <= '0';
        elsif rising_edge(Clk) then
            if SIGNAL_Counter = DIV_FACTOR - 1 then
                SIGNAL_Counter <= (others => '0');
                SIGNAL_Tick <= '1';
            else
                SIGNAL_Counter <= SIGNAL_Counter + 1;
                SIGNAL_Tick <= '0';
            end if;
        end if;
    end process;

    -- Copie de la donnee lors d un reset inactif
    process (Clk, Reset_n)
    begin
        if Reset_n = '0' then
            SIGNAL_Data_Tx<= (others => '0');
        elsif rising_edge(Clk) then
            if Load(0) = '1' then
                SIGNAL_Data_Tx<= Ascii(7 downto 0);
                SIGNAL_Load_Save <= '1';
            else 
                SIGNAL_Load_Save <= '0';
            end if;
        end if;
    end process;

    -- Double FSM pour gerer la transmission UART
    process (Clk, Reset_n)
    begin
        if Reset_n = '0' then
            SIGNAL_Etape <= Waiting_step;
            SIGNAL_Etape_Lecture <= Waiting_Start_Bit;
            SIGNAL_Data_Reg <= (others => '0');
            Rx_Data <= (others => '0');
            SIGNAL_Bit_Index_Tx <= 0;
            SIGNAL_Bit_Index_Rx <= 0;
            SIGNAL_Data_Rx <= (others => '0');
            Uart_Tx <= '1';
        elsif rising_edge(Clk) then
            if SIGNAL_Tick = '1' then
                if SIGNAL_Load_Save = '1' or SIGNAL_Etape /= Waiting_step then
                    case SIGNAL_Etape is
                        when Waiting_step =>
                            -- Transition uniquement si Load est actif
                            if SIGNAL_Load_Save = '1' then
                                SIGNAL_Etape <= Load_Reg;
                            end if;
                            -- Reset de la lecture
                            SIGNAL_Etape_Lecture <= Waiting_Start_Bit;

                        when Load_Reg =>
                            -- Charger les donnees et passer a l envoi
                            SIGNAL_Data_Reg <= '1' & SIGNAL_Data_Tx& '0'; -- Ajout des bits start et stop
                            SIGNAL_Bit_Index_Tx <= 0;
                            SIGNAL_Etape <= Start_Bit;

                        when Start_Bit =>
                            -- Envoi du bit de start
                            Uart_Tx <= SIGNAL_Data_Reg(SIGNAL_Bit_Index_Tx);
                            SIGNAL_Bit_Index_Tx <= SIGNAL_Bit_Index_Tx + 1;
                            SIGNAL_Etape <= Send_Bits;

                        when Send_Bits =>
                            -- Envoi des bits data
                            Uart_Tx <= SIGNAL_Data_Reg(SIGNAL_Bit_Index_Tx);
                            if SIGNAL_Bit_Index_Tx = 8 then
                                SIGNAL_Etape <= Stop_Bit;
                            else
                                SIGNAL_Bit_Index_Tx <= SIGNAL_Bit_Index_Tx + 1;
                            end if;

                        when Stop_Bit =>
                            -- Envoi du bit de stop et transition vers l attente de la liberation de Load
                            Uart_Tx <= '1';
                            SIGNAL_Etape <= Wait_Release;

                        when Wait_Release =>
                            -- Attendre que Load retombe a '0'
                            if SIGNAL_Load_Save = '0' then
                                SIGNAL_Etape <= Waiting_step;
                            end if;

                        when others =>
                            SIGNAL_Etape <= Waiting_step;
                    end case;

                -- Transmission prioritaire sur lecture 
                else 
                    case SIGNAL_Etape_Lecture is
                        when Waiting_Start_Bit =>
                            -- Transition uniquement si le bit de start a ete detecte
                            if Uart_Rx = '0' then
                                SIGNAL_Etape_Lecture <= Load_Data;
                                SIGNAL_Bit_Index_Rx <= 0;
                            end if;
                        
                        when Load_Data =>
                            -- Chargement des donnees
                            if SIGNAL_Bit_Index_Rx = 8 then
                                SIGNAL_Etape_Lecture <= Check_Stop_Bit;
                            else
                                SIGNAL_Data_Rx(SIGNAL_Bit_Index_Rx) <= Uart_Rx;
                                SIGNAL_Bit_Index_Rx <= SIGNAL_Bit_Index_Rx + 1;
                            end if;
                        
                        when Check_Stop_Bit =>
                            -- Transition uniquement si le bit de stop a ete detecte
                            if Uart_Rx = '1' then
                                SIGNAL_Etape_Lecture <= Refresh_Data;
                                Rx_Data (7 downto 0) <= SIGNAL_Data_Rx; -- Copie uniquement si la trame est conforme, entier Start data Stop inclu
                                SIGNAL_Data_Rx <= (others => '0'); -- Reset de la sauvegarde
                            end if;
                            
                        when Refresh_Data => -- Tempo pas utile sauf si on veut ajouter un bit de parite ou autre bit de stop /!\ peut etre problematique si l on envoi directement la prochaine lecture
                            SIGNAL_Etape_Lecture <= Waiting_Start_Bit;

                        when others =>
                            SIGNAL_Etape_Lecture <= Waiting_Start_Bit;
                    end case;
                end if;
            end if;
        end if;
    end process;

end architecture;

-- Code based on UART Yann DOUZE and gpt