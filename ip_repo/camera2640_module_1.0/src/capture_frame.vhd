library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity capture_frame is
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
end entity capture_frame;

architecture rtl of capture_frame is
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
  component frame_fifo is
    port (
      rst          : in  std_logic;
      wr_clk       : in  std_logic;
      rd_clk       : in  std_logic;
      din          : in  std_logic_vector(7 downto 0);
      wr_en        : in  std_logic;
      rd_en        : in  std_logic;
      dout         : out std_logic_vector(31 downto 0);
      full         : out std_logic;
      almost_full  : out std_logic;
      empty        : out std_logic;
      almost_empty : out std_logic);
  end component frame_fifo;
  signal rst         : std_logic;
  signal vsync_start : std_logic;
  signal vsync_end   : std_logic;
  signal capture     : std_logic;
  signal en_p        : std_logic;
  signal wr_en       : std_logic;
  signal frame_state : integer;
begin
  U0_CAPTURE_START : edge_detector
    generic map (
      PULSE_EXT             => 0,
      EDGE_TYPE             => 0,
      IGNORE_RST_WHILE_BUSY => 0)
    port map (
      clk       => clk,
      rst_n     => rstn,
      signal_in => en,
      pulse_out => en_p);

  U1_VSYNC_START : edge_detector
    generic map (
      PULSE_EXT             => 0,
      EDGE_TYPE             => 1,
      IGNORE_RST_WHILE_BUSY => 0)
    port map (
      clk       => clk,
      rst_n     => rstn,
      signal_in => vsync,
      pulse_out => vsync_start);

  U2_VSYNC_END : edge_detector
    generic map (
      PULSE_EXT             => 0,
      EDGE_TYPE             => 0,
      IGNORE_RST_WHILE_BUSY => 0)
    port map (
      clk       => clk,
      rst_n     => rstn,
      signal_in => vsync,
      pulse_out => vsync_end);

  U3_RECORD_FRAME : process(clk, rstn)
  begin
    if rstn = '0' then
      frame_state <= 0;
      capture     <= '0';
      status      <= '0';
    else
      if rising_edge(clk) then
        case frame_state is
          when 0 =>                     --Waiting for start signal
            capture <= '0';
            status  <= '0';
            if en_p = '1' then
              frame_state <= 1;
            else
              frame_state <= 0;
            end if;
          when 1 =>                     --Waiting for start of VSYNC
            capture <= '0';
            status  <= '1';
            if vsync_start = '1' then
              frame_state <= 2;
            else
              frame_state <= 1;
            end if;
          when 2 =>                     --Waiting for end of VSYNC
            capture <= '1';
            status  <= '1';
            if vsync_end = '1' then
              frame_state <= 3;
            else
              frame_state <= 2;
            end if;
          when 3 =>                     --Finished recording a frame
            capture     <= '0';
            status      <= '0';
            frame_state <= 3;
          when others =>                --Handle other cases
            capture     <= '0';
            status      <= '0';
            frame_state <= 3;
        end case;
      end if;
    end if;
  end process;

  rst   <= not rstn;
  wr_en <= capture and href;

  U4_FRAME_FIFO : frame_fifo
    port map (
      rst          => rst,
      wr_clk       => pclk,
      rd_clk       => clk,
      din          => data_in,
      wr_en        => wr_en,
      rd_en        => rd_en,
      dout         => data_out,
      full         => open,
      almost_full  => open,
      empty        => rd_wait,
      almost_empty => open);

end architecture rtl;
