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

--
use work.user_addr_decode.all;
--

--! user packages
use work.user_package.all;
use work.user_version_package.all;

--! GEM packages
use work.gem_pkg.all;
use work.gem_board_config_package.all;
use work.ttc_pkg.all;
use work.mgt_pkg.all;

entity user_logic is
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
    cdce_out2_p  	                     : in	  std_logic;			  
    cdce_out2_n  	                     : in	  std_logic;			  
    -- BANK_115(Q3):                 
    clk125_2_i                          : in	  std_logic;		      
    fmc1_gbtclk1_m2c_p	               : in	  std_logic;     
    fmc1_gbtclk1_m2c_n	               : in	  std_logic;     
    -- BANK_116(Q4):                 
    fmc1_gbtclk0_m2c_p	               : in	  std_logic;	  
    fmc1_gbtclk0_m2c_n	               : in	  std_logic;	  
    cdce_out3_p	                        : in	  std_logic;		  
    cdce_out3_n	                        : in	  std_logic;		    
    --================================--
    -- USER FABRIC CLOCKS
    --================================--
    xpoint1_clk3_p	                     : in	  std_logic;		   
    xpoint1_clk3_n	                     : in	  std_logic;		   
    ------------------------------------  
    cdce_out4_p                         : in	  std_logic;                
    cdce_out4_n                         : in	  std_logic;              
    ------------------------------------
    amc_tclkb_o					            : out	  std_logic;
    ------------------------------------      
    fmc1_clk0_m2c_xpoint2_p	            : in	  std_logic;
    fmc1_clk0_m2c_xpoint2_n	            : in	  std_logic;
    fmc1_clk1_m2c_p		               : in	  std_logic;	
    fmc1_clk1_m2c_n		               : in	  std_logic;	
    fmc1_clk2_bidir_p		               : in	  std_logic;	
    fmc1_clk2_bidir_n		               : in	  std_logic;	
    fmc1_clk3_bidir_p		               : in	  std_logic;	
    fmc1_clk3_bidir_n		               : in	  std_logic;	
    ------------------------------------
    fmc2_clk1_m2c_p	                  : in	  std_logic;		
    fmc2_clk1_m2c_n	                  : in	  std_logic;		
	--================================--
	-- GBT PHASE MONITORING MGT REFCLK
	--================================--
    cdce_out0_gtxe1_o                   : out   std_logic;  		  
    cdce_out3_gtxe1_o                   : out   std_logic;  
	--================================--
	-- AMC PORTS
	--================================--
    amc_port_tx_p				            : out	  std_logic_vector(1 to 15);
	amc_port_tx_n				            : out	  std_logic_vector(1 to 15);
	amc_port_rx_p				            : in	  std_logic_vector(1 to 15);
	amc_port_rx_n				            : in	  std_logic_vector(1 to 15);
	------------------------------------
	amc_port_tx_out			            : out	  std_logic_vector(17 to 20);	
	amc_port_tx_in				            : in	  std_logic_vector(17 to 20);		
	amc_port_tx_de				            : out	  std_logic_vector(17 to 20);	
	amc_port_rx_out			            : out	  std_logic_vector(17 to 20);	
	amc_port_rx_in				            : in	  std_logic_vector(17 to 20);	
	amc_port_rx_de				            : out	  std_logic_vector(17 to 20);	
	--================================--
	-- SFP QUAD
	--================================--
	sfp_tx_p						            : out	  std_logic_vector(1 to 4);
	sfp_tx_n						            : out	  std_logic_vector(1 to 4);
	sfp_rx_p						            : in	  std_logic_vector(1 to 4);
	sfp_rx_n						            : in	  std_logic_vector(1 to 4);
	sfp_mod_abs					            : in	  std_logic_vector(1 to 4);		
	sfp_rxlos					            : in	  std_logic_vector(1 to 4);		
	sfp_txfault					            : in	  std_logic_vector(1 to 4);				
	--================================--
	-- FMC1
	--================================--
	fmc1_tx_p					            : out	  std_logic_vector(1 to 4);
	fmc1_tx_n                           : out	  std_logic_vector(1 to 4);
	fmc1_rx_p                           : in	  std_logic_vector(1 to 4);
	fmc1_rx_n                           : in	  std_logic_vector(1 to 4);
	------------------------------------
	fmc1_io_pin					            : inout fmc_io_pin_type;
	------------------------------------
	fmc1_clk_c2m_p				            : out	  std_logic_vector(0 to 1);
	fmc1_clk_c2m_n				            : out	  std_logic_vector(0 to 1);
	fmc1_present_l				            : in	  std_logic;
	--================================--
	-- FMC2
	--================================--
	fmc2_io_pin					            : inout fmc_io_pin_type;
	------------------------------------
	fmc2_clk_c2m_p				            : out	  std_logic_vector(0 to 1);
	fmc2_clk_c2m_n				            : out	  std_logic_vector(0 to 1);
	fmc2_present_l				            : in	  std_logic;
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
	sys_pcie_amc_tx_p		               : in	  std_logic_vector(0 to 3);    
    sys_pcie_amc_tx_n		               : in	  std_logic_vector(0 to 3);    
    sys_pcie_amc_rx_p		               : out	  std_logic_vector(0 to 3);    
    sys_pcie_amc_rx_n		               : out	  std_logic_vector(0 to 3);    
    ------------------------------------
	user_sys_pcie_slv_o	               : out   R_slv_to_ezdma2;									   	
	user_sys_pcie_slv_i	               : in    R_slv_from_ezdma2; 	   						    
	user_sys_pcie_dma_o                 : out   R_userDma_to_ezdma2_array  (1 to 7);		   					
	user_sys_pcie_dma_i                 : in 	  R_userDma_from_ezdma2_array(1 to 7);		   	
	user_sys_pcie_int_o 	               : out   R_int_to_ezdma2;									   	
	user_sys_pcie_int_i 	               : in    R_int_from_ezdma2; 								    
	user_sys_pcie_cfg_i 	               : in	  R_cfg_from_ezdma2; 								   	
	--================================--
	-- SRAMs
	--================================--
	user_sram_control_o		            : out	  userSramControlR_array(1 to 2);
	user_sram_addr_o			            : out	  array_2x21bit;
	user_sram_wdata_o			            : out	  array_2x36bit;
	user_sram_rdata_i			            : in 	  array_2x36bit;
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
    fpga_clkout_o	  			            : out	  std_logic;	
    ------------------------------------
    sec_clk_o		                     : out	  std_logic;	
	------------------------------------
	user_cdce_locked_i			         : in	  std_logic;
	user_cdce_sync_done_i					: in	  std_logic;
	user_cdce_sel_o			            : out	  std_logic;
	user_cdce_sync_o			            : out	  std_logic;
	--================================--  
	-- USER BUS  
	--================================--       
	wb_miso_o				               : out	  wb_miso_bus_array(0 to number_of_wb_slaves-1);
	wb_mosi_i				               : in 	  wb_mosi_bus_array(0 to number_of_wb_slaves-1);
	------------------------------------
	ipb_clk_i				               : in 	  std_logic;
	ipb_miso_o			                  : out	  ipb_rbus_array(0 to number_of_ipb_slaves-1);
	ipb_mosi_i			                  : in 	  ipb_wbus_array(0 to number_of_ipb_slaves-1);   
    --================================--
	-- VARIOUS
	--================================--
    reset_i						            : in	  std_logic;	    
	user_clk125_i                  		: in	  std_logic;       
    user_clk200_i                  		: in	  std_logic;       
    ------------------------------------   
    sn			                           : in    std_logic_vector(7 downto 0);	   
    ------------------------------------   
    amc_slot_i									: in    std_logic_vector( 3 downto 0);
	mac_addr_o 					            : out   std_logic_vector(47 downto 0);
    ip_addr_o					            : out   std_logic_vector(31 downto 0);
    ------------------------------------	
    user_v6_led_o                       : out	  std_logic_vector(1 to 2)
);                         	
end user_logic;
							
architecture user_logic_arch of user_logic is                    	

    -- Reset
    signal reset_pwrup : std_logic;

    -- TTC
    signal clk240_ttc : std_logic;

    signal ttc_clcks : t_ttc_clks;
    signal ttc_clcks_locked : std_logic;

    -- GTX GBT
    signal mgt_tx_serial_arr : t_mgt_tx_serial_arr(0 to 2);
    signal mgt_rx_serial_arr : t_mgt_rx_serial_arr(0 to 2);

    signal mgt_gbt_tx_word_clk_arr : std_logic_vector(0 to 2);
    signal mgt_gbt_tx_word_arr : t_mgt_gbt_word_arr(0 to 2);

    signal mgt_gbt_rx_word_clk_arr : std_logic_vector(0 to 2);
    signal mgt_gbt_rx_word_arr : t_mgt_gbt_word_arr(0 to 2);

    signal gtx_reset, gtx_reset_sync : std_logic;
    signal gtx_config, gtx_status, gtx_prbs_pattern, gtx_prbs_errors : std_logic_vector(31 downto 0);

    -- Trigger RX GTX / GTH links (3.2Gbs, 16bit @ 160MHz w/ 8b10b encoding)
    signal gem_gt_trig0_rx_clk_arr  : std_logic_vector(CFG_NUM_OF_OHs - 1 downto 0);
    signal gem_gt_trig0_rx_data_arr : t_gt_8b10b_rx_data_arr(CFG_NUM_OF_OHs - 1 downto 0);
    signal gem_gt_trig1_rx_clk_arr  : std_logic_vector(CFG_NUM_OF_OHs - 1 downto 0);
    signal gem_gt_trig1_rx_data_arr : t_gt_8b10b_rx_data_arr(CFG_NUM_OF_OHs - 1 downto 0);

    -- GBT GTX/GTH links (4.8Gbs, 40bit @ 120MHz w/o 8b10b encoding)
    signal gem_gt_gbt_rx_data_arr   : t_gt_gbt_data_arr(CFG_NUM_OF_OHs * 3 - 1 downto 0);
    signal gem_gt_gbt_tx_data_arr   : t_gt_gbt_data_arr(CFG_NUM_OF_OHs * 3 - 1 downto 0);
    signal gem_gt_gbt_rx_clk_arr    : std_logic_vector(CFG_NUM_OF_OHs * 3 - 1 downto 0);
    signal gem_gt_gbt_tx_clk_arr    : std_logic_vector(CFG_NUM_OF_OHs * 3 - 1 downto 0);
    signal gth_gbt_common_rxusrclk  : std_logic;

    -- IPbus
    signal ipb_miso_arr : ipb_rbus_array(number_of_ipb_slaves - 1 downto 0);
    signal ipb_mosi_arr : ipb_wbus_array(number_of_ipb_slaves - 1 downto 0);

    signal daq_clk_bufg : std_logic;
    signal daq_clk_locked : std_logic;
    signal daq_to_daqlink : t_daq_to_daqlink;
    signal daqlink_to_daq : t_daqlink_to_daq;

    -- GEM lodaer
    signal to_gem_loader : t_to_gem_loader;
    signal from_gem_loader : t_from_gem_loader;
    
    signal sram_rdata : std_logic_vector(35 downto 0);
    signal sram_addr  : std_logic_vector(20 downto 0);
    signal sram_cs    : std_logic;

-----
signal ctrl_reg		               : array_32x32bit;
signal stat_reg		               : array_32x32bit;


begin

--
-- Ctrl & Status
--

	--===========================================--
	stat_regs_inst: entity work.ipb_user_status_regs
	--===========================================--
	port map
	(
		clk					=> ipb_clk_i,
		reset					=> reset_i,
		ipb_mosi_i			=> ipb_mosi_arr(C_IPB_SLV.sfp_glib_status),
		ipb_miso_o			=> ipb_miso_arr(C_IPB_SLV.sfp_glib_status),
		regs_i				=> stat_reg
	);
	--===========================================--


	--===========================================--
	ctrl_regs_inst: entity work.ipb_user_control_regs
	--===========================================--
	port map
	(
		clk					=> ipb_clk_i,
		reset					=> reset_i,
		ipb_mosi_i			=> ipb_mosi_arr(C_IPB_SLV.sfp_glib_ctrl),
		ipb_miso_o			=> ipb_miso_arr(C_IPB_SLV.sfp_glib_ctrl),
		regs_o				=> ctrl_reg
	);
	--===========================================--
stat_reg(0) <= gtx_status;
gtx_config <= ctrl_reg(0);
gtx_reset <= ctrl_reg(1)(0);
gtx_reset_sync <= ctrl_reg(1)(1);
gtx_prbs_pattern <= ctrl_reg(2);
stat_reg(1) <= gtx_prbs_errors;


    --=============================--
    --== GLIB IP & MAC Addresses ==--
    --=============================--
   
    --ip_addr_o  <= x"c0a800a"     & x"0"; --amc_slot_i;  -- 192.168.0.[160:175]
    ip_addr_o  <= x"c0a802a"     & x"0"; --amc_slot_i;  -- 192.168.2.[160:175]
    mac_addr_o <= x"080030F100a" & x"0"; --amc_slot_i;  -- 08:00:30:F1:00:0[A0:AF] 

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
        C => mgt_gbt_rx_word_clk_arr(0),
        CE => '1',
        D1 => '1',
        D2 => '0',
        R => '0',
        S => '0'
    );

    --=============--
    --== GTX GBT ==--
    --=============--
    g_mgt_serial: for i in 0 to 2 generate
        sfp_tx_p(i+1) <= mgt_tx_serial_arr(i).txp;
        sfp_tx_n(i+1) <= mgt_tx_serial_arr(i).txn;
        
        mgt_rx_serial_arr(i).rxp <= sfp_rx_p(i+1);
        mgt_rx_serial_arr(i).rxn <= sfp_rx_n(i+1);
    end generate;
    
    i_gtx_wrapper: entity work.gtx_wrapper
    port map (
        mgt_clk_p_i => cdce_out0_p,
        mgt_clk_n_i => cdce_out0_n,

        mgt_tx_arr_o => mgt_tx_serial_arr,      
        mgt_rx_arr_i => mgt_rx_serial_arr,

        rx_reset_i => gtx_reset,
        tx_reset_i => gtx_reset,
        rx_sync_reset_i => gtx_reset_sync,
        tx_sync_reset_i => gtx_reset_sync,

        tx_word_clk_arr_o => mgt_gbt_tx_word_clk_arr,
        rx_word_clk_arr_o => mgt_gbt_rx_word_clk_arr,

        txusrclk_i => ttc_clcks.clk_120,

        mgt_tx_word_arr_i => mgt_gbt_tx_word_arr,
        mgt_rx_word_arr_o => mgt_gbt_rx_word_arr,
        
        
      tx_pol_i => gtx_config(0),
      rx_pol_i => gtx_config(1),
      rx_eq_mix_i => gtx_config(4 downto 2),
      tx_conf_diff_i => gtx_config(8 downto 5),
      tx_post_emph_i => gtx_config(13 downto 9),
      tx_pre_emph_i => gtx_config(17 downto 14),

      tx_reset_done_o(0) => gtx_status(0),
      tx_reset_done_o(1 to 2) => open,
      rx_reset_done_o(0) => gtx_status(1),
      rx_reset_done_o(1 to 2) => open,
      ready_o(0)         => gtx_status(2),
      ready_o(1 to 2) => open,
      gbttx_mgttx_rdy_o(0)       => gtx_status(3),
      gbttx_mgttx_rdy_o(1 to 2) => open,
      gbtrx_mgtrx_rdy_o(0)       => gtx_status(4),
      gbtrx_mgtrx_rdy_o(1 to 2) => open,
      gbtrx_rxwordclk_ready_o(0) => gtx_status(5),
      gbtrx_rxwordclk_ready_o(1 to 2) => open,

        prbs_pattern_i_p => gtx_prbs_pattern(2 downto 0),
        TXPRBSFORCEERR_IN => gtx_prbs_pattern(3),
        PRBSCNTRESET_IN => gtx_prbs_pattern(4),
        RXPRBSERR_OUT => gtx_prbs_errors(2 downto 0),
        LOOPBACK_IN => gtx_prbs_pattern(8 downto 5)
    );

    -- GTX mapping to GEM links (GBT)
    g_mgt_gbt: for i in 0 to 2 generate
        gem_gt_gbt_tx_clk_arr(i) <= mgt_gbt_tx_word_clk_arr(i);
        mgt_gbt_tx_word_arr(i)   <= gem_gt_gbt_tx_data_arr(i);

        gem_gt_gbt_rx_clk_arr(i)  <= mgt_gbt_rx_word_clk_arr(i);
        gem_gt_gbt_rx_data_arr(i) <= mgt_gbt_rx_word_arr(i);
    end generate;

    --=============--
    --== DAQLink ==--
    --=============--

    daq_clk_bufg <= '0';
    daq_clk_locked <= '0';
    -- daq_to_daqlink
    daqlink_to_daq <= (ready => '0', almost_full => '0', disperr_cnt => x"0000", notintable_cnt => x"0000");

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
    
    --===================--
    --== GEM AMC Logic ==--
    --===================--
          
    i_gem_amc : entity work.gem_amc
        generic map(
            g_NUM_OF_OHs         => CFG_NUM_OF_OHs,
            g_USE_TRIG_LINKS     => CFG_USE_TRIG_LINKS,
            g_NUM_IPB_SLAVES     => number_of_ipb_slaves-2, ---
            g_DAQ_CLK_FREQ       => 62_500_000
        )
        port map(
            -- Resets
            reset_i                => reset_i,
            reset_pwrup_o          => reset_pwrup,

            -- TTC
            ttc_data_p_i            => amc_port_rx_p(3), --ttc_data_p_i,
            ttc_data_n_i            => amc_port_rx_n(3), --ttc_data_n_i,
            ttc_clocks_i            => ttc_clcks,
            ttc_clocks_locked_i     => ttc_clcks_locked,

            -- Trigger RX GTX / GTH links (3.2Gbs, 16bit @ 160MHz w/ 8b10b encoding)
            gt_trig0_rx_clk_arr_i   => gem_gt_trig0_rx_clk_arr,
            gt_trig0_rx_data_arr_i  => gem_gt_trig0_rx_data_arr,
            gt_trig1_rx_clk_arr_i   => gem_gt_trig1_rx_clk_arr,
            gt_trig1_rx_data_arr_i  => gem_gt_trig1_rx_data_arr,

            -- GBT DAQ + Control GTX / GTH links (4.8Gbs, 20bit @ 240MHz without encoding)
            gt_gbt_rx_data_arr_i    => gem_gt_gbt_rx_data_arr,
            gt_gbt_tx_data_arr_o    => gem_gt_gbt_tx_data_arr,
            gt_gbt_rx_clk_arr_i     => gem_gt_gbt_rx_clk_arr,
            gt_gbt_tx_clk_arr_i     => gem_gt_gbt_tx_clk_arr,
            gt_gbt_rx_common_clk_i  => ttc_clcks.clk_120,

            -- IPbus
            ipb_reset_i             => reset_i or reset_pwrup,
            ipb_clk_i               => ipb_clk_i,
            ipb_miso_arr_o          => ipb_miso_arr(number_of_ipb_slaves - 3 downto 0), ---
            ipb_mosi_arr_i          => ipb_mosi_arr(number_of_ipb_slaves - 3 downto 0), ---

            -- LEDs
            led_l1a_o               => user_v6_led_o(2),
            led_trigger_o           => user_v6_led_o(1),

            -- DAQLink
            daq_data_clk_i          => daq_clk_bufg,
            daq_data_clk_locked_i   => daq_clk_locked,
            daq_to_daqlink_o        => daq_to_daqlink,
            daqlink_to_daq_i        => daqlink_to_daq,
            
            -- Board serial number
            board_id_i              => x"00" & sn,

            -- GEM loader
            to_gem_loader_o         => to_gem_loader,
            from_gem_loader_i       => from_gem_loader
        );

    -- GTX mapping to GEM links (trigger)
    gem_gt_trig0_rx_clk_arr <= (others => '0');
    gem_gt_trig1_rx_clk_arr <= (others => '0');

    gem_gt_trig0_rx_data_arr <= (others => (rxdata => (others => ('0')), rxcharisk => (others => '0'), rxchariscomma => (others => '0'), rxnotintable => (others => '0'), rxdisperr => (others => '0'), rxcommadet => '0', rxbyterealign => '0', rxbyteisaligned => '0'));
    gem_gt_trig1_rx_data_arr <= (others => (rxdata => (others => ('0')), rxcharisk => (others => '0'), rxchariscomma => (others => '0'), rxnotintable => (others => '0'), rxdisperr => (others => '0'), rxcommadet => '0', rxbyterealign => '0', rxbyteisaligned => '0'));

    -- IPBus mapping
    g_ipb_map : for i in 0 to number_of_ipb_slaves - 1 generate
         ipb_miso_o(i)   <= ipb_miso_arr(i);
         ipb_mosi_arr(i) <= ipb_mosi_i(i);
    end generate;

end user_logic_arch;
