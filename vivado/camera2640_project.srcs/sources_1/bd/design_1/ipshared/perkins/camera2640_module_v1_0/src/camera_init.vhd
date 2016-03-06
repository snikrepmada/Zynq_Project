library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ov2640_init is
  port (
    clk    : in    std_logic;
    rstn   : in    std_logic;
    en     : in    std_logic;
    status : out   std_logic;
    sda    : inout std_logic;
    scl    : inout std_logic);
end entity ov2640_init;

architecture rtl of ov2640_init is
  component edge_detector is
    generic (
      PULSE_EXT             : integer;
      EDGE_TYPE             : integer;
      IGNORE_RST_WHILE_BUSY : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      signal_in : in  std_logic;
      pulse_out : out std_logic);
  end component edge_detector;
  component i2cm is
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
  end component i2cm;
  component ov2640reg_rom is
    generic (
      WIDTH      : integer;
      ADDR_WIDTH : integer;
      DEPTH      : integer);
    port (
      clk     : in  std_logic;
      address : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      q       : out std_logic_vector(WIDTH-1 downto 0));
  end component ov2640reg_rom;
  constant OV2640_READ_ADDR  : std_logic_vector(6 downto 0) := "1100001";
  constant OV2640_WRITE_ADDR : std_logic_vector(6 downto 0) := "1100000";
  signal en_p                : std_logic;
  signal i2c_addr            : std_logic_vector(6 downto 0);
  signal i2c_wr_reg          : std_logic_vector(7 downto 0);
  signal i2c_wr_reg_data     : std_logic_vector(7 downto 0);
  signal i2c_wr_data         : std_logic_vector(7 downto 0);
  signal i2c_wr_data_data    : std_logic_vector(7 downto 0);
  signal i2c_rd_reg          : std_logic_vector(7 downto 0);
  signal i2c_rd_reg_data     : std_logic_vector(7 downto 0);
  signal i2c_rd_data         : std_logic_vector(7 downto 0);
  signal i2c_rw              : std_logic;
  signal i2c_en              : std_logic;
  signal i2c_busy            : std_logic;
  signal rom_addr            : std_logic_vector(7 downto 0);
  signal rom_addr_rst        : std_logic;
  signal rom_addr_en         : std_logic;
  signal rom_data            : std_logic_vector(15 downto 0);
  type state_t is (s_idle, s_rom_reset, s_default_reg_write_check_i2c_busy,
                   s_default_reg_write_setup, s_default_reg_write_latch,
                   s_default_reg_write_hold, s_default_reg_write_inc_rom, s_done);
  signal current_state : state_t;
  signal next_state    : state_t;
begin
  U0_EDGE_DETECTOR : edge_detector
    generic map (
      PULSE_EXT             => 0,
      EDGE_TYPE             => 0,
      IGNORE_RST_WHILE_BUSY => 0)
    port map (
      clk       => clk,
      rst_n     => rstn,
      signal_in => en,
      pulse_out => en_p);

  U1_I2C_MASTER : i2cm
    port map (
      clk     => clk,
      rstn    => rstn,
      addr    => i2c_addr,
      wr_reg  => i2c_wr_reg,
      wr_data => i2c_wr_data,
      rd_reg  => i2c_rd_reg,
      rd_data => i2c_rd_data,
      rw      => i2c_rw,
      en      => i2c_en,
      busy    => i2c_busy,
      sda     => sda,
      scl     => scl);

  U2_OV2640REG_ROM : ov2640reg_rom
    generic map (
      WIDTH      => 16,
      ADDR_WIDTH => 8,
      DEPTH      => 256)
    port map (
      clk     => clk,
      address => rom_addr,
      q       => rom_data);

  i2c_wr_reg_data  <= rom_data(15 downto 8);
  i2c_rd_reg_data  <= rom_data(15 downto 8);
  i2c_wr_data_data <= rom_data(7 downto 0);

  U3_ADDRESS_COUNTER : process(clk, rstn)
  begin
    if rstn = '0' then
      rom_addr <= (others => '0');
    else
      if rising_edge(clk) then
        if rom_addr_rst = '1' then
          rom_addr <= (others => '0');
        else
          if rom_addr_en = '1' then
            rom_addr <= std_logic_vector(unsigned(rom_addr) + to_unsigned(1, 8));
          end if;
        end if;
      end if;
    end if;
  end process;

  U4_STATE_CLOCK : process(clk)
  begin
    if rising_edge(clk) then
      if rstn = '0' then
        current_state <= s_idle;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  U5_STATE_MACHINE : process(current_state, en_p, rom_addr, i2c_busy)
  begin
    case current_state is
      when s_idle =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '0';
        i2c_addr     <= (others => '0');
        i2c_wr_reg   <= (others => '0');
        i2c_wr_data  <= (others => '0');
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '0';
        if en_p = '1' then
          next_state <= s_rom_reset;
        else
          next_state <= s_idle;
        end if;
      when s_rom_reset =>
        rom_addr_rst <= '1';
        rom_addr_en  <= '0';
        i2c_addr     <= (others => '0');
        i2c_wr_reg   <= (others => '0');
        i2c_wr_data  <= (others => '0');
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '0';
        next_state   <= s_default_reg_write_check_i2c_busy;
      when s_default_reg_write_check_i2c_busy =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '0';
        i2c_addr     <= (others => '0');
        i2c_wr_reg   <= (others => '0');
        i2c_wr_data  <= (others => '0');
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '0';
        if unsigned(rom_addr) < 201 then
          if i2c_busy = '0' then
            next_state <= s_default_reg_write_setup;
          else
            next_state <= s_default_reg_write_check_i2c_busy;
          end if;
        else
          next_state <= s_done;
        end if;
      when s_default_reg_write_setup =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '0';
        i2c_addr     <= OV2640_WRITE_ADDR;
        i2c_wr_reg   <= i2c_wr_reg_data;
        i2c_wr_data  <= i2c_wr_data_data;
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '0';
        next_state   <= s_default_reg_write_latch;
      when s_default_reg_write_latch =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '0';
        i2c_addr     <= OV2640_WRITE_ADDR;
        i2c_wr_reg   <= i2c_wr_reg_data;
        i2c_wr_data  <= i2c_wr_data_data;
        i2c_rw       <= '0';
        i2c_en       <= '1';
        status       <= '0';
        if i2c_busy = '1' then
          next_state <= s_default_reg_write_hold;
        else
          next_state <= s_default_reg_write_latch;
        end if;
      when s_default_reg_write_hold =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '0';
        i2c_addr     <= OV2640_WRITE_ADDR;
        i2c_wr_reg   <= i2c_wr_reg_data;
        i2c_wr_data  <= i2c_wr_data_data;
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '0';
        if i2c_busy = '0' then
          next_state <= s_default_reg_write_inc_rom;
        else
          next_state <= s_default_reg_write_hold;
        end if;
      when s_default_reg_write_inc_rom =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '1';
        i2c_addr     <= (others => '0');
        i2c_wr_reg   <= (others => '0');
        i2c_wr_data  <= (others => '0');
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '0';
        next_state   <= s_default_reg_write_check_i2c_busy;
      when s_done =>
        rom_addr_rst <= '0';
        rom_addr_en  <= '0';
        i2c_addr     <= (others => '0');
        i2c_wr_reg   <= (others => '0');
        i2c_wr_data  <= (others => '0');
        i2c_rw       <= '0';
        i2c_en       <= '0';
        status       <= '1';
        next_state   <= s_done;
    end case;
  end process;
end architecture rtl;
