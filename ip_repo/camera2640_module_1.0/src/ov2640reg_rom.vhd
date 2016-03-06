library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ov2640reg_rom is
  generic (
    WIDTH      : integer := 16;
    ADDR_WIDTH : integer := 8;
    DEPTH      : integer := 256         --Must be 2**ADDR_WIDTH
    );
  port (
    clk     : in  std_logic;
    address : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    q       : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity ov2640reg_rom;

architecture rtl of ov2640reg_rom is
  type romarray is array(0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
  constant rom_mem : romarray := (
    --Defaut initialization registers and data
    --0
    (x"ff00"),
    (x"2cff"),
    (x"2edf"),
    (x"ff01"),
    (x"3c32"),
    (x"1100"),
    (x"0902"),
    (x"04a8"),
    (x"13e5"),
    (x"1448"),
    (x"2c0c"),
    (x"3378"),
    (x"3a33"),
    (x"3bfb"),
    (x"3e00"),
    (x"4311"),
    (x"1610"),
    (x"3902"),
    (x"3588"),
    (x"220a"),
    (x"3740"),
    (x"2300"),
    (x"34a0"),
    (x"0602"),
    (x"0688"),
    (x"07c0"),
    (x"0db7"),
    (x"0e01"),
    (x"4c00"),
    (x"4a81"),
    (x"2199"),
    (x"2440"),
    (x"2538"),
    (x"2682"),
    (x"5c00"),
    (x"6300"),
    (x"4622"),
    (x"0c3a"),
    (x"5d55"),
    (x"5e7d"),
    (x"5f7d"),
    (x"6055"),
    (x"6170"),
    (x"6280"),
    (x"7c05"),
    (x"2080"),
    (x"2830"),
    (x"6c00"),
    (x"6d80"),
    (x"6e00"),
    (x"7002"),
    (x"7194"),
    (x"73c1"),
    (x"3d34"),
    (x"1204"),
    (x"5a57"),
    (x"4fbb"),
    (x"509c"),
    (x"ff00"),
    (x"e57f"),
    (x"f9c0"),
    (x"4124"),
    (x"e014"),
    (x"76ff"),
    (x"33a0"),
    (x"4220"),
    (x"4318"),
    (x"4c00"),
    (x"87d0"),
    (x"883f"),
    (x"d703"),
    (x"d910"),
    (x"d382"),
    (x"c808"),
    (x"c980"),
    (x"7c00"),
    (x"7d00"),
    (x"7c03"),
    (x"7d48"),
    (x"7d48"),
    (x"7c08"),
    (x"7d20"),
    (x"7d10"),
    (x"7d0e"),
    (x"9000"),
    (x"910e"),
    (x"911a"),
    (x"9131"),
    (x"915a"),
    (x"9169"),
    (x"9175"),
    (x"917e"),
    (x"9188"),
    (x"918f"),
    (x"9196"),
    (x"91a3"),
    (x"91af"),
    (x"91c4"),
    (x"91d7"),
    (x"91e8"),
    (x"9120"),
    (x"9200"),
    (x"9306"),
    (x"93e3"),
    (x"9303"),
    (x"9303"),
    (x"9300"),
    (x"9302"),
    (x"9300"),
    (x"9300"),
    (x"9300"),
    (x"9300"),
    (x"9300"),
    (x"9300"),
    (x"9300"),
    (x"9600"),
    (x"9708"),
    (x"9719"),
    (x"9702"),
    (x"970c"),
    (x"9724"),
    (x"9730"),
    (x"9728"),
    (x"9726"),
    (x"9702"),
    (x"9798"),
    (x"9780"),
    (x"9700"),
    (x"9700"),
    (x"a400"),
    (x"a800"),
    (x"c511"),
    (x"c651"),
    (x"bf80"),
    (x"c710"),
    (x"b666"),
    (x"b8a5"),
    (x"b764"),
    (x"b97c"),
    (x"b3af"),
    (x"b497"),
    (x"b5ff"),
    (x"b0c5"),
    (x"b194"),
    (x"b20f"),
    (x"c45c"),
    (x"a600"),
    (x"a720"),
    (x"a7d8"),
    (x"a71b"),
    (x"a731"),
    (x"a700"),
    (x"a718"),
    (x"a720"),
    (x"a7d8"),
    (x"a719"),
    (x"a731"),
    (x"a700"),
    (x"a718"),
    (x"a720"),
    (x"a7d8"),
    (x"a719"),
    (x"a731"),
    (x"a700"),
    (x"a718"),
    (x"7f00"),
    (x"e51f"),
    (x"e177"),
    (x"dd7f"),
    (x"c20e"),
    (x"ff00"),
    (x"e004"),
    (x"c0c8"),
    (x"c196"),
    (x"863d"),
    (x"5190"),
    (x"522c"),
    (x"5300"),
    (x"5400"),
    (x"5588"),
    (x"5700"),
    (x"5092"),
    (x"5a50"),
    (x"5b3c"),
    (x"5c00"),
    (x"d304"),
    (x"e000"),
    (x"ff00"),
    (x"0500"),
    (x"da08"),
    (x"d703"),
    (x"e000"),
    (x"0500"),
    (x"ffff"),
    --YUV setup registers and data
    --195
    (x"ff00"),
    (x"c20e"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    --Set color bar
    --202
    (x"ff01"),
    (x"1246"),
    --Blank
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000"),
    (x"0000")--,
    --(x"0000")
    );
begin
  U0_ROM : process(address)             --clk)
  begin
    --if (rising_edge(clk)) then
    q <= rom_mem(to_integer(unsigned(address)));
  --end if;
  end process;
end rtl;