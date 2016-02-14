library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity camera2640 is
  port (
    clk      : in    std_logic;
    rstn     : in    std_logic;
    capture  : in    std_logic;
    status   : out   std_logic;
    sda      : inout std_logic;
    scl      : inout std_logic;
    vsync    : in    std_logic;
    href     : in    std_logic;
    pclk     : in    std_logic;
    data_in  : in    std_logic_vector(7 downto 0);
    data_out : out   std_logic_vector(31 downto 0);
    rd_en    : in    std_logic;
    rd_wait  : out   std_logic;
    debug    : out   std_logic_vector(3 downto 0));
end entity camera2640;

architecture rtl of camera2640 is
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
  component ov2640_init is
    port (
      clk    : in    std_logic;
      rstn   : in    std_logic;
      en     : in    std_logic;
      status : out   std_logic;
      sda    : inout std_logic;
      scl    : inout std_logic);
  end component ov2640_init;
  component capture_frame is
    port (
      clk      : in  std_logic;
      rstn     : in  std_logic;
      en       : in  std_logic;
      status   : out std_logic;
      vsync    : in  std_logic;
      href     : in  std_logic;
      pclk     : in  std_logic;
      data_in  : in  std_logic_vector(7 downto 0);
      data_out : out std_logic_vector(31 downto 0);
      rd_en    : in  std_logic;
      rd_wait  : out std_logic);
  end component capture_frame;
  signal init_en     : std_logic;
  signal init_status : std_logic;
  signal cap_en      : std_logic;
  signal cap_status  : std_logic;
  signal run_state   : integer;
begin

  U0_CAMERA2640_INIT : ov2640_init
    port map (
      clk    => clk,
      rstn   => rstn,
      en     => init_en,
      status => init_status,
      sda    => sda,
      scl    => scl);

  U1_CAPTURE_FRAME : capture_frame
    port map (
      clk      => clk,
      rstn     => rstn,
      en       => cap_en,
      status   => cap_status,
      vsync    => vsync,
      href     => href,
      pclk     => pclk,
      data_in  => data_in,
      data_out => data_out,
      rd_en    => rd_en,
      rd_wait  => rd_wait);

  U2_CAPTURE_START : edge_detector
    generic map (
      PULSE_EXT             => 0,
      EDGE_TYPE             => 0,
      IGNORE_RST_WHILE_BUSY => 0)
    port map (
      clk       => clk,
      rst_n     => rstn,
      signal_in => capture,
      pulse_out => cap_en);

  U2_PROGRAM_STATE : process(clk, rstn)
  begin
    if rstn = '0' then
      run_state         <= 0;
      debug(1 downto 0) <= "00";
    else
      if rising_edge(clk) then
        case run_state is
          when 0 =>
            init_en           <= '1';
            debug(1 downto 0) <= "01";
            run_state         <= 1;
          when 1 =>
            init_en           <= '0';
            debug(1 downto 0) <= "10";
            if init_status = '1' then
              run_state <= 2;
            else
              run_state <= 1;
            end if;
          when 2 =>
            init_en           <= '0';
            debug(1 downto 0) <= "11";
            run_state         <= 2;
          when others =>
            init_en           <= '0';
            debug(1 downto 0) <= "11";
            run_state         <= 2;
        end case;
      end if;
    end if;
  end process;

end architecture rtl;
