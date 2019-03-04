library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
use work.ipbus.all; 
use work.system_package.all; 

entity ipb_user_fifo is
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
	
end ipb_user_fifo; 

architecture rtl of ipb_user_fifo is
	
	--signal sel : integer range 0 to 31; 
	signal ack : std_logic; 
	signal err : std_logic; 
	
	attribute keep        : boolean; 
	attribute keep of ack : signal is true; 
	attribute keep of err : signal is true; 
	--attribute keep of sel : signal is true; 
	
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
	process(reset, ipbclk)
	--=============================--
	begin
		if reset='1' then
			ack <= '0'; 
			err <= '0';
			rd_en <= '0';
		elsif rising_edge(ipbclk) then
			-- read 
			ipb_miso_o.ipb_rdata <= dout; 
			-- ack
			rd_en <= ipb_mosi_i.ipb_strobe; 
			--ack <= (not ack) and valid; 
			ack <= valid; 
			err <= underflow; 
			
		end if; 
	end process; 
	
	ipb_miso_o.ipb_ack <= ack; 
	ipb_miso_o.ipb_err <= err; 
	
end rtl;