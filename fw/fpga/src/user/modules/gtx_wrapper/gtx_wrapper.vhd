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

-- GEM packages
use work.mgt_pkg.all;

entity gtx_wrapper is  
    port (     
        -- MGT I/O
        mgt_clk_p_i : in std_logic;
        mgt_clk_n_i : in std_logic;

        mgt_rx_arr_i : in t_mgt_rx_serial_arr(0 to 2);
        mgt_tx_arr_o : out t_mgt_tx_serial_arr(0 to 2);

        --Resets
        rx_reset_i : in std_logic;
        tx_reset_i : in std_logic;
        rx_sync_reset_i : in std_logic;
        tx_sync_reset_i : in std_logic;
                 
        -- Clocks
        tx_word_clk_arr_o : out std_logic_vector(0 to 2);
        rx_word_clk_arr_o  : out std_logic_vector(0 to 2);

        txusrclk_i : in std_logic;

        --=======--
        -- Words --
        --=======--

        mgt_tx_word_arr_i : in  t_mgt_gbt_word_arr(0 to 2);     
        mgt_rx_word_arr_o : out t_mgt_gbt_word_arr(0 to 2);

        --=============--      
        -- GBT Control --      
        --=============--

        rx_eq_mix_i : in std_logic_vector(2 downto 0);
        tx_conf_diff_i : in std_logic_vector(3 downto 0);
        tx_post_emph_i : in std_logic_vector(4 downto 0);
        tx_pre_emph_i : in std_logic_vector(3 downto 0);

        tx_reset_done_o : out std_logic_vector(0 to 2);
        rx_reset_done_o : out std_logic_vector(0 to 2);
        ready_o : out std_logic_vector(0 to 2);

        tx_pol_i : in std_logic;
        rx_pol_i : in std_logic;

        gbttx_mgttx_rdy_o                              : out std_logic_vector(0 to 2);
        gbtrx_mgtrx_rdy_o                              : out std_logic_vector(0 to 2);
        gbtrx_rxwordclk_ready_o                        : out std_logic_vector(0 to 2);
        
        prbs_pattern_i_p : in std_logic_vector(2 downto 0);
        TXPRBSFORCEERR_IN : in std_logic;
        PRBSCNTRESET_IN : in std_logic;
        RXPRBSERR_OUT : out std_logic_vector(2 downto 0);
        
        LOOPBACK_IN : in std_logic_vector(3 downto 0)
    );
end gtx_wrapper;

architecture structural of gtx_wrapper is    

    signal mgt_clk : std_logic;
    
    signal RXPRBSERR_OUT_s : std_logic_vector(2 downto 0);

begin

    i_ibufds_gtxe1 : ibufds_gtxe1
    port map(
        o       => mgt_clk,
        odiv2   => open,
        ceb     => '0',
        i       => mgt_clk_p_i,
        ib      => mgt_clk_n_i
    );

    g_gtx_single : for i in 0 to 2 generate
        i_gtx_single : entity work.gtx_single
        port map(
            mgt_clk_i => mgt_clk,
          
            mgt_rx_p_i => mgt_rx_arr_i(i).rxp,
            mgt_rx_n_i => mgt_rx_arr_i(i).rxn,
            mgt_tx_p_o => mgt_tx_arr_o(i).txp,
            mgt_tx_n_o => mgt_tx_arr_o(i).txn,

            --== Resets ==--
            rx_reset_i => rx_reset_i,
            tx_reset_i => tx_reset_i,
            rx_sync_reset_i => rx_sync_reset_i,
            tx_sync_reset_i => tx_sync_reset_i,
                     
            --========--
            -- Clocks --
            --========--
            TX_WORDCLK_O => tx_word_clk_arr_o(i),
            RX_WORDCLK_O => rx_word_clk_arr_o(i),

            txusrclk_i => txusrclk_i,

            --== Words ==--
            mgt_tx_word_i => mgt_tx_word_arr_i(i),
            mgt_rx_word_o => mgt_rx_word_arr_o(i),

            --== GBT Control ==--

            rx_eq_mix_i => rx_eq_mix_i,
            tx_conf_diff_i => tx_conf_diff_i,
            tx_post_emph_i => tx_post_emph_i,
            tx_pre_emph_i => tx_pre_emph_i,

            tx_reset_done_o => tx_reset_done_o(i),
            rx_reset_done_o => rx_reset_done_o(i),
            ready_o => ready_o(i),

            tx_pol_i => tx_pol_i,
            rx_pol_i => rx_pol_i,

            GBTTX_MGTTX_RDY_O => gbttx_mgttx_rdy_o(i),
            GBTRX_MGTRX_RDY_O => gbtrx_mgtrx_rdy_o(i),
            GBTRX_RXWORDCLK_READY_O => gbtrx_rxwordclk_ready_o(i),
            
            prbs_pattern_i_p => prbs_pattern_i_p,
            TXPRBSFORCEERR_IN => TXPRBSFORCEERR_IN,
            PRBSCNTRESET_IN => PRBSCNTRESET_IN,
            RXPRBSERR_OUT => RXPRBSERR_OUT_s(i),
            
            LOOPBACK_IN => LOOPBACK_IN
        );
        
        i_prbs_err_latch : entity work.latch
        port map(
            reset_i => PRBSCNTRESET_IN,
            clk_i   => txusrclk_i,
            input_i => RXPRBSERR_OUT_s(i),
            latch_o => RXPRBSERR_OUT(i)
        );
    end generate;

end structural;
