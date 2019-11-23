------------------------------------------------------------------------------
-- repeated-subtraction (iterative)
-- 
-- returns quo and rmn after a max. of 2^N clock cycles
-- if den=0, returns quo=0 and rmn=0 after one clock cycle
------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity div is
  generic (
    N : positive := 10                    -- bit vector length
  );
  port (
    clk   : in  std_ulogic;               -- clock
    rst_n : in  std_ulogic;               -- reset, active low
    start : in  std_ulogic;               -- division start pulse
    num   : in  unsigned(N-1 downto 0);   -- numerator, N bits
    den   : in  unsigned(N-1 downto 0);   -- denominator, N bits
    quo   : out unsigned(N-1 downto 0);   -- quotient, N bits
    rmn   : out unsigned(N-1 downto 0);   -- remainder, N bits
    done  : out std_ulogic                -- division done pulse
  );
end entity div;

architecture rtl of div is

  type t_div is record
    num  : unsigned(N-1 downto 0);
    den  : unsigned(N-1 downto 0);
    quo  : unsigned(N-1 downto 0);
    done : std_ulogic;
  end record t_div;

  -- one iteration of the repeated-subtraction
  function f_div (
    div_arg : t_div
  ) return t_div is
    variable res : t_div;
  begin
    res := div_arg;

    if (res.num >= res.den and res.den /= to_unsigned(0, N)) then
      res.num := res.num - res.den;
      res.quo := res.quo + 1;
    else
      res.done := '1';
    end if;

    if (res.den = to_unsigned(0, N)) then
      res.num := (others => '0');
    end if;

    return res;
  end function f_div;

  signal div_comb : t_div;
  signal div_reg  : t_div;

  signal first_start : std_ulogic;

begin

  -- Combinational Processes
  p_comb : process (all)
  begin
    div_comb <= f_div(div_reg);
  end process p_comb;

  -- Registered Processes
  p_reg : process (clk, rst_n)
  begin
    if (rst_n = '0') then
      first_start <= '0';
      div_reg <= ((others => '0'), (others => '0'), (others => '0'), '0');
    elsif (rising_edge(clk)) then
      if (first_start = '1') then
        div_reg <= div_comb;
      end if;

      if (start = '1') then
        first_start <= '1';
        div_reg <= (num, den, (others => '0'), '0');
      end if;
    end if;
  end process p_reg;

  -- Concurrent Assignments
  quo <= div_reg.quo;
  rmn <= div_reg.num;
  done <= div_reg.done;

end architecture rtl;
