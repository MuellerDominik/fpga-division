------------------------------------------------------------------------------
-- srt division (iterative)
-- 
-- returns quo and rmn after N clock cycles
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
    den  : unsigned(N-1 downto 0);
    quo  : unsigned(N-1 downto 0);
    rmn  : unsigned(N-1 downto 0);
    p    : unsigned(2*N downto 0);    -- 2*N + 1 bit long, (N-1 downto 0) = ap
    an   : unsigned(N-1 downto 0);    -- N bit long
    iter : integer range 0 to N;      -- N iterations + 1 (stop appropriately)
    k    : integer range 0 to N-1;    -- k leading zeros
    done : std_ulogic;
  end record t_div;

  -- select function
  function f_sel (
    div_parm : t_div
  ) return t_div is
    variable res : t_div;
  begin
    res := div_parm;

    c_sel : case res.p(2*N downto 2*N - 2) is
      -- leading three bits of p equal
      when "000" | "111" =>
        res.p := res.p(2*N - 1 downto 0) & '0';
        res.an := res.an(N-2 downto 0) & '0';

      -- leading three bits of p unequal, p negative
      when "100" | "101" | "110" =>
        res.p := res.p(2*N - 1 downto 0) & '0';
        res.an := res.an(N-2 downto 0) & '1';
        res.p(2*N downto N) := res.p(2*N downto N) + ('0' & res.den);

      -- leading three bits of p unequal, p positive
      when others =>  -- "001" | "010" | "011"
        res.p := res.p(2*N - 1 downto 0) & '1';
        res.an := res.an(N-2 downto 0) & '0';
        res.p(2*N downto N) := res.p(2*N downto N) - ('0' & res.den);
    end case c_sel;

    return res;
  end function f_sel;

  -- one iteration of the srt division
  function f_div (
    div_parm : t_div
  ) return t_div is
    variable res : t_div;
    constant c_i : integer := N-1;  -- N iterations (0 to N-1)
  begin
    res := div_parm;

    -- if den=0, directly return quo=0 and rmn=0
    if (res.den = to_unsigned(0, N)) then
      res.done := '1';
      return res;
    end if;

    -- prevent further iterations after N+1 iterations
    if (res.iter = N) then
      return res;
    end if;

    c_iteration : case res.iter is
      -- remove leading zeros by shifting k times to the left,
      -- first iteration 0 of N iterations
      when 0 =>
        -- get rid of leading zeros
        l_rem_lead_zer : for k in N-2 downto 0 loop
          if (res.den(N-1) /= '1') then
            res.den := res.den(N-2 downto 0) & '0';
            res.p := res.p(2*N - 1 downto 0) & '0';
            res.k := res.k + 1;
          else
            exit;
          end if;
        end loop l_rem_lead_zer;

        -- first iteration 0
        res := f_sel(res);
        res.iter := res.iter + 1;

      -- final iteration N and computation of quo and rmn
      when c_i =>
        res := f_sel(res);

        -- compute quo (ap - an)
        res.quo := res.p(N-1 downto 0) - res.an;

        -- if rmn is negative, correct rmn and quo
        if (res.p(2*N) = '1') then
          res.p(2*N downto N) := res.p(2*N downto N) + ('0' & res.den);
          res.quo := res.quo - 1;
        end if;

        -- shift rmn k bits right (undo initial step)
        res.rmn := resize(shift_right(res.p(2*N downto N), res.k), N);

        -- division done
        res.done := '1';

        -- prevent further iterations (iter = N)
        res.iter := res.iter + 1;

      -- iteration iter (1 to N-1)
      when others =>
        res := f_sel(res);
        res.iter := res.iter + 1;
    end case c_iteration;

    return res;
  end function f_div;

  signal div_comb : t_div;
  signal div_reg  : t_div;

  -- prevent calculation after reset
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
      div_reg <= (den  => (others => '0'),
                  quo  => (others => '0'),
                  rmn  => (others => '0'),
                  p    => (others => '0'),
                  an   => (others => '0'),
                  iter => 0, k => 0,
                  done => '0');
    elsif (rising_edge(clk)) then
      -- prevent calculation after reset
      if (first_start = '1') then
        div_reg <= div_comb;
      end if;

      if (start = '1') then
        first_start <= '1';
        div_reg <= (den  => den,
                    quo  => (others => '0'),
                    rmn  => (others => '0'),
                    p    => resize(num, 2*N + 1),
                    an   => (others => '0'),
                    iter => 0, k => 0,
                    done => '0');
      end if;
    end if;
  end process p_reg;

  -- Concurrent Assignments
  quo <= div_reg.quo;
  rmn <= div_reg.rmn;
  done <= div_reg.done;

end architecture rtl;
