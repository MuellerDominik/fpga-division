library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity div_tb is
end entity div_tb;

architecture sim of div_tb is

  constant c_n          : positive := 10;   -- bit vector length

  signal clk   : std_ulogic;                -- clock
  signal rst_n : std_ulogic;                -- reset, active low
  signal start : std_ulogic;                -- division start pulse
  signal num   : unsigned(c_n-1 downto 0);  -- numerator, c_n bits
  signal den   : unsigned(c_n-1 downto 0);  -- denominator, c_n bits
  signal quo   : unsigned(c_n-1 downto 0);  -- quotient, c_n bits
  signal rmn   : unsigned(c_n-1 downto 0);  -- remainder, c_n bits
  signal done  : std_ulogic;                -- division done pulse

begin

  -- Device Under Verification
  duv : entity work.div(rtl)
    generic map (
      N => c_n
    )
    port map (
      clk   => clk,
      rst_n => rst_n,
      start => start,
      num   => num,
      den   => den,
      quo   => quo,
      rmn   => rmn,
      done  => done
    );

  verify_inst : entity work.verify(stim_and_mon)
    generic map (
      N => c_n
    )
    port map (
      quo   => quo,
      rmn   => rmn,
      done  => done,
      clk   => clk,
      rst_n => rst_n,
      start => start,
      num   => num,
      den   => den
    );

end architecture sim;
