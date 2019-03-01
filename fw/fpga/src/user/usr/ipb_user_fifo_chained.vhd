library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.ipbus.all; 
use work.system_package.all; 

entity ipb_user_fifo_chained is
	generic(addr_width : natural := 6); 
	port
	(
		clk        : in  std_logic; 
		reset      : in  std_logic; 
		ipb_mosi_i : in  ipb_wbus; 
		ipb_miso_o : out ipb_rbus
		------------------
		
	); 
	
end ipb_user_fifo_chained; 

architecture rtl of ipb_user_fifo_chained is
	
	--signal sel : integer range 0 to 31; 
	signal ack : std_logic; 
	signal err : std_logic; 
	
	attribute keep        : boolean; 
	attribute keep of ack : signal is true; 
	attribute keep of err : signal is true; 
	--attribute keep of sel : signal is true; 
	
	signal cnt                                                           : unsigned(31 downto 0) := (others => '0'); 
	signal din0, dout0, dout1, dout2                                      : std_logic_vector(31 downto 0); 
	signal wr_en0, rd_en2, underflow2, full0 : std_logic; 
	signal valid0, valid1, valid2 : std_logic;
	
	COMPONENT fifo_1
		PORT (
			clk       : IN  STD_LOGIC; 
			rst       : IN  STD_LOGIC; 
			din       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
			wr_en     : IN  STD_LOGIC; 
			rd_en     : IN  STD_LOGIC; 
			dout      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); 
			full      : OUT STD_LOGIC; 
			wr_ack    : OUT STD_LOGIC; 
			overflow  : OUT STD_LOGIC; 
			empty     : OUT STD_LOGIC; 
			valid     : OUT STD_LOGIC; 
			underflow : OUT STD_LOGIC
		); 
	END COMPONENT; 
	
begin
	
	--=============================--
	FIFO_GEN : process(reset, clk)
	--=============================--
	begin
		if reset='1' then
			wr_en0 <= '0'; 
		elsif rising_edge(clk) then
			if(full0 = '0') then
				cnt <= cnt + 1; 
				wr_en0 <= '1';
			else
				wr_en0 <= '0';
			end if; 
		end if; 
	end process; 

	din0 <= std_logic_vector(cnt);
	
	i_oh_rx_fifo_0 : fifo_1
		PORT MAP (
			clk       => clk,
			rst       => reset,
			din       => din0,
			wr_en     => wr_en0,
			rd_en     => '1',
			dout      => dout0,
			full      => open,
			wr_ack    => open,
			overflow  => open,
			empty     => open,
			valid     => valid0,
			underflow => open
		); 

	i_oh_rx_fifo_1 : fifo_1
		PORT MAP (
			clk       => clk,
			rst       => reset,
			din       => dout0,
			wr_en     => valid0,
			rd_en     => '1',
			dout      => dout1,
			full      => open,
			wr_ack    => open,
			overflow  => open,
			empty     => open,
			valid     => valid1,
			underflow => open
		); 
	
	i_oh_rx_fifo_2 : fifo_1
		PORT MAP (
			clk       => clk,
			rst       => reset,
			din       => dout1,
			wr_en     => valid1,
			rd_en     => rd_en2,
			dout      => dout2,
			full      => open,
			wr_ack    => open,
			overflow  => open,
			empty     => open,
			valid     => valid2,
			underflow => underflow2
		); 

	--=============================--
	--sel <= to_integer(unsigned(ipb_mosi_i.ipb_addr(addr_width downto 0))) when addr_width>0 else 0; 
	--=============================--
	
	--=============================--
	process(reset, clk)
	--=============================--
	begin
		if reset='1' then
			ack <= '0'; 
		elsif rising_edge(clk) then
			-- read 
			ipb_miso_o.ipb_rdata <= dout2; 
			-- ack
			rd_en2 <= ipb_mosi_i.ipb_strobe;
			--ack <= (not ack) and valid; 
			ack <= valid2;
			err <= underflow2; 
				
				end if; 
		end process; 
		
		ipb_miso_o.ipb_ack <= ack; 
		ipb_miso_o.ipb_err <= err; 
		
	end rtl;