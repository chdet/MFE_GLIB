--------------------------------------------------------------------------------
-- Title       : User FIFO TB
-- Project     : Default Project Name
--------------------------------------------------------------------------------
-- File        : ipb_user_fifo_2_tb.vhd
-- Author      : User Name <user.email@user.company.com>
-- Company     : User Company Name
-- Created     : Thu Mar  7 19:08:56 2019
-- Last update : Thu Mar  7 19:27:34 2019
-- Platform    : Default Part Number
-- Standard    : <VHDL-2008 | VHDL-2002 | VHDL-1993 | VHDL-1987>
--------------------------------------------------------------------------------
-- Copyright (c) 2019 User Company Name
-------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------
-- Revisions:  Revisions and documentation are controlled by
-- the revision control system (RCS).  The RCS should be consulted
-- on revision history.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.ipbus.all; 
use work.system_package.all; 

-----------------------------------------------------------

entity ipb_user_fifo_2_tb is

end entity ipb_user_fifo_2_tb;

-----------------------------------------------------------

architecture testbench of ipb_user_fifo_2_tb is

	-- Testbench DUT generics as constants
	constant addr_width : natural := 6;

	-- Testbench DUT ports as signals
	signal ipbclk     : std_logic;
	signal usrclk     : std_logic;
	signal reset      : std_logic;
	signal ipb_mosi_i : ipb_wbus;
	signal ipb_miso_o : ipb_rbus;

	-- Other constants
	constant C_IPBCLK_PERIOD : real := 1.6e-8;
	constant C_USRCLK_PERIOD : real := 1.0e-7;


begin
	-----------------------------------------------------------
	-- Clocks and Reset
	-----------------------------------------------------------
	IPBCLK_GEN : process
	begin
		ipbclk <= '1';
		wait for C_IPBCLK_PERIOD / 2.0 * (1 SEC);
		ipbclk <= '0';
		wait for C_IPBCLK_PERIOD / 2.0 * (1 SEC);
	end process IPBCLK_GEN;

	USRCLK_GEN : process
	begin
		ipbclk <= '1';
		wait for C_USRCLK_PERIOD / 2.0 * (1 SEC);
		ipbclk <= '0';
		wait for C_USRCLK_PERIOD / 2.0 * (1 SEC);
	end process USRCLK_GEN;

	RESET_GEN : process
	begin
		reset <= '1',
		         '0' after 5.0*C_USRCLK_PERIOD * (1 SEC);
		wait;
	end process RESET_GEN;

	-----------------------------------------------------------
	-- Testbench Stimulus
	-----------------------------------------------------------

	STIM : process
	begin
		wait until reset = '0';
		ipb_mosi_i.ipb_strobe <= '1';
		wait for 2.0 * C_IPBCLK_PERIOD * (1 SEC);
		ipb_mosi_i.ipb_strobe <= '0';
		wait for 5.0 * C_IPBCLK_PERIOD * (1 SEC);
		ipb_mosi_i.ipb_strobe <= '1';
		wait for 15.0 * C_IPBCLK_PERIOD * (1 SEC);
		ipb_mosi_i.ipb_strobe <= '0';
	end process STIM;

	-----------------------------------------------------------
	-- Entity Under Test
	-----------------------------------------------------------
	DUT : entity work.ipb_user_fifo_2
		generic map (
			addr_width => addr_width
		)
		port map (
			ipbclk     => ipbclk,
			usrclk     => usrclk,
			reset      => reset,
			ipb_mosi_i => ipb_mosi_i,
			ipb_miso_o => ipb_miso_o
		);

end architecture testbench;