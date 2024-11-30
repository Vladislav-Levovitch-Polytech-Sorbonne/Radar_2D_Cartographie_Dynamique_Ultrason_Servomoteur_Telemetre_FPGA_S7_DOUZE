Library ieee;
Use     ieee.std_logic_1164.all;
Use     ieee.numeric_std.all;

Entity DE10_Lite_Telemetre_us_to_cm Is Port (
      -- Host Side
      clk         : In    std_logic;      -- 50MHz
      Rst_n       : In    std_logic;      -- Reset in low state
      echo        : In    std_logic;      -- Echo signal from HC-SR04

      -- Telemetre Output Datas
      trig        : Out   std_logic;      -- Trigger signal for HC-SR04
      Dist_cm     : Out   std_logic_vector(9 downto 0)  -- Measured distance
    );
End Entity;

Architecture RTL of DE10_Lite_Telemetre_us_to_cm Is

-- Signal
Signal T_SIGNAL_trig_counter         : integer := 0; -- Integer 32 bit soit 32 bascules pour chaque integer, tres energivor a borner ou a eviter
Signal T_SIGNAL_echo_sub_counter     : integer := 0; -- Une boucle aurait suffit
Signal T_SIGNAL_echo_super_counter   : integer := 0;
Signal T_SIGNAL_current_mesure       : std_logic := '0';
Signal T_SIGNAL_distance_cm          : integer := 0;
Signal T_SIGNAL_Espacement_trig      : integer := 0;

Begin

-- Content
Process( Rst_n, Clk )
begin
    If ( Rst_n = '0' ) Then
      Dist_cm                    <= ( others => '0' );
      trig                       <= '0';
      T_SIGNAL_current_mesure    <= '0'; -- Sauvegarde etat courant pour calcul final lors du changement d etat
      T_SIGNAL_trig_counter      <= 0;
      T_SIGNAL_echo_sub_counter  <= 0;
      T_SIGNAL_echo_super_counter<= 0;
      T_SIGNAL_distance_cm       <= 0;
      T_SIGNAL_Espacement_trig   <= 0;

    ElsIf Rising_Edge( Clk ) Then
      -- Periode entre trig ( 60 ms minimum )
      If ( T_SIGNAL_Espacement_trig < 3_000_000 ) Then  -- Propose par Chat GPT
        T_SIGNAL_Espacement_trig <= T_SIGNAL_Espacement_trig + 1;

      Else
        -- Generation Trig
        If ( T_SIGNAL_trig_counter < 500 ) Then 
          T_SIGNAL_trig_counter <= T_SIGNAL_trig_counter + 1;
          trig <= '1';
          Dist_cm <= "0000000000";

        Else
          trig <= '0';
          If ( T_SIGNAL_trig_counter >= 500 ) Then
            T_SIGNAL_Espacement_trig <= 0; -- Reinitialiser le compteur de delai
            T_SIGNAL_trig_counter <= 0;
          End If;
        End If;
      End If;

      -- Comptage de la duree de Echo
      If ( echo = '1' ) Then
        T_SIGNAL_current_mesure <= '1';
        If ( T_SIGNAL_echo_sub_counter < 200 ) Then
          T_SIGNAL_echo_sub_counter <= T_SIGNAL_echo_sub_counter + 1;
        Else
          T_SIGNAL_echo_sub_counter <= 0;
          T_SIGNAL_echo_super_counter <= T_SIGNAL_echo_super_counter + 1;
        End If;

      ElsIf ( echo = '0' And T_SIGNAL_current_mesure = '1' ) Then
        T_SIGNAL_current_mesure <= '0';
        -- Calcul de la distance en cm
        T_SIGNAL_distance_cm <= T_SIGNAL_echo_super_counter / 15;
        T_SIGNAL_echo_sub_counter <= 0;
        T_SIGNAL_echo_super_counter <= 0;
      End If;

      -- Conversion pour la sortie
      Dist_cm <= std_logic_vector( to_unsigned ( T_SIGNAL_distance_cm, 10 ) );
    End If;
  End Process;
End Architecture;

-- Co redige avec Chat Generative Pre Trained