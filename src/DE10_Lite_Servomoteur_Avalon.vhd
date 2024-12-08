Library ieee;
Use     ieee.std_logic_1164.all;
Use     ieee.numeric_std.all;

Entity DE10_Lite_Servomoteur_Avalon Is Port (
      -- Host Side
      clk         : In    std_logic;                       -- 50MHz
      reset_n     : In    std_logic;                       -- Reset in low state
      chipselect  : In    std_logic;      -- Avalon CS
      write_n     : In    std_logic;      -- Avalon WE (NOT)
      WriteData   : In    std_logic_vector(15 downto 0);   -- Position in 0.1°  

      -- Telemetre Output Datas
      commande    : Out   std_logic                        -- Command Servomotor 
    );
End Entity;

Architecture RTL of DE10_Lite_Servomoteur_Avalon Is

-- Signal
Signal T_SIGNAL_counter         : integer := 0; -- Clock Counter until 20ms
Signal T_SIGNAL_position_EN     : std_logic_vector(15 downto 0) := ( others => '0' );

Begin

-- Content

Process( reset_n, chipselect, Clk )
Begin
    If ( reset_n = '0' ) Then
      T_SIGNAL_position_EN <= ( others => '0' );
    ElsIf Rising_Edge( clk ) Then
        If ( write_n = '0' and chipselect = '1' ) Then
          T_SIGNAL_position_EN <= WriteData; -- MAJ position
        End If;
    End If;
End Process;

Process( reset_n, Clk )
begin
    If ( reset_n = '0') Then
      T_SIGNAL_counter  <=  0;
      commande          <= '0';

    ElsIf Rising_Edge( Clk ) Then
      -- echo_r <= echo; 
      -- echo_rr <= echo_r; 
      If ( T_SIGNAL_counter < 1_000_000 ) Then  -- Full periode is 20ms = 20ns * 1 ooo ooo
          T_SIGNAL_counter <= T_SIGNAL_counter + 1;

          If ( (to_integer (unsigned(WriteData))) > 900 ) Then -- If user ask more than 900 * 0,1 ° => uptade position to max periode (90,0°)
            If ( T_SIGNAL_counter < 100_000) Then -- 20ns * 100_000 = 2ms
            commande <= '1';
            Else
            commande <= '0';
            End If;

          Else 
            If ( T_SIGNAL_counter < (50_000 +(to_integer (unsigned(WriteData)))*55 )) Then
            commande <= '1';
            Else
            commande <= '0';
            End If;
          End If;
      Else
      T_SIGNAL_counter <= 0;
      End If;
    End if;
  End Process;
End Architecture;