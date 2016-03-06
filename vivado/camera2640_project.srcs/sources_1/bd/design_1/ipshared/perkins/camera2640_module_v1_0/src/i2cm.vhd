library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity i2cm is
  port (
    clk     : in    std_logic;
    rstn    : in    std_logic;
    addr    : in    std_logic_vector(6 downto 0);
    wr_reg  : in    std_logic_vector(7 downto 0);
    wr_data : in    std_logic_vector(7 downto 0);
    rd_reg  : in    std_logic_vector(7 downto 0);
    rd_data : out   std_logic_vector(7 downto 0);
    rw      : in    std_logic;
    en      : in    std_logic;
    busy    : out   std_logic;
    sda     : inout std_logic;
    scl     : inout std_logic);
end entity i2cm;

architecture rtl of i2cm is
  constant BASE_CLK_FREQ : integer := 50000000;
  constant I2C_CLK_FREQ  : integer := 100000;
  signal i2c_clk         : std_logic_vector(15 downto 0);
  signal scl_en          : std_logic;
  signal scl_cnt         : integer;
  signal scl_b           : std_logic;
  signal sda_b           : std_logic;
  signal sda_b_cat       : std_logic_vector(23 downto 0);
  signal tx              : std_logic;
begin

  U0_START : process(clk, rstn)
  begin
    if rstn = '0' then
      scl_en <= '0';
    else
      if rising_edge(clk) then
        if scl_cnt = 0 then
          if en = '1' then
            scl_en <= '1';
          end if;
        else
          if scl_cnt > 228 then
            scl_en <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  U1_I2C_CLK : process(clk, rstn)
  begin
    if rstn = '0' then
      i2c_clk <= (others => '0');
      scl_b   <= '1';
      scl_cnt <= 0;
    else
      if rising_edge(clk) then
        if scl_en = '1' then
          if unsigned(i2c_clk) < ((BASE_CLK_FREQ/(I2C_CLK_FREQ*2))-1) then
            i2c_clk <= std_logic_vector(unsigned(i2c_clk) + to_unsigned(1, 16));
          else
            i2c_clk <= (others => '0');
            scl_b   <= not scl_b;
            if scl_b = '1' then
              scl_cnt <= scl_cnt + 1;
            end if;
          end if;
        else
          i2c_clk <= (others => '0');
          scl_b   <= '1';
          scl_cnt <= 0;
        end if;
      end if;
    end if;
  end process;

  U2_SEND_DATA : process(clk, rstn)
  begin
    if rstn = '0' then
      tx        <= '0';
      sda_b     <= '0';
      sda_b_cat <= (others => '0');
      busy      <= '0';
    else
      if rising_edge(clk) then
        case scl_cnt is
          when 0 =>
            tx        <= '1';
            sda_b_cat <= "0" & addr & wr_reg & wr_data;
            sda_b     <= '0';
            busy      <= '0';
          when 1 to 8 =>
            tx        <= '1';
            sda_b_cat <= sda_b_cat;
            sda_b     <= sda_b_cat(24-scl_cnt);
            busy      <= '1';
          when 9 =>
            tx        <= '1';
            sda_b_cat <= sda_b_cat;
            sda_b     <= '0';
            busy      <= '1';
          when 10 to 17 =>
            tx        <= '1';
            sda_b_cat <= sda_b_cat;
            sda_b     <= sda_b_cat(25-scl_cnt);
            busy      <= '1';
          when 18 =>
            tx        <= '1';
            sda_b_cat <= sda_b_cat;
            sda_b     <= '0';
            busy      <= '1';
          when 19 to 26 =>
            tx        <= '1';
            sda_b_cat <= sda_b_cat;
            sda_b     <= sda_b_cat(26-scl_cnt);
            busy      <= '1';
          when 27 =>
            tx        <= '1';
            sda_b_cat <= sda_b_cat;
            sda_b     <= '0';
            busy      <= '1';
          when 28 to 228 =>
            tx        <= '0';
            sda_b_cat <= (others => '0');
            sda_b     <= 'Z';
            busy      <= '1';
          when others =>
            tx        <= '0';
            sda_b_cat <= (others => '0');
            sda_b     <= 'Z';
            busy      <= '0';
        end case;
      end if;
    end if;
  end process;

  scl <= scl_b when (scl_en = '1' and tx = '1') else 'Z';
  sda <= sda_b when (scl_en = '1' and tx = '1') else 'Z';

end architecture rtl;
