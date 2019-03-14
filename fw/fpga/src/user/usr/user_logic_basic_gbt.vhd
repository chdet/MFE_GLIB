library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
--! xilinx packages
library unisim;
use unisim.vcomponents.all;
--! system packages
use work.system_flash_sram_package.all;
use work.system_pcie_package.all;
use work.system_package.all;
use work.fmc_package.all;
use work.wb_package.all;
use work.ipbus.all;
--! user packages
use work.user_package.all;
use work.user_version_package.all;

use work.ttc_pkg.all;

--! GEM packages
use work.gem_pkg.all;
use work.gem_board_config_package.all;
use work.ttc_pkg.all;
use work.mgt_pkg.all;
use work.vendor_specific_gbt_bank_package.all;

entity user_logic_gbt is
port
	(
	--================================--
	-- USER MGT REFCLKs
	--================================--
	-- BANK_112(Q0):  
	clk125_1_p	                        : in	  std_logic;  		    
	clk125_1_n	                        : in	  std_logic;  		  
	cdce_out0_p	                        : in	  std_logic;  		  
	cdce_out0_n	                        : in	  std_logic; 		  
	-- BANK_113(Q1):                 
	fmc2_clk0_m2c_xpoint2_p	            : in	  std_logic;
	fmc2_clk0_m2c_xpoint2_n	            : in	  std_logic;
	cdce_out1_p	                        : in	  std_logic;       
	cdce_out1_n	                        : in	  std_logic;         
	-- BANK_114(Q2):                 
	pcie_clk_p	                        : in	  std_logic; 			  
	pcie_clk_n	                        : in	  std_logic;			  
	cdce_out2_p  	                    : in	  std_logic;			  
	cdce_out2_n  	                    : in	  std_logic;			  
	-- BANK_115(Q3):                 
	clk125_2_i                          : in	  std_logic;		      
	fmc1_gbtclk1_m2c_p	                : in	  std_logic;     
	fmc1_gbtclk1_m2c_n	                : in	  std_logic;     
	-- BANK_116(Q4):                 
	fmc1_gbtclk0_m2c_p	                : in	  std_logic;	  
	fmc1_gbtclk0_m2c_n	                : in	  std_logic;	  
	cdce_out3_p	                        : in	  std_logic;		  
	cdce_out3_n	                        : in	  std_logic;		    
	--================================--
	-- USER FABRIC CLOCKS
	--================================--
	xpoint1_clk3_p	                    : in	  std_logic;		   
	xpoint1_clk3_n	                    : in	  std_logic;		   
	------------------------------------  
	cdce_out4_p                         : in	  std_logic;                
	cdce_out4_n                         : in	  std_logic;              
	------------------------------------
	amc_tclkb_o					        : out	  std_logic;
	------------------------------------      
	fmc1_clk0_m2c_xpoint2_p	            : in	  std_logic;
	fmc1_clk0_m2c_xpoint2_n	            : in	  std_logic;
	fmc1_clk1_m2c_p		                : in	  std_logic;	
	fmc1_clk1_m2c_n		                : in	  std_logic;	
	fmc1_clk2_bidir_p	                : in	  std_logic;	
	fmc1_clk2_bidir_n	                : in	  std_logic;	
	fmc1_clk3_bidir_p	                : in	  std_logic;	
	fmc1_clk3_bidir_n	                : in	  std_logic;	
	------------------------------------
	fmc2_clk1_m2c_p	                    : in	  std_logic;		
	fmc2_clk1_m2c_n	                    : in	  std_logic;		
	--================================--
	-- GBT PHASE MONITORING MGT REFCLK
	--================================--
	cdce_out0_gtxe1_o                   : out   std_logic;  		  
	cdce_out3_gtxe1_o                   : out   std_logic;  
	--================================--
	-- AMC PORTS
	--================================--
	amc_port_tx_p				        : out	  std_logic_vector(1 to 15);
	amc_port_tx_n				        : out	  std_logic_vector(1 to 15);
	amc_port_rx_p				        : in	  std_logic_vector(1 to 15);
	amc_port_rx_n				        : in	  std_logic_vector(1 to 15);
	------------------------------------
	amc_port_tx_out			            : out	  std_logic_vector(17 to 20);	
	amc_port_tx_in				        : in	  std_logic_vector(17 to 20);		
	amc_port_tx_de				        : out	  std_logic_vector(17 to 20);	
	amc_port_rx_out			            : out	  std_logic_vector(17 to 20);	
	amc_port_rx_in				        : in	  std_logic_vector(17 to 20);	
	amc_port_rx_de				        : out	  std_logic_vector(17 to 20);	
	--================================--
	-- SFP QUAD
	--================================--
	sfp_tx_p						    : out	  std_logic_vector(1 to 4);
	sfp_tx_n						    : out	  std_logic_vector(1 to 4);
	sfp_rx_p						    : in	  std_logic_vector(1 to 4);
	sfp_rx_n						    : in	  std_logic_vector(1 to 4);
	sfp_mod_abs					        : in	  std_logic_vector(1 to 4);		
	sfp_rxlos					        : in	  std_logic_vector(1 to 4);		
	sfp_txfault					        : in	  std_logic_vector(1 to 4);				
	--================================--
	-- FMC1
	--================================--
	fmc1_tx_p					        : out	  std_logic_vector(1 to 4);
	fmc1_tx_n                           : out	  std_logic_vector(1 to 4);
	fmc1_rx_p                           : in	  std_logic_vector(1 to 4);
	fmc1_rx_n                           : in	  std_logic_vector(1 to 4);
	------------------------------------
	fmc1_io_pin					        : inout fmc_io_pin_type;
	------------------------------------
	fmc1_clk_c2m_p				        : out	  std_logic_vector(0 to 1);
	fmc1_clk_c2m_n				        : out	  std_logic_vector(0 to 1);
	fmc1_present_l				        : in	  std_logic;
	--================================--
	-- FMC2
	--================================--
	fmc2_io_pin					        : inout fmc_io_pin_type;
	------------------------------------
	fmc2_clk_c2m_p				        : out	  std_logic_vector(0 to 1);
	fmc2_clk_c2m_n				        : out	  std_logic_vector(0 to 1);
	fmc2_present_l				        : in	  std_logic;
	--================================--      
	-- SYSTEM GBE   
	--================================--      
	sys_eth_amc_p1_tx_p		            : in	  std_logic;	
	sys_eth_amc_p1_tx_n		            : in	  std_logic;	
	sys_eth_amc_p1_rx_p		            : out	  std_logic;	
	sys_eth_amc_p1_rx_n		            : out	  std_logic;	
	------------------------------------
	user_mac_syncacqstatus_i            : in	  std_logic_vector(0 to 3);
	user_mac_serdes_locked_i            : in	  std_logic_vector(0 to 3);
	--================================--   										
	-- SYSTEM PCIe				   												
	--================================--   
	sys_pcie_mgt_refclk_o	            : out	  std_logic;	  
	user_sys_pcie_dma_clk_i             : in	  std_logic;	  
	------------------------------------
	sys_pcie_amc_tx_p		            : in	  std_logic_vector(0 to 3);    
	sys_pcie_amc_tx_n		            : in	  std_logic_vector(0 to 3);    
	sys_pcie_amc_rx_p		            : out	  std_logic_vector(0 to 3);    
	sys_pcie_amc_rx_n		            : out	  std_logic_vector(0 to 3);    
	------------------------------------
	user_sys_pcie_slv_o	                : out   R_slv_to_ezdma2;									   	
	user_sys_pcie_slv_i	                : in    R_slv_from_ezdma2; 	   						    
	user_sys_pcie_dma_o                 : out   R_userDma_to_ezdma2_array  (1 to 7);		   					
	user_sys_pcie_dma_i                 : in 	  R_userDma_from_ezdma2_array(1 to 7);		   	
	user_sys_pcie_int_o 	            : out   R_int_to_ezdma2;									   	
	user_sys_pcie_int_i 	            : in    R_int_from_ezdma2; 								    
	user_sys_pcie_cfg_i 	            : in	  R_cfg_from_ezdma2; 								   	
	--================================--
	-- SRAMs
	--================================--
	user_sram_control_o		            : out	  userSramControlR_array(1 to 2);
	user_sram_addr_o			        : out	  array_2x21bit;
	user_sram_wdata_o			        : out	  array_2x36bit;
	user_sram_rdata_i			        : in 	  array_2x36bit;
	------------------------------------
	sram1_bwa                           : out	  std_logic;  
	sram1_bwb                           : out	  std_logic;  
	sram1_bwc                           : out	  std_logic;  
	sram1_bwd                           : out	  std_logic;  
	sram2_bwa                           : out	  std_logic;  
	sram2_bwb                           : out	  std_logic;  
	sram2_bwc                           : out	  std_logic;  
	sram2_bwd                           : out	  std_logic;    
	--================================--               
	-- CLK CIRCUITRY              
	--================================--    
	fpga_clkout_o	  			        : out	  std_logic;	
	------------------------------------
	sec_clk_o		                    : out	  std_logic;	
	------------------------------------
	user_cdce_locked_i			        : in	  std_logic;
	user_cdce_sync_done_i		    	: in	  std_logic;
	user_cdce_sel_o			            : out	  std_logic;
	user_cdce_sync_o			        : out	  std_logic;
	--================================--  
	-- USER BUS  
	--================================--       
	wb_miso_o				            : out	  wb_miso_bus_array(0 to number_of_wb_slaves-1);
	wb_mosi_i				            : in 	  wb_mosi_bus_array(0 to number_of_wb_slaves-1);
	------------------------------------
	ipb_clk_i				            : in 	  std_logic;
	ipb_miso_o			                : out	  ipb_rbus_array(0 to number_of_ipb_slaves-1);
	ipb_mosi_i			                : in 	  ipb_wbus_array(0 to number_of_ipb_slaves-1);   
	--================================--
	-- VARIOUS
	--================================--
	reset_i						        : in	  std_logic;	    
	user_clk125_i                  		: in	  std_logic;       
	user_clk200_i                  		: in	  std_logic;       
	------------------------------------   
	sn			                        : in    std_logic_vector(7 downto 0);	   
	------------------------------------   
	amc_slot_i						    : in    std_logic_vector( 3 downto 0);
	mac_addr_o 					        : out   std_logic_vector(47 downto 0);
	ip_addr_o					        : out   std_logic_vector(31 downto 0);
	------------------------------------	
	user_v6_led_o                       : out	  std_logic_vector(1 to 2)
	);                         	
end user_logic_gbt;
							
architecture user_logic_arch of user_logic_gbt is                    	

	signal reset_pwrup : std_logic;

	signal ctrl_reg		               : array_32x32bit;
	signal stat_reg		               : array_32x32bit;

	signal led1									: std_logic;
	signal led2									: std_logic;

	signal mgtclk : std_logic;
	signal usrclk_10 : std_logic;
	signal usrclk_5 : std_logic;
	signal clk240_ttc : std_logic;
    signal ttc_clcks : t_ttc_clks;
    signal ttc_clcks_locked : std_logic;

    signal gtx_reset, gtx_reset_sync : std_logic;
    signal gtx_config, gtx_status, gtx_prbs_pattern, gtx_prbs_errors : std_logic_vector(31 downto 0);

    signal reprogram_oh : std_logic := '0';

    --== Slow control ==--
    signal vfat3_sc_status              : t_vfat_slow_control_status; 
    --signal ttc_cmd              : t_ttc_cmds;
	------------------------------------

    --== GTX <-> GBT ==--
    signal mgt_gbt_tx_word_clk 			: std_logic_vector(0 downto 0);
    signal mgt_gbt_tx_word 				: std_logic_vector(WORD_WIDTH-1 downto 0);

    signal mgt_gbt_rx_word_clk 			: std_logic_vector(0 downto 0);
    signal mgt_gbt_rx_word 				: std_logic_vector(WORD_WIDTH-1 downto 0);

    signal gem_gt_gbt_rx_data   		: t_gt_gbt_data_arr(0 downto 0);
    signal gem_gt_gbt_tx_data   		: t_gt_gbt_data_arr(0 downto 0);
    signal gem_gt_gbt_rx_clk    		: std_logic_vector(0 downto 0);
    signal gem_gt_gbt_tx_clk    		: std_logic_vector(0 downto 0);
	------------------------------------

	--== GBT ==--
	signal gbt_manual_reset 			: std_logic := '0';
	signal gbt_link_status         	    : t_gbt_link_status_arr(0 downto 0);
	signal loopback_gbt_test_en         : std_logic := '0'; 

	signal gbt_tx_data              	: t_gbt_frame_array(0 downto 0);    
    signal gbt_tx_gearbox_aligned   	: std_logic_vector(0 downto 0);
    signal gbt_tx_gearbox_align_done 	: std_logic_vector(0 downto 0);
            
    signal gbt_rx_data           	    : t_gbt_frame_array(0 downto 0);    
    signal gbt_rx_valid           	    : std_logic_vector(0 downto 0);
    signal gbt_rx_header                : std_logic_vector(0 downto 0);
    signal gbt_rx_header_locked         : std_logic_vector(0 downto 0);
    signal gbt_rx_bitslip_nbr           : rxBitSlipNbr_mxnbit_A(0 downto 0);
	------------------------------------

	--== GBT elinks ==--
    signal gbt_ready                    : std_logic_vector(0 downto 0);
    signal sca_tx_data                  : t_std2_array(0 downto 0);
    signal sca_rx_data                  : t_std2_array(0 downto 0);
    signal gbt_ic_tx_data               : t_std2_array(0 downto 0);
    signal gbt_ic_rx_data               : t_std2_array(0 downto 0);
    signal promless_tx_data             : std_logic_vector(15 downto 0);
    signal oh_fpga_tx_data              : t_std8_array(0 downto 0);
    signal oh_fpga_rx_data              : t_std8_array(0 downto 0);
    signal vfat3_tx_data                : t_vfat3_elinks_arr(0 downto 0);
    signal vfat3_rx_data                : t_vfat3_elinks_arr(0 downto 0);

    signal tst_gbt_tx_data_arr 			: t_gbt_frame_array(2 downto 0);
	------------------------------------
	
	--== GBT Link Mux ==--
    signal gbt_rx_data_wrapper          : t_gbt_frame_array(2 downto 0);    
	signal gbt_tx_data_wrapper          : t_gbt_frame_array(2 downto 0);    
	signal gbt_link_status_wrapper      : t_gbt_link_status_arr(2 downto 0);
    signal gbt_ic_tx_data_wrapper       : t_std2_array(2 downto 0);
    signal gbt_ic_rx_data_wrapper       : t_std2_array(2 downto 0);
    signal gbt_ready_wrapper            : std_logic_vector(2 downto 0);
	------------------------------------

	--== GEM Loader ==--
    signal to_gem_loader : t_to_gem_loader;
    signal from_gem_loader : t_from_gem_loader;
    
    signal sram_rdata : std_logic_vector(35 downto 0);
    signal sram_addr  : std_logic_vector(20 downto 0);
    signal sram_cs    : std_logic;
	------------------------------------

	attribute dont_touch : string;
	attribute dont_touch of from_gem_loader : signal is "true"; 

begin

	--#############################--
	--## GLIB IP & MAC ADDRESSES ##--
	--#############################--

	ip_rarp: if force_rarp = true generate
	ip_addr_o				               <= x"00000000";
	end generate ip_rarp;

	ip_user: if force_rarp = false generate 
	ip_addr_o				               <= x"c0a800a"     & amc_slot_i;  -- 192.168.0.[160:175]
	end generate ip_user;

	-- default mac addr when eeprom with invalid contents
	mac_addr_o 				               <= x"080030F100a" & amc_slot_i;  -- 08:00:30:F1:00:0[A0:AF] 

	--#############################--
	--## USER LOGIC              ##--
	--#############################--

	--===========================================--
	user_mmcm : entity work.clk_wiz_10MHZ
	--===========================================--
	port map (
    clk240_ttc => clk240_ttc,
    usrclk_10  => usrclk_10,
    reset      => reset_i,
    locked     => open
    );

	--===========================================--
	ipb_user_fifo_inst : entity work.ipb_user_fifo
	--===========================================--
	port map (
	ipbclk        		=> ipb_clk_i,
	usrclk     	  		=> usrclk_10,
	reset      	  		=> reset_i,
	ipb_mosi_i 	  		=> ipb_mosi_i(user_ipb_fifo),
	ipb_miso_o 	  		=> ipb_miso_o(user_ipb_fifo)
	);	
	--===========================================--

	--===========================================--
	stat_regs_inst: entity work.ipb_user_status_regs
	--===========================================--
	port map
	(
	clk					=> ipb_clk_i,
	reset				=> reset_i,
	ipb_mosi_i			=> ipb_mosi_i(user_ipb_stat_regs),
	ipb_miso_o			=> ipb_miso_o(user_ipb_stat_regs),
	regs_i				=> stat_reg
	);
	--===========================================--

	stat_reg(0)			<= gtx_status;
	stat_reg(1) 		<= gtx_prbs_errors;

	--===========================================--
	ctrl_regs_inst: entity work.ipb_user_control_regs
	--===========================================--
	port map
	(
	clk					=> ipb_clk_i,
	reset				=> reset_i,
	ipb_mosi_i			=> ipb_mosi_i(user_ipb_ctrl_regs),
	ipb_miso_o			=> ipb_miso_o(user_ipb_ctrl_regs),
	regs_o				=> ctrl_reg
	);
	--===========================================--

	gtx_config 			<= ctrl_reg(0);
	gtx_reset 			<= ctrl_reg(1)(0);
	gtx_reset_sync 		<= ctrl_reg(1)(1);
	gbt_manual_reset 	<= ctrl_reg(1)(2);
	gtx_prbs_pattern 	<= ctrl_reg(2);
    reprogram_oh 		<= ctrl_reg(3)(0);

	--===========================================--
	-- register mapping
	--===========================================--
	led1 			<= gtx_status(2);
	--led2 			<= gbt_link_status(0).gbt_rx_ready;
	led2			<= gbt_ready_wrapper(0);
	--===========================================--

	--===========================================--
	-- I/O mapping
	--===========================================--
	user_v6_led_o(1) <= led1;
	user_v6_led_o(2) <= led2;
	--===========================================--

	--================================--
    -- Power-on reset  
    --================================--
    
    process(ttc_clcks.clk_40) -- NOTE: using TTC clock, no nothing will work if there's no TTC clock
        variable countdown : integer := 40_000_000; -- 1s - probably way too long, but ok for now (this is only used after powerup)
    begin
        if (rising_edge(ttc_clcks.clk_40)) then
            if (countdown > 0) then
              reset_pwrup <= '1';
              countdown := countdown - 1;
            else
              reset_pwrup <= '0';
            end if;
        end if;
    end process;   

    --=========--
    --== TTC ==--
    --=========--

    i_ibufgds_clk_240_ttc : IBUFDS
    port map (
        O  => clk240_ttc,
        I  => cdce_out4_p,
        IB => cdce_out4_n
    );
    
    i_ttc_clocks : entity work.ttc_clocks
    port map (
        clk240_ttc_i => clk240_ttc,
        clk40_o      => ttc_clcks.clk_40,
        clk80_o      => ttc_clcks.clk_80,
        clk120_o     => open,
        clk160_o     => ttc_clcks.clk_160,
        clk240_o     => ttc_clcks.clk_120,
        reset_i      => '0',
        locked_o     => ttc_clcks_locked
    );

    i_oddr : ODDR
    generic map(
        DDR_CLK_EDGE => "SAME_EDGE",
        INIT => '0',
        SRTYPE => "SYNC")
    port map (
        Q => fpga_clkout_o,
        --C => ttc_clcks.clk_40,
        C => mgt_gbt_rx_word_clk(0),
        CE => '1',
        D1 => '1',
        D2 => '0',
        R => '0',
        S => '0'
    );

	--===========================================--

	--==========--
	--    GTX   --
	--==========--

	i_ibufds_gtxe1 : ibufds_gtxe1
	port map(
	o       => mgtclk,
	odiv2   => open,
	ceb     => '0',
	i       => cdce_out0_p,
	ib      => cdce_out0_n
	);

	i_gtx_single : entity work.gtx_single
	port map (
		mgt_clk_i               => mgtclk,

		mgt_rx_p_i              => sfp_rx_p(4),
		mgt_rx_n_i              => sfp_rx_n(4),
		mgt_tx_p_o              => sfp_tx_p(4),
		mgt_tx_n_o              => sfp_tx_n(4),

		rx_reset_i              => gtx_reset or reset_pwrup,
		tx_reset_i              => gtx_reset or reset_pwrup,
		rx_sync_reset_i         => gtx_reset_sync,
		tx_sync_reset_i         => gtx_reset_sync,

		TX_WORDCLK_O            => mgt_gbt_tx_word_clk(0),
		RX_WORDCLK_O            => mgt_gbt_rx_word_clk(0),

		txusrclk_i              => ttc_clcks.clk_120,

		mgt_tx_word_i           => mgt_gbt_tx_word,
		mgt_rx_word_o           => mgt_gbt_rx_word,

		rx_eq_mix_i             => gtx_config(4 downto 2),
		tx_conf_diff_i          => gtx_config(8 downto 5),
		tx_post_emph_i          => gtx_config(13 downto 9),
		tx_pre_emph_i           => gtx_config(17 downto 14),

		tx_reset_done_o         => gtx_status(0),
		rx_reset_done_o         => gtx_status(1),
		ready_o                 => gtx_status(2),

		tx_pol_i                => gtx_config(0),
		rx_pol_i                => gtx_config(1),

		GBTTX_MGTTX_RDY_O       => gtx_status(3),
		GBTRX_MGTRX_RDY_O       => gtx_status(4),
		GBTRX_RXWORDCLK_READY_O => gtx_status(5),
		prbs_pattern_i_p        => gtx_prbs_pattern(2 downto 0),
		TXPRBSFORCEERR_IN       => gtx_prbs_pattern(3),
		PRBSCNTRESET_IN         => gtx_prbs_pattern(4),
		RXPRBSERR_OUT           => gtx_prbs_errors(0),
		LOOPBACK_IN             => gtx_prbs_pattern(8 downto 5)
	);

	-- GTX mapping to GEM links (GBT)
	gem_gt_gbt_tx_clk     <= mgt_gbt_tx_word_clk;
	gem_gt_gbt_rx_clk     <= mgt_gbt_rx_word_clk;

	mgt_gbt_tx_word       <= gem_gt_gbt_tx_data(0);
	gem_gt_gbt_rx_data(0) <= mgt_gbt_rx_word;

	--===========================================--


	--==========--
	--    GBT   --
	--==========--


	i_gbt : entity work.gbt
	    generic map(
	        GBT_BANK_ID     => 0,
	        NUM_LINKS       => 1,	-- Only using one single GBT on the OH
	        TX_OPTIMIZATION => 1,
	        RX_OPTIMIZATION => 0,
	        TX_ENCODING     => 0,
	        RX_ENCODING     => 0
	    )
	    port map(
	        reset_i                     => reset_i or reset_pwrup,
	        cnt_reset_i                 => gbt_manual_reset,

	        tx_frame_clk_i              => ttc_clcks.clk_40,
	        rx_frame_clk_i              => ttc_clcks.clk_40,
	        rx_word_common_clk_i        => ttc_clcks.clk_120,

	        tx_word_clk_arr_i           => gem_gt_gbt_tx_clk,
	        rx_word_clk_arr_i           => gem_gt_gbt_rx_clk,

	        tx_ready_arr_i              => (others => '1'),
	        tx_we_arr_i                 => (others => '1'),

	        tx_data_arr_i               => gbt_tx_data,
	        tx_gearbox_aligned_arr_o    => gbt_tx_gearbox_aligned,
	        tx_gearbox_align_done_arr_o => gbt_tx_gearbox_align_done,

	        rx_frame_clk_rdy_arr_i      => (others => '1'),
	        rx_word_clk_rdy_arr_i       => (others => '1'),

	        rx_bitslip_nbr_arr_o        => gbt_rx_bitslip_nbr,
	        rx_header_arr_o             => gbt_rx_header,
	        rx_header_locked_arr_o      => gbt_rx_header_locked,
	        rx_data_valid_arr_o         => gbt_rx_valid,
	        rx_data_arr_o               => gbt_rx_data,

	        mgt_rx_rdy_arr_i            => (others => '1'),
	        mgt_tx_data_arr_o           => gem_gt_gbt_tx_data,
	        mgt_rx_data_arr_i           => gem_gt_gbt_rx_data,

	        link_status_arr_o           => gbt_link_status
	    );

	gtx_status(6) <= gbt_link_status(0).gbt_rx_ready;
	gtx_status(7) <= gbt_ready_wrapper(0);
	gtx_status(8) <= '1';

 	gbt_rx_data_wrapper(0) 		<= gbt_rx_data(0);
	gbt_tx_data(0)				<= gbt_tx_data_wrapper(0);     
	gbt_link_status_wrapper(0)	<= gbt_link_status(0);
	--gbt_ic_tx_data_wrapper(0)	<= gbt_ic_tx_data(0); 
	--gbt_ic_rx_data_wrapper(0)	<= gbt_ic_rx_data(0); 
	--gbt_ready_wrapper			<= gbt_ready(0) & "00";      

	i_gbt_link_mux : entity work.gbt_link_mux(gbt_link_mux_ge21)
	    generic map(
	        g_NUM_OF_OHs  => 1
	    )
	    port map(
	        gbt_frame_clk_i             => ttc_clcks.clk_40,

	        gbt_rx_data_arr_i           => gbt_rx_data_wrapper,--
	        gbt_tx_data_arr_o           => gbt_tx_data_wrapper,--
	        gbt_link_status_arr_i       => gbt_link_status_wrapper,--

	        link_test_mode_i            => loopback_gbt_test_en,
	        use_oh_vfat3_connectors_i   => '0',
	        use_v3b_mapping_i           => '0',

	        sca_tx_data_arr_i           => sca_tx_data,
	        sca_rx_data_arr_o           => sca_rx_data,

	        gbt_ic_tx_data_arr_i        => gbt_ic_tx_data_wrapper,--
	        gbt_ic_rx_data_arr_o        => gbt_ic_rx_data_wrapper,--

	        promless_tx_data_i          => promless_tx_data,

	        oh_fpga_tx_data_arr_i       => oh_fpga_tx_data,
	        oh_fpga_rx_data_arr_o       => oh_fpga_rx_data,

	        vfat3_tx_data_arr_i         => vfat3_tx_data,
	        vfat3_rx_data_arr_o         => vfat3_rx_data,

	        gbt_ready_arr_o             => gbt_ready_wrapper,--

	        tst_gbt_rx_data_arr_o       => open,--
	        tst_gbt_tx_data_arr_i       => tst_gbt_tx_data_arr,--
	        tst_gbt_ready_arr_o         => open--
	    );

	--===========================================--



    --===================--
    --    Slow Control   --
    --===================--

    i_slow_control : entity work.slow_control
        generic map(
            g_NUM_OF_OHs => 1,
            g_DEBUG      => false
        )
        port map(
            reset_i             => reset_i or reset_pwrup,
            ttc_clk_i           => ttc_clcks,

            gbt_rx_ready_i      => gbt_ready_wrapper,
            gbt_rx_sca_elinks_i => sca_rx_data,
            gbt_tx_sca_elinks_o => sca_tx_data,
            gbt_rx_ic_elinks_i  => gbt_ic_rx_data_wrapper,
            gbt_tx_ic_elinks_o  => gbt_ic_tx_data_wrapper,

            ipb_reset_i         => reset_i or reset_pwrup,
            ipb_clk_i           => ipb_clk_i,
            ipb_miso_o          => ipb_miso_o(user_ipb_slow_control),
            ipb_mosi_i          => ipb_mosi_i(user_ipb_slow_control)
        );
	--===========================================--

    --===========================--
    --    OH FPGA programming    --
    --===========================--

    i_oh_fpga_loader : entity work.oh_fpga_loader
        port map(
            reset_i           => reset_i or reset_pwrup,
            gbt_clk_i         => ttc_clcks.clk_40,
            loader_clk_i      => ttc_clcks.clk_80,
            to_gem_loader_o   => to_gem_loader,
            from_gem_loader_i => from_gem_loader,
            elink_data_o      => promless_tx_data,
            hard_reset_i      => reprogram_oh
        );

    --================================--

	--================--
    --== GEM loader ==--
    --================--

    sram1_bwa <= '0';
    sram1_bwb <= '0';
    sram1_bwc <= '0';
    sram1_bwd <= '0';

    user_sram_addr_o(1)  <= sram_addr;
    user_sram_wdata_o(1) <= (others => '0');
    sram_rdata           <= user_sram_rdata_i(1);
    user_sram_control_o(1).reset       <= '0';
    user_sram_control_o(1).clk         <= to_gem_loader.clk;
    user_sram_control_o(1).writeEnable <= '0';
    user_sram_control_o(1).cs          <= sram_cs;

    i_gem_loader : entity work.gem_loader
    port map ( 
        clk_i => to_gem_loader.clk,
        en_i  => to_gem_loader.en,
        
        sram_rdata_i => sram_rdata(31 downto 0),
        sram_addr_o  => sram_addr,
        sram_cs_o    => sram_cs,

        ready_o => from_gem_loader.ready,
        data_o  => from_gem_loader.data,
        valid_o => from_gem_loader.valid,
        first_o => from_gem_loader.first,
        last_o  => from_gem_loader.last,
        error_o => from_gem_loader.error
    );

    --===========================================--

    --================================--
    -- TTC  
    --================================--
    -- TODO: NECESSARY ???

    --i_ttc : entity work.ttc
    --    port map(
    --        reset_i             => reset,
    --        ttc_clks_i          => ttc_clocks_i,
    --        ttc_clks_locked_i   => ttc_clocks_locked_i,
    --        ttc_data_p_i        => ttc_data_p_i,
    --        ttc_data_n_i        => ttc_data_n_i,
    --        ttc_cmds_o          => ttc_cmd,
    --        ttc_daq_cntrs_o     => ttc_counters,
    --        ttc_status_o        => ttc_status,
    --        l1a_led_o           => led_l1a_o,
    --        ipb_reset_i         => ipb_reset,
    --        ipb_clk_i           => ipb_clk_i,
    --        ipb_mosi_i          => ipb_mosi_arr_i(C_IPB_SLV.ttc),
    --        ipb_miso_o          => ipb_miso_arr(C_IPB_SLV.ttc)
    --    );
    
    --================================--

end user_logic_arch;