library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mgt_pkg is

    -- TX/RX serial records
    type t_mgt_tx_serial is record
        txn : std_logic;
        txp : std_logic;
    end record;
    type t_mgt_tx_serial_arr is array(natural range <>) of t_mgt_tx_serial;

    type t_mgt_rx_serial is record
        rxp : std_logic;
        rxn : std_logic;
    end record;
    type t_mgt_rx_serial_arr is array(natural range <>) of t_mgt_rx_serial;

    -- Control record
    type t_mgt_ctrl is record
        -- Common
        
        -- TX
        tx_pd       : std_logic_vector(1 downto 0);
        tx_polarity : std_logic;

        tx_conf_diff : std_logic_vector(3 downto 0);
        tx_post_emph : std_logic_vector(4 downto 0);
        tx_pre_emph  : std_logic_vector(3 downto 0);

        -- RX
        rx_pd       : std_logic_vector(1 downto 0);
        rx_polarity : std_logic;

        rx_eq_mix : std_logic_vector(2 downto 0);

        -- PRBS
        prbs_pattern          : std_logic_vector(2 downto 0);
        prbs_force_tx_err     : std_logic;
        prbs_reset_rx_err_cnt : std_logic;
    end record;
    type t_mgt_ctrl_arr is array(natural range <>) of t_mgt_ctrl;

    -- Status record
    type t_mgt_status is record
        -- TX
        tx_reset_done : std_logic;

        -- RX
        rx_reset_done : std_logic;
        
        -- PRBS
    end record;
    type t_mgt_status_arr is array(natural range <>) of t_mgt_status;

    -- Word
    type t_mgt_gbt_word_arr is array(natural range <>) of std_logic_vector(19 downto 0);

end package;