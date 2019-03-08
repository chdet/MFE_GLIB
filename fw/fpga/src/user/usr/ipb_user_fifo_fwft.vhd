library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.ipbus.all; 
use work.system_package.all; 

entity ipb_user_fifo_fwft is
	generic(addr_width : natural := 6); 
	port
	(
		ipbclk     : in  std_logic; 
		usrclk     : in  std_logic; 
		reset      : in  std_logic; 
		ipb_mosi_i : in  ipb_wbus; 
		ipb_miso_o : out ipb_rbus
		------------------
		
	); 
	
end ipb_user_fifo_fwft; 

architecture rtl of ipb_user_fifo_fwft is
	
	signal sel : integer range 0 to 31; 
	signal ack : std_logic; 
	signal err : std_logic; 
	
	attribute keep        : boolean; 
	attribute keep of ack : signal is true; 
	attribute keep of err : signal is true; 
	attribute keep of sel : signal is true; 
	
	signal cnt                                                           : unsigned(31 downto 0) := (others => '0'); 
	signal din, dout                                                     : std_logic_vector(31 downto 0); 
	signal wr_en, rd_en, full, empty, valid, underflow, overflow, wr_ack : std_logic; 
	
	COMPONENT fifo_2
		PORT (
			rst       : IN  STD_LOGIC; 
			wr_clk    : IN  STD_LOGIC; 
			rd_clk    : IN  STD_LOGIC; 
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
	FIFO_GEN : process(reset, usrclk)
	--=============================--
	begin
		if reset='1' then
			wr_en <= '0'; 
			cnt <= (others => '0');
		elsif rising_edge(usrclk) then
			cnt   <= cnt + 1; 
			if(full = '0') then
				wr_en <= '1'; 
			else
				wr_en <= '0'; 
			end if; 
		end if; 
	end process; 
	
	din <= std_logic_vector(cnt); 
	
	i_oh_rx_fifo : fifo_2
		PORT MAP (
			rst       => reset,
			wr_clk    => usrclk,
			rd_clk    => ipbclk,
			din       => din,
			wr_en     => wr_en,
			rd_en     => rd_en,
			dout      => dout,
			full      => full,
			wr_ack    => wr_ack,
			overflow  => overflow,
			empty     => empty,
			valid     => valid,
			underflow => underflow
		); 
	
	--=============================--
	--sel <= to_integer(unsigned(ipb_mosi_i.ipb_addr(addr_width downto 0))) when addr_width>0 else 0;
	--=============================--

	-- FIXME: Reads of the FIFO exhibit "jumps", usually by 3. With FWFT, there are additional jumps of arbitrary length
	
	----=============================--
	--process(reset, ipbclk)
	----=============================--
	--begin
	--	if reset='1' then
	--		ack <= '0'; 
	--		err <= '0';
	--		rd_en <= '0';
	--	elsif rising_edge(ipbclk) then
	--		--if (sel = 0) then
	--		ipb_miso_o.ipb_rdata <= dout; 
	--		rd_en <= ipb_mosi_i.ipb_strobe; 
	--		ack <= ipb_mosi_i.ipb_strobe and valid; -- in FWFT mode, the valid flag will be high even when rd_en is low.
	--		-- Keeping ack tied to valid alone would empty the fifo without any request, and prevent other register reads.
	--		err <= empty; 
	--		--else
	--		--	ipb_miso_o.ipb_rdata <= (0 => overflow, others => '0'); 
	--		--	ack <= ipb_mosi_i.ipb_strobe and not ack;
	--		--	err <= '0'; 
	--		--end if;
			
			
	--	end if; 
	--end process; 
	
	ipb_miso_o.ipb_rdata <= dout; 
	rd_en <= ipb_mosi_i.ipb_strobe;
	ipb_miso_o.ipb_ack <= ipb_mosi_i.ipb_strobe and valid;
	ipb_miso_o.ipb_err <= ipb_mosi_i.ipb_strobe and underflow; 

	--ipb_miso_o.ipb_ack <= ack; 
	--ipb_miso_o.ipb_err <= err; 
	
end rtl;