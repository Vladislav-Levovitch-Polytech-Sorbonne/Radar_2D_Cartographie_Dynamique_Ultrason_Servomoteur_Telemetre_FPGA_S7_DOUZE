library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DE10_Lite_UART_tx_YD is
    port (
        Clk      : in std_logic;                    -- Horloge principale
        Reset_n  : in std_logic;                    -- Reset actif bas
        Load     : in std_logic;                    -- Signal de chargement
        Ascii    : in std_logic_vector(7 downto 0); -- Donnée ASCII à transmettre
        Uart_Tx  : out std_logic                    -- Sortie UART tx
    );
end entity;

architecture Behavioral of DE10_Lite_UART_tx_YD is
    -- Etats du FSM
    type StateType is (Waiting_step, Wait_Release, Load_Reg, Start_Bit, Send_Bits, Stop_Bit);
    signal SIGNAL_Etape        : StateType := Waiting_step;

    -- Registre interne pour les données
    signal SIGNAL_Data_Reg     : std_logic_vector(9 downto 0) := (others => '0'); -- 1 bit start, 8 bits data, 1 bit stop
    signal Bit_Index           : integer range 0 to 9 := 0; -- Index des bits en cours d'envoi

    -- SIGNAL_Tick interne pour la gestion du timing
    constant DIV_FACTOR : integer := 434; -- Division pour une horloge de 50 MHz et un baud rate de 115200
    signal SIGNAL_Counter      : unsigned(13 downto 0) := (others => '0'); -- Compteur pour le diviseur
    signal SIGNAL_Tick         : std_logic := '0'; -- Signal Tick

    -- Copie locale de la donnée
    signal SIGNAL_Data    : std_logic_vector(7 downto 0) := (others => '0');
begin

    -- Diviseur d'horloge pour générer le signal Tick
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

    -- Copie de la donnée lors d'un reset inactif
    process (Clk, Reset_n)
    begin
        if Reset_n = '0' then
            SIGNAL_Data <= (others => '0');
        elsif rising_edge(Clk) then
            if Load = '1' then
                SIGNAL_Data <= Ascii;
            end if;
        end if;
    end process;

    -- FSM pour gérer la transmission UART
    process (Clk, Reset_n)
    begin
        if Reset_n = '0' then
            SIGNAL_Etape <= Waiting_step;
            SIGNAL_Data_Reg <= (others => '0');
            Bit_Index <= 0;
            Uart_Tx <= '1';
        elsif rising_edge(Clk) then
            if SIGNAL_Tick = '1' then
                case SIGNAL_Etape is
                    when Waiting_step =>
                        -- Transition uniquement si Load est actif
                        if Load = '1' then
                            SIGNAL_Etape <= Load_Reg;
                        end if;

                    when Load_Reg =>
                        -- Charger les données et passer à l'envoi
                        SIGNAL_Data_Reg <= '1' & SIGNAL_Data & '0'; -- Ajout des bits start et stop
                        Bit_Index <= 0;
                        SIGNAL_Etape <= Start_Bit;

                    when Start_Bit =>
                        -- Envoi du bit de start
                        Uart_Tx <= SIGNAL_Data_Reg(Bit_Index);
                        Bit_Index <= Bit_Index + 1;
                        SIGNAL_Etape <= Send_Bits;

                    when Send_Bits =>
                        -- Envoi des bits data
                        Uart_Tx <= SIGNAL_Data_Reg(Bit_Index);
                        if Bit_Index = 8 then
                            SIGNAL_Etape <= Stop_Bit;
                        else
                            Bit_Index <= Bit_Index + 1;
                        end if;

                    when Stop_Bit =>
                        -- Envoi du bit de stop et transition vers l'attente de la libération de Load
                        Uart_Tx <= '1';
                        SIGNAL_Etape <= Wait_Release;

                    when Wait_Release =>
                        -- Attendre que Load retombe à '0'
                        if Load = '0' then
                            SIGNAL_Etape <= Waiting_step;
                        end if;

                    when others =>
                        SIGNAL_Etape <= Waiting_step;
                end case;
            end if;
        end if;
    end process;

end architecture;

-- Code based on Yann DOUZE and gpt adapted