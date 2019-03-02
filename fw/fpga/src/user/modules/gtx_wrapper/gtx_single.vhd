--=================================================================================================--
--##################################   Package Information   ######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           Xilinx Virtex 6 - Multi Gigabit Transceivers latency-optimized
--                                                                                                 
-- Language:              VHDL'93                                                                 
--                                                                                                   
-- Target Device:         Xilinx Virtex 6                                                         
-- Tool version:          ISE 14.5                                                               
--                                                                                                   
-- Revision:              3.2                                                                      
--
-- Description:           
--
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--
--                        20/06/2013   3.0       M. Barros Marin   First .vhd module definition
--
--                        29/08/2014   3.2       M. Barros Marin   RX_WORDCLK ready flag high when RX STD
--
-- Additional Comments:
--
-- * Note!! The GTX TX and RX PLLs reference clocks frequency is 240 MHz
--
-- * Note!! The Elastic buffers are bypassed in this latency-optimized GTX (reduces the latency as well
--          as ensures deterministic latency within the GTX)
--
-- * Note!! The phase of the recovered clock is shifted during bitslip. This is done to achieve
--          deterministic phase when crossing from serial clock (2.4Ghz DDR) to RX_RECCLK (240MHz SDR)                                                                               
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!                                                                                           !!
-- !! * The different parameters of the GBT Bank are set through:                               !!  
-- !!   (Note!! These parameters are vendor specific)                                           !!                    
-- !!                                                                                           !!
-- !!   - The MGT control ports of the GBT Bank module (these ports are listed in the records   !!
-- !!     of the file "<vendor>_<device>_gbt_bank_package.vhd").                                !! 
-- !!     (e.g. xlx_v6_gbt_bank_package.vhd)                                                    !!
-- !!                                                                                           !!  
-- !!   - By modifying the content of the file "<vendor>_<device>_gbt_bank_user_setup.vhd".     !!
-- !!     (e.g. xlx_v6_gbt_bank_user_setup.vhd)                                                 !! 
-- !!                                                                                           !! 
-- !! * The "<vendor>_<device>_gbt_bank_user_setup.vhd" is the only file of the GBT Bank that   !!
-- !!   may be modified by the user. The rest of the files MUST be used as is.                  !!
-- !!                                                                                           !!  
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                                                                   
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;
use work.gbt_banks_user_setup.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity gtx_single is  
   port (     
        
      --=========--    
      -- MGT I/O --    
      --=========--    

      mgt_clk_i : in std_logic;
      
      mgt_rx_p_i : in std_logic;
      mgt_rx_n_i : in std_logic;
      mgt_tx_p_o : out std_logic;
      mgt_tx_n_o : out std_logic;

      --== Resets ==--
      rx_reset_i : in std_logic;
      tx_reset_i : in std_logic;
      rx_sync_reset_i : in std_logic;
      tx_sync_reset_i : in std_logic;
                 
      --========--
      -- Clocks --
      --========--
      TX_WORDCLK_O  : out std_logic;
      RX_WORDCLK_O  : out std_logic;   

    txusrclk_i : in std_logic;

      --=======--
      -- Words --
      --=======--

      mgt_tx_word_i : in  std_logic_vector(WORD_WIDTH-1 downto 0);     
      mgt_rx_word_o : out std_logic_vector(WORD_WIDTH-1 downto 0);

      --=============--      
      -- GBT Control --      
      --=============--

      rx_eq_mix_i : in std_logic_vector(2 downto 0);
      tx_conf_diff_i : in std_logic_vector(3 downto 0);
      tx_post_emph_i : in std_logic_vector(4 downto 0);
      tx_pre_emph_i : in std_logic_vector(3 downto 0);

      tx_reset_done_o : out std_logic;
      rx_reset_done_o : out std_logic;
      ready_o : out std_logic;

    tx_pol_i : in std_logic;
    rx_pol_i : in std_logic;

      GBTTX_MGTTX_RDY_O                              : out std_logic;            
      GBTRX_MGTRX_RDY_O                              : out std_logic;
      GBTRX_RXWORDCLK_READY_O                        : out std_logic;
      
      -- PRBS
      prbs_pattern_i_p : in std_logic_vector(2 downto 0);
      TXPRBSFORCEERR_IN : in std_logic;
      PRBSCNTRESET_IN : in std_logic;
      RXPRBSERR_OUT : out std_logic;
      
      LOOPBACK_IN : in std_logic_vector(3 downto 0)
   );
end gtx_single;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of gtx_single is    
   
   --================================ Signal Declarations ================================--
   
   --===============--
   -- Resets scheme --      
   --===============--       
  
   signal txResetDone_from_gtx                       : std_logic;
   signal rxResetDone_from_gtx                       : std_logic;
                                                                                 
   -- TX reset done synchronization registers:                                   
   -------------------------------------------                                   
                                                                                 
   signal txResetDone_r                              : std_logic;
   signal txResetDone_r2_from_gtxTxRstDoneSync       : std_logic;
                                                                                 
   -- RX reset done synchronization registers:                                   
   -------------------------------------------                                   
                                                                                 
   signal rxResetDone_r_from_gtxRxRstDoneSync1       : std_logic;
   signal rxResetDone_r2                             : std_logic;
   --------------------------------------------------                            
   signal rxResetDone_r3                             : std_logic;
   signal rxResetDone_r4_from_gtxRxRstDoneSync2      : std_logic;
                                                                                 
   --==============================--                                            
   -- MGT internal phase alignment --                                            
   --==============================--                                            
                                                                                 
   -- TX synchronizer:                                                           
   -------------------                                                           
                                                                                 
   signal txEnPmaPhaseAlign_from_txSync              : std_logic;
   signal txPmaSetPhase_from_txSync                  : std_logic;
   signal txDlyAlignDisable_from_txSync              : std_logic;
   signal txDlyAlignReset_from_txSync                : std_logic;
   signal txSyncDone_from_txSync                     : std_logic;
   --------------------------------------------------           
   signal reset_to_txSync                            : std_logic;
                                                                
   -- RX synchronizer:                                          
   -------------------                                          
                                                                
   signal rxEnPmaPhaseAlign_from_rxSync              : std_logic; 
   signal rxPmaSetPhase_from_rxSync                  : std_logic;
   signal rxDlyAlignDisable_from_rxSync              : std_logic;
   signal rxDlyAlignOverride_from_rxSync             : std_logic;
   signal rxDlyAlignReset_from_rxSync                : std_logic;
   signal rxSyncDone_from_rxSync                     : std_logic;
   --------------------------------------------------           
   signal reset_to_rxSync                            : std_logic;
                                                                                 
   
   --============--
   -- Clocks     --
   --============--
   signal tx_wordclk_sig                         : std_logic;
   signal tx_wordclk_nobuff_sig                   : std_logic;
   signal rx_wordclk_sig                         : std_logic;
   signal rx_wordclk_nobuff_sig                   : std_logic;
 
   --=====================================================================================--      
   
   signal mgt_rx_word : std_logic_vector(WORD_WIDTH-1 downto 0);

--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--

      --=============--
      -- Assignments --
      --=============--
   
      tx_reset_done_o                  <= txResetDone_r2_from_gtxTxRstDoneSync;
      rx_reset_done_o                  <= rxResetDone_r4_from_gtxRxRstDoneSync2; 
      ready_o                         <= txSyncDone_from_txSync and rxSyncDone_from_rxSync;
      GBTTX_MGTTX_RDY_O                           <= txSyncDone_from_txSync;
      GBTRX_MGTRX_RDY_O                           <= rxSyncDone_from_rxSync;
      
         GBTRX_RXWORDCLK_READY_O                  <= rxResetDone_from_gtx;
         
      -- Loopback
      mgt_rx_word_o <= mgt_tx_word_i when LOOPBACK_IN(3) = '1' else mgt_rx_word;
      
      --================================================--
      -- Multi-Gigabit Transceivers (latency-optimized) --
      --================================================--  

      gtxLatOpt: entity work.xlx_v6_gtx_latopt
         generic map (
            GTX_SIM_GTXRESET_SPEEDUP                 => 0)
         port map (        
            -----------------------------------------
            LOOPBACK_IN                              => LOOPBACK_IN(2 downto 0),
            -----------------------------------------
            RXSLIDE_IN                               => '0',
            -----------------------------------------
            PRBSCNTRESET_IN                          => PRBSCNTRESET_IN,
            RXENPRBSTST_IN                           => prbs_pattern_i_p,
            RXPRBSERR_OUT                            => RXPRBSERR_OUT,
            -----------------------------------------
            RXDATA_OUT                               => mgt_rx_word,
            RXRECCLK_OUT                             => rx_wordclk_nobuff_sig,
            RXUSRCLK2_IN                             => rx_wordclk_sig,
            -----------------------------------------
            RXEQMIX_IN                               => rx_eq_mix_i,
            RXN_IN                                   => mgt_rx_n_i,
            RXP_IN                                   => mgt_rx_p_i,
            -----------------------------------------
            RXDLYALIGNDISABLE_IN                     => rxDlyAlignDisable_from_rxSync,
            RXDLYALIGNMONENB_IN                      => '0',                      
            RXDLYALIGNMONITOR_OUT                    => open,
            RXDLYALIGNOVERRIDE_IN                    => rxDlyAlignOverride_from_rxSync,
            RXDLYALIGNRESET_IN                       => rxDlyAlignReset_from_rxSync,
            RXENPMAPHASEALIGN_IN                     => rxEnPmaPhaseAlign_from_rxSync,
            RXPMASETPHASE_IN                         => rxPmaSetPhase_from_rxSync,
            -----------------------------------------
            GTXRXRESET_IN                            => rx_reset_i,
            MGTREFCLKRX_IN                           => ('0' & mgt_clk_i),
            PLLRXRESET_IN                            => '0',
            RXPLLLKDET_OUT                           => open,
            RXRESETDONE_OUT                          => rxResetDone_from_gtx,
            -----------------------------------------
            RXPOLARITY_IN                            => rx_pol_i,
            -----------------------------------------
            DADDR_IN                                 => (others => '0'),
            DCLK_IN                                  => '0',
            DEN_IN                                   => '0',
            DI_IN                                    => (others => '0'),
            DRDY_OUT                                 => open,
            DRPDO_OUT                                => open,
            DWE_IN                                   => '0',
            -----------------------------------------
            TXDATA_IN                                => mgt_tx_word_i,
            TXOUTCLK_OUT                             => tx_wordclk_nobuff_sig,
            TXUSRCLK2_IN                             => tx_wordclk_sig,
            -----------------------------------------
            TXDIFFCTRL_IN                            => tx_conf_diff_i,
            TXN_OUT                                  => mgt_tx_n_o,
            TXP_OUT                                  => mgt_tx_p_o,
            TXPOSTEMPHASIS_IN                        => tx_post_emph_i,
            -----------------------------------------
            TXPREEMPHASIS_IN                         => tx_pre_emph_i,
            -----------------------------------------
            TXDLYALIGNDISABLE_IN                     => txDlyAlignDisable_from_txSync,
            TXDLYALIGNMONENB_IN                      => '0',                                
            TXDLYALIGNMONITOR_OUT                    => open,                                
            TXDLYALIGNRESET_IN                       => txDlyAlignReset_from_txSync,
            TXENPMAPHASEALIGN_IN                     => txEnPmaPhaseAlign_from_txSync,
            TXPMASETPHASE_IN                         => txPmaSetPhase_from_txSync,
            -----------------------------------------
            GTXTXRESET_IN                            => tx_reset_i,
            MGTREFCLKTX_IN                           => ('0' & mgt_clk_i),
            PLLTXRESET_IN                            => '0',
            TXPLLLKDET_OUT                           => open,
            TXRESETDONE_OUT                          => txResetDone_from_gtx,
            -----------------------------------------
            TXENPRBSTST_IN                           => prbs_pattern_i_p,
            TXPRBSFORCEERR_IN                        => TXPRBSFORCEERR_IN,
            -----------------------------------------
            TXPOLARITY_IN                            => tx_pol_i     
         );

        rxWordClkBufg: BUFG
            port map (
                  O                                        => rx_wordclk_sig,
                  I                                        => rx_wordclk_nobuff_sig
            );   
         tx_wordclk_sig <= txusrclk_i;
         
         TX_WORDCLK_O <= tx_wordclk_sig;
         RX_WORDCLK_O <= rx_wordclk_sig;
			
      --==============--
      -- Reset scheme --      
      --==============--    
      
      -- TX reset done synchronization registers:
      -------------------------------------------
      
      gtxTxRstDoneSync: process(txResetDone_from_gtx, tx_wordclk_sig)
      begin
         if txResetDone_from_gtx = '0' then       
            txResetDone_r2_from_gtxTxRstDoneSync  <= '0';
            txResetDone_r                         <= '0';
         elsif rising_edge(tx_wordclk_sig) then   
            txResetDone_r2_from_gtxTxRstDoneSync  <= txResetDone_r;
            txResetDone_r                         <= txResetDone_from_gtx;
         end if;
      end process;
      
      -- RX reset done synchronization registers:
      -------------------------------------------  
      
      gtxRxRstDoneSync1: process(rx_wordclk_sig)
      begin
         if rising_edge(rx_wordclk_sig) then
            rxResetDone_r_from_gtxRxRstDoneSync1  <= rxResetDone_from_gtx;
         end if; 
      end process;
      
      gtxRxRstDoneSync2: process(rxResetDone_r_from_gtxRxRstDoneSync1, rx_wordclk_sig)
      begin
         if rxResetDone_r_from_gtxRxRstDoneSync1 = '0' then      
            rxResetDone_r4_from_gtxRxRstDoneSync2 <= '0';
            rxResetDone_r3                        <= '0';
            rxResetDone_r2                        <= '0';
         elsif rising_edge(rx_wordclk_sig) then       
            rxResetDone_r4_from_gtxRxRstDoneSync2 <= rxResetDone_r3;
            rxResetDone_r3                        <= rxResetDone_r2;
            rxResetDone_r2                        <= rxResetDone_r_from_gtxRxRstDoneSync1;
         end if; 
      end process;
      
      --==============================--
      -- MGT internal phase alignment --
      --==============================--
      
      -- Comment: The internal clock domains of the GTX must be synchronized due to the elastic buffer bypassing. 
      
      -- TX synchronizer:
      -------------------
      
      reset_to_txSync                             <= (not txResetDone_r2_from_gtxTxRstDoneSync) or tx_sync_reset_i;
      
      txSync: entity work.xlx_v6_gtx_latopt_tx_sync
         generic map (
            SIM_TXPMASETPHASE_SPEEDUP                => 0)
         port map (         
            TXENPMAPHASEALIGN                        => txEnPmaPhaseAlign_from_txSync,
            TXPMASETPHASE                            => txPmaSetPhase_from_txSync,
            TXDLYALIGNDISABLE                        => txDlyAlignDisable_from_txSync,
            TXDLYALIGNRESET                          => txDlyAlignReset_from_txSync,
            SYNC_DONE                                => txSyncDone_from_txSync,
            USER_CLK                                 => tx_wordclk_sig,
            RESET                                    => reset_to_txSync
         );

      -- RX synchronizer:
      -------------------
      
      reset_to_rxSync                             <= (not rxResetDone_r4_from_gtxRxRstDoneSync2) or rx_sync_reset_i; 
      
      rxSync: entity work.xlx_v6_gtx_latopt_rx_sync
         port map (                                                                            
            RXENPMAPHASEALIGN                        => rxEnPmaPhaseAlign_from_rxSync,            
            RXPMASETPHASE                            => rxPmaSetPhase_from_rxSync,
            RXDLYALIGNDISABLE                        => rxDlyAlignDisable_from_rxSync,
            RXDLYALIGNOVERRIDE                       => rxDlyAlignOverride_from_rxSync,
            RXDLYALIGNRESET                          => rxDlyAlignReset_from_rxSync,
            SYNC_DONE                                => rxSyncDone_from_rxSync,
            USER_CLK                                 => rx_wordclk_sig,
            RESET                                    => reset_to_rxSync
         );         

end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
