library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.system_package.all;
use work.fifo_1.all;

entity ipb_user_status_regs is
generic(addr_width : natural := 6);
port
(
	clk					: in 	std_logic;
	reset					: in 	std_logic;
	ipb_mosi_i			: in 	ipb_wbus;
	ipb_miso_o			: out ipb_rbus;
	------------------
	regs_i				: in	array_32x32bit
);
	
end ipb_user_status_regs;

architecture rtl of ipb_user_status_regs is

signal regs: array_32x32bit;		

	signal sel: integer range 0 to 31;
	signal ack: std_logic;

	attribute keep: boolean;
	attribute keep of ack: signal is true;
	attribute keep of sel: signal is true;

	signal din, dout: std_logic_vector(31 downto 0);
	signal wr_en, rd_en, full, empty, valid: std_logic;

	COMPONENT fifo_1
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );

begin

	U0 : entity work.fifo_1
  PORT MAP (
    clk => clk,
    rst => reset,
    din => din,
    wr_en => wr_en,
    rd_en => rd_en,
    dout => dout,
    full => full,
    empty => empty,
    valid => valid
  );

	--=============================--
	-- io mapping
	--=============================--
	regs 		<= regs_i;


	--=============================--
	sel <= to_integer(unsigned(ipb_mosi_i.ipb_addr(addr_width downto 0))) when addr_width>0 else 0;
	--=============================--
	

	--=============================--
	process(reset, clk)
	--=============================--
	begin
	if reset='1' then
		ack 	 <= '0';
	elsif rising_edge(clk) then
		-- read 
		ipb_miso_o.ipb_rdata <= regs(sel);
		-- ack
		ack <= ipb_mosi_i.ipb_strobe and not ack;

	end if;
	end process;
	
	ipb_miso_o.ipb_ack <= ack;
	ipb_miso_o.ipb_err <= '0';

end rtl;