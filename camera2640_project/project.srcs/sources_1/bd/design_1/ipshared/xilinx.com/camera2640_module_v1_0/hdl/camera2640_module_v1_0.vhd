library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera2640_module_v1_0 is
  generic (
    WIDTH            : integer := 32;
    DELAY            : integer := 32;
    NUMBER_OF_PIXELS : integer := 76800);
  port (
    m_axis_aclk    : in    std_logic;
    m_axis_aresetn : in    std_logic;
    m_axis_tvalid  : out   std_logic;
    m_axis_tdata   : out   std_logic_vector(WIDTH-1 downto 0);
    m_axis_tstrb   : out   std_logic_vector((WIDTH/8)-1 downto 0);
    m_axis_tlast   : out   std_logic;
    m_axis_tready  : in    std_logic;
    capture        : in    std_logic;
    sda            : inout std_logic;
    scl            : inout std_logic;
    vsync          : in    std_logic;
    href           : in    std_logic;
    pclk           : in    std_logic;
    data_in        : in    std_logic_vector(7 downto 0);
    debug          : out   std_logic_vector(3 downto 0));
end entity camera2640_module_v1_0;

architecture rtl of camera2640_module_v1_0 is
  component camera2640_module_v1_0_M_AXIS is
    generic (
      WIDTH            : integer;
      DELAY            : integer;
      NUMBER_OF_PIXELS : integer);
    port (
      m_axis_aclk    : in    std_logic;
      m_axis_aresetn : in    std_logic;
      m_axis_tvalid  : out   std_logic;
      m_axis_tdata   : out   std_logic_vector(WIDTH-1 downto 0);
      m_axis_tstrb   : out   std_logic_vector((WIDTH/8)-1 downto 0);
      m_axis_tlast   : out   std_logic;
      m_axis_tready  : in    std_logic;
      capture        : in    std_logic;
      sda            : inout std_logic;
      scl            : inout std_logic;
      vsync          : in    std_logic;
      href           : in    std_logic;
      pclk           : in    std_logic;
      data_in        : in    std_logic_vector(7 downto 0);
      debug          : out   std_logic_vector(3 downto 0));
  end component camera2640_module_v1_0_M_AXIS;
begin
  camera2640_module_v1_0_M_AXIS_1 : camera2640_module_v1_0_M_AXIS
    generic map (
      WIDTH            => WIDTH,
      DELAY            => DELAY,
      NUMBER_OF_PIXELS => NUMBER_OF_PIXELS)
    port map (
      m_axis_aclk    => m_axis_aclk,
      m_axis_aresetn => m_axis_aresetn,
      m_axis_tvalid  => m_axis_tvalid,
      m_axis_tdata   => m_axis_tdata,
      m_axis_tstrb   => m_axis_tstrb,
      m_axis_tlast   => m_axis_tlast,
      m_axis_tready  => m_axis_tready,
      capture        => capture,
      sda            => sda,
      scl            => scl,
      vsync          => vsync,
      href           => href,
      pclk           => pclk,
      data_in        => data_in,
      debug          => debug);
end architecture rtl;
