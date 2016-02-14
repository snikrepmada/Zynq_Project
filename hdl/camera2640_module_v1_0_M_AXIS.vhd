library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera2640_module_v1_0_M_AXIS is
  generic (
    NUMBER_OF_PIXELS : integer := 76800;
    WIDTH            : integer := 32;
    DELAY            : integer := 32);
  port (
    --AXI stream ports
    m_axis_aclk    : in    std_logic;
    m_axis_aresetn : in    std_logic;
    m_axis_tvalid  : out   std_logic;
    m_axis_tdata   : out   std_logic_vector(WIDTH-1 downto 0);
    m_axis_tstrb   : out   std_logic_vector((WIDTH/8)-1 downto 0);
    m_axis_tlast   : out   std_logic;
    m_axis_tready  : in    std_logic
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

begin
  m_axis_tvalid <= axis_tvalid_r;
  m_axis_tlast  <= axis_tlast_r;
  m_axis_tstrb  <= (others => '1');

  -- Control state machine implementation                                               
  process(m_axis_aclk)
  begin
    if rising_edge(m_axis_aclk) then
      if m_axis_aresetn = '0' then
        current_state <= s_idle;
        delay_count   <= (others => '0');
      else
        case (current_state) is
          when s_idle =>
            delay_count   <= (others => '0');
            current_state <= s_init_counter;
          when s_init_counter =>
            if delay_count = std_logic_vector(to_unsigned(DELAY), 5) then
              current_state <= s_send_stream;
            else
              delay_count   <= std_logic_vector (unsigned(delay_count) + 1);
              current_state <= s_init_counter;
            end if;
          when s_send_stream =>
            delay_count <= (others => '0')
            if tx_done = '1' then
              current_state <= s_idle;
            else
              current_state <= s_send_stream;
            end if;
        end case;
      end if;
    end if;
  end process;


  --tvalid generation
  --axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
  --number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
  axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (read_pointer < NUMBER_OF_OUTPUT_WORDS)) else '0';

  -- AXI tlast generation                                                                        
  -- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
  -- (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
  axis_tlast <= '1' when (read_pointer = NUMBER_OF_OUTPUT_WORDS-1) else '0';

  -- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
  -- to match the latency of M_AXIS_TDATA                                                        
  process(M_AXIS_ACLK)
  begin
    if (rising_edge (M_AXIS_ACLK)) then
      if(M_AXIS_ARESETN = '0') then
        axis_tvalid_delay <= '0';
        axis_tlast_delay  <= '0';
      else
        axis_tvalid_delay <= axis_tvalid;
        axis_tlast_delay  <= axis_tlast;
      end if;
    end if;
  end process;


  --read_pointer pointer

  process(M_AXIS_ACLK)
  begin
    if (rising_edge (M_AXIS_ACLK)) then
      if(M_AXIS_ARESETN = '0') then
        read_pointer <= 0;
        tx_done      <= '0';
      else
        if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1) then
          if (tx_en = '1') then
            -- read pointer is incremented after every read from the FIFO          
            -- when FIFO read signal is enabled.                                   
            read_pointer <= read_pointer + 1;
            tx_done      <= '0';
          end if;
        elsif (read_pointer = NUMBER_OF_OUTPUT_WORDS) then
          -- tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
          -- has been out.                                                         
          tx_done <= '1';
        end if;
      end if;
    end if;
  end process;


  --FIFO read enable generation 
  rd_en <= m_axis_tready and rd_wait;

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

end implementation;
