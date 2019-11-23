library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
library std;
  use std.textio.all;

entity verify is
  generic (
    N : positive := 10                      -- bit vector length
  );
  port (
    quo   : in  unsigned(N-1 downto 0);     -- quotient, N bits
    rmn   : in  unsigned(N-1 downto 0);     -- remainder, N bits
    done  : in  std_ulogic;                 -- division done pulse
    clk   : out std_ulogic;                 -- clock
    rst_n : out std_ulogic;                 -- reset, active low
    start : out std_ulogic;                 -- division start pulse
    num   : out unsigned(N-1 downto 0);     -- numerator, N bits
    den   : out unsigned(N-1 downto 0)      -- denominator, N bits
  );
end entity verify;

architecture stim_and_mon of verify is

  constant c_clk_period : time := 20 ns;    -- clock frequency (50 MHz)

  signal sim_end : boolean := false;

begin

    -- Reset and Clock
    p_rst_clk : process
    begin
      rst_n <= '0', '1' after 20 ns;
      l_clk : while not sim_end loop
        clk <= '0', '1' after c_clk_period/2;
        wait for c_clk_period;
      end loop l_clk;
      wait;
    end process p_rst_clk;

    -- Stimuli
    p_stim : process
      file input_file       : text open read_mode is "./stim/div_stimuli.txt";
      variable v_input_line : line;
      variable v_num        : unsigned(N-1 downto 0);
      variable v_den        : unsigned(N-1 downto 0);
      variable v_quo        : unsigned(N-1 downto 0);
      variable v_rmn        : unsigned(N-1 downto 0);
    begin

      start  <= '0';
      num <= (others => '0');
      den <= (others => '0');
      wait for 40 ns;
      wait until falling_edge(clk);

      l_stim : while not endfile(input_file) loop
        start <= '1', '0' after c_clk_period;

        readline(input_file, v_input_line);
        hread(v_input_line, v_num);
        hread(v_input_line, v_den);
        hread(v_input_line, v_quo);
        hread(v_input_line, v_rmn);

        num <= v_num;
        den <= v_den;
        wait until done;

        assert quo = v_quo report "quo wrong: " & to_string(quo) &
                                  " instead of " & to_string(v_quo) &
                                  " (num=" & to_string(v_num) & ", den=" &
                                  to_string(v_den) & ")" severity error;

        assert rmn = v_rmn report "rmn wrong: " & to_string(rmn) &
                                  " instead of " & to_string(v_rmn) &
                                  " (num=" & to_string(v_num) & ", den=" &
                                  to_string(v_den) & ")" severity error;

        wait until falling_edge(clk);
      end loop l_stim;

      report "simulation done" severity note;
      sim_end <= true;
      wait;

    end process p_stim;

end architecture stim_and_mon;
