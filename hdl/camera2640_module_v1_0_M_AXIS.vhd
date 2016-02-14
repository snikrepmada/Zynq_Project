library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera2640_module_v1_0_M_AXIS is
  generic (
    WIDTH            : integer := 32;
    DELAY            : integer := 32;
    NUMBER_OF_PIXELS : integer := 76800);
  port (
    --AXI stream ports
    m_axis_aclk    : in    std_logic;
    m_axis_aresetn : in    std_logic;
    m_axis_tvalid  : out   std_logic;
    m_axis_tdata   : out   std_logic_vector(WIDTH-1 downto 0);
    m_axis_tstrb   : out   std_logic_vector((WIDTH/8)-1 downto 0);
    m_axis_tlast   : out   std_logic;
    m_axis_tready  : in    std_logic;
    --Camera ports
    capture        : in    std_logic;
    sda            : inout std_logic;
    scl            : inout std_logic;
    vsync          : in    std_logic;
    href           : in    std_logic;
    pclk           : in    std_logic;
    data_in        : in    std_logic_vector(7 downto 0);
    debug          : out   std_logic_vector(3 downto 0));
end entity camera2640_module_v1_0_M_AXIS;

architecture rtl of camera2640_module_v1_0_M_AXIS is
  component camera2640 is
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
  end component camera2640;
  type state_t is (s_idle, s_init_counter, s_send_stream);
  signal current_state : state_t;
  signal status        : std_logic;
  signal rd_en         : std_logic;
  signal rd_wait       : std_logic;
  signal delay_count   : std_logic_vector(4 downto 0);
  signal axis_tlast    : std_logic;
  signal axis_tlast_r  : std_logic;
  signal axis_tvalid   : std_logic;
  signal axis_tvalid_r : std_logic;
  signal pixel_count   : std_logic_vector(WIDTH-1 downto 0);
  signal tx_en         : std_logic;
  signal tx_done       : std_logic;
begin
  m_axis_tvalid <= axis_tvalid_r;
  m_axis_tlast  <= axis_tlast_r;
  m_axis_tstrb  <= (others => '1');

  --Control state machine implementation                                               
  process(m_axis_aclk)
  begin
    if rising_edge(m_axis_aclk) then
      if m_axis_aresetn = '0' then
        current_state <= s_idle;
        delay_count   <= (others => '0');
      else
        case (current_state) is
          when s_idle =>
            delay_count <= (others => '0');
            if status = '1' then
              current_state <= s_init_counter;
            else
              current_state <= s_idle;
            end if;
          when s_init_counter =>
            if delay_count = std_logic_vector(to_unsigned(DELAY, 5)) then
              delay_count   <= delay_count;
              current_state <= s_send_stream;
            else
              delay_count   <= std_logic_vector(unsigned(delay_count) + 1);
              current_state <= s_init_counter;
            end if;
          when s_send_stream =>
            delay_count <= (others => '0');
            if tx_done = '1' then
              current_state <= s_idle;
            else
              current_state <= s_send_stream;
            end if;
        end case;
      end if;
    end if;
  end process;

  axis_tvalid <= '1' when ((current_state = s_send_stream) and (pixel_count < std_logic_vector(to_unsigned(NUMBER_OF_PIXELS, WIDTH)))) else '0';
  axis_tlast  <= '1' when (pixel_count = std_logic_vector(to_unsigned(NUMBER_OF_PIXELS-1, WIDTH)))                                     else '0';

  process(m_axis_aclk)
  begin
    if (rising_edge (m_axis_aclk)) then
      if(m_axis_aresetn = '0') then
        axis_tvalid_r <= '0';
        axis_tlast_r  <= '0';
      else
        axis_tvalid_r <= axis_tvalid;
        axis_tlast_r  <= axis_tlast;
      end if;
    end if;
  end process;

  --Pixel counter
  process(m_axis_aclk)
  begin
    if rising_edge (m_axis_aclk) then
      if m_axis_aresetn = '0' then
        pixel_count <= (others => '0');
        tx_done     <= '0';
      else
        if (pixel_count <= std_logic_vector(to_unsigned(NUMBER_OF_PIXELS-1, WIDTH))) then
          if tx_en = '1' then
            pixel_count <= std_logic_vector(unsigned(pixel_count) + to_unsigned(1, WIDTH));
            tx_done     <= '0';
          end if;
        else
          if pixel_count = std_logic_vector(to_unsigned(NUMBER_OF_PIXELS, WIDTH)) then
            tx_done <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  --FIFO read enable generation
  rd_en <= m_axis_tready and axis_tvalid_r;
  tx_en <= not rd_wait and axis_tvalid_r;

  camera2640_1 : camera2640
    port map (
      clk      => m_axis_aclk,
      rstn     => m_axis_aresetn,
      capture  => capture,
      status   => status,
      sda      => sda,
      scl      => scl,
      vsync    => vsync,
      href     => href,
      pclk     => pclk,
      data_in  => data_in,
      data_out => m_axis_tdata,
      rd_en    => rd_en,
      rd_wait  => rd_wait,
      debug    => debug);

end architecture rtl;
