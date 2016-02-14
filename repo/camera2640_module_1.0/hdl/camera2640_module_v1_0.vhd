library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera2640_module_v1_0 is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Master Bus Interface M_AXIS
    C_M_AXIS_TDATA_WIDTH : integer := 32;
    C_M_AXIS_START_COUNT : integer := 32
    );
  port (
    -- Users to add ports here
    capture : in    std_logic;
    sda     : inout std_logic;
    scl     : inout std_logic;
    vsync   : in    std_logic;
    href    : in    std_logic;
    pclk    : in    std_logic;
    data_in : in    std_logic_vector(7 downto 0);
    debug   : out   std_logic_vector(3 downto 0);
    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Master Bus Interface M_AXIS
    m_axis_aclk    : in  std_logic;
    m_axis_aresetn : in  std_logic;
    m_axis_tvalid  : out std_logic;
    m_axis_tdata   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    m_axis_tstrb   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
    m_axis_tlast   : out std_logic;
    m_axis_tready  : in  std_logic
    );
end camera2640_module_v1_0;

architecture arch_imp of camera2640_module_v1_0 is

  -- component declaration
  component camera2640_module_v1_0_M_AXIS is
    generic (
      C_M_AXIS_TDATA_WIDTH : integer := 32;
      C_M_START_COUNT      : integer := 32
      );
    port (
      M_AXIS_ACLK    : in  std_logic;
      M_AXIS_ARESETN : in  std_logic;
      M_AXIS_TVALID  : out std_logic;
      M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
      M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
      M_AXIS_TLAST   : out std_logic;
      M_AXIS_TREADY  : in  std_logic
      );
  end component camera2640_module_v1_0_M_AXIS;

begin

-- Instantiation of Axi Bus Interface M_AXIS
  camera2640_module_v1_0_M_AXIS_inst : camera2640_module_v1_0_M_AXIS
    generic map (
      C_M_AXIS_TDATA_WIDTH => C_M_AXIS_TDATA_WIDTH,
      C_M_START_COUNT      => C_M_AXIS_START_COUNT
      )
    port map (
      M_AXIS_ACLK    => m_axis_aclk,
      M_AXIS_ARESETN => m_axis_aresetn,
      M_AXIS_TVALID  => m_axis_tvalid,
      M_AXIS_TDATA   => m_axis_tdata,
      M_AXIS_TSTRB   => m_axis_tstrb,
      M_AXIS_TLAST   => m_axis_tlast,
      M_AXIS_TREADY  => m_axis_tready,
      --User signals
      capture        => capture,
      sda            => sda,
      scl            => scl,
      vsync          => vsync,
      href           => href,
      pclk           => pclk,
      data_in        => data_in,
      debug          => debug
      );

  -- Add user logic here

  -- User logic ends

end arch_imp;
