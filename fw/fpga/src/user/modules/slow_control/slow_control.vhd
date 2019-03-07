------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    14:19 2016-10-05
-- Module Name:    slow_control
-- Description:    This module is mainly responsible for communication with Optohybrid SCA and reading/writing GBTx registers
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.gem_pkg.all;
use work.sca_pkg.all;
use work.ttc_pkg.all;
use work.ipbus.all;
use work.registers.all;

entity slow_control is
    generic(
        g_NUM_OF_OHs    : integer := 1;
        g_DEBUG         : boolean := false -- if this is set to true, some chipscope cores will be inserted
    );
    port(
        -- reset
        reset_i                 : in  std_logic;

        -- TTC
        ttc_clk_i               : in  t_ttc_clks;
        ttc_cmds_i              : in  t_ttc_cmds;
        
        -- SCA elinks
        gbt_rx_ready_i          : in  std_logic_vector(g_NUM_OF_OHs * 3 - 1 downto 0); 
        gbt_rx_sca_elinks_i     : in  t_std2_array(g_NUM_OF_OHs - 1 downto 0);
        gbt_tx_sca_elinks_o     : out t_std2_array(g_NUM_OF_OHs - 1 downto 0);
        
        -- GBTx IC elinks
        gbt_rx_ic_elinks_i      : in  t_std2_array(g_NUM_OF_OHs * 3 - 1 downto 0);
        gbt_tx_ic_elinks_o      : out t_std2_array(g_NUM_OF_OHs * 3 - 1 downto 0);
        
        -- VFAT3 slow control status
        vfat3_sc_status_i       : in t_vfat_slow_control_status; 
        
        -- IPbus
        ipb_reset_i             : in  std_logic;
        ipb_clk_i               : in  std_logic;
        ipb_miso_o              : out ipb_rbus;
        ipb_mosi_i              : in  ipb_wbus
        
    );
end slow_control;

architecture slow_control_arch of slow_control is

    --------------------------------- signals ---------------------------------    

    -- only handle one GBT IC for now, this constant defines the elink to use for that one SCA controller
    constant ELINK_IDX          : integer := 1;

    --============ SCA ============--
    
    -- general
    signal sca_reset                : std_logic;
    signal sca_reset_mask           : std_logic_vector(31 downto 0);
    signal sca_ready_arr            : std_logic_vector(31 downto 0);
    signal sca_critical_error_arr   : std_logic_vector(31 downto 0);
    signal sca_ttc_hr_enable        : std_logic;
    
    -- manual commands
    signal manual_hard_reset            : std_logic;
    signal sca_user_command             : t_sca_command;
    signal sca_user_command_en          : std_logic;
    signal sca_user_command_en_mask     : std_logic_vector(31 downto 0); -- command_en signal will only be sent to the channels that are enabled in this bitmask
    signal sca_user_command_done_arr    : std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
    signal sca_user_command_done_latch  : std_logic_vector(g_NUM_OF_OHs - 1 downto 0) := (others => '0');
    signal sca_user_command_done_all    : std_logic;
    signal sca_user_reply_arr           : t_sca_reply_array(g_NUM_OF_OHs - 1 downto 0);
    
    -- core monitoring
    signal sca_not_ready_cnt_arr: t_std16_array(g_NUM_OF_OHs - 1 downto 0);
    signal sca_rx_err_cnt       : std_logic_vector(15 downto 0);
    signal sca_seq_num_err_cnt  : std_logic_vector(15 downto 0);
    signal sca_crc_err_cnt      : std_logic_vector(15 downto 0);
    signal sca_tr_timeout_cnt   : std_logic_vector(15 downto 0);
    signal sca_tr_fail_cnt      : std_logic_vector(15 downto 0);
    signal sca_tr_done_cnt      : std_logic_vector(31 downto 0);
    signal sca_last_sca_error   : std_logic_vector(6 downto 0);
    
    -- adc
    signal sca_adc_monitor_off_arr  : std_logic_vector(31 downto 0);
    signal sca_adc_readings_arr     : t_sca_adc_value_arr_arr(g_NUM_OF_OHs - 1 downto 0);
    
    -- jtag
    signal jtag_enabled_mask        : std_logic_vector(31 downto 0);
    signal jtag_cmd_length          : std_logic_vector(6 downto 0);
    signal jtag_tdo                 : std_logic_vector(31 downto 0);
    signal jtag_tms                 : std_logic_vector(31 downto 0);
    signal jtag_tdi_arr             : t_std32_array(g_NUM_OF_OHs - 1 downto 0);
    signal jtag_shift_tdo_en        : std_logic; 
    signal jtag_shift_tms_en        : std_logic;
    signal jtag_shift_tdi_en_arr    : std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
    signal jtag_shift_done_arr      : std_logic_vector(g_NUM_OF_OHs - 1 downto 0); 
    signal jtag_shift_done_latch    : std_logic_vector(g_NUM_OF_OHs - 1 downto 0) := (others => '0'); 
    signal jtag_shift_done_all      : std_logic; 
    signal jtag_shift_msb_first     : std_logic; -- tell SCA to shift out MSB first instead of the default LSB first
    signal jtag_exec_on_every_tdo   : std_logic; -- EXPERT ONLY: used to optimize firmware downloading, when set high the controller will execute JTAG_GO after every TDO shift (even if length is higher than 32)
    signal jtag_no_length_update    : std_logic; -- EXPERT ONLY: used to optimize firmware downloading, when set high the controller will assume that SCA already has the correct length and will not update it before each JTAG_GO
    signal jtag_shift_tdo_async     : std_logic; -- kindof expert: if this is set high then JTAG controller will assert jtag_shift_done_o immediately after TDO shift command, but if the second command is received while it's still busy it won't assert jtag_shift_done_o until the previous command is done
    
            
    -- debug
    signal sca_tx_raw_last_cmd  : std_logic_vector(95 downto 0);
    signal sca_rx_raw_last_reply: std_logic_vector(95 downto 0);
    signal sca_rx_last_calc_crc : std_logic_vector(15 downto 0);

    ------------- GBTx IC -------------

    signal ic_link_select       : std_logic_vector(5 downto 0);
    signal ic_rx_elink          : std_logic_vector(1 downto 0);
    signal ic_tx_elink          : std_logic_vector(1 downto 0);
    signal ic_address           : std_logic_vector(15 downto 0);
    signal ic_write_data        : std_logic_vector(31 downto 0);
    signal ic_rw_length         : std_logic_vector(2 downto 0);
    signal ic_write_req         : std_logic;
    signal ic_write_done        : std_logic;
    signal ic_read_req          : std_logic; 
    signal ic_gbtx_i2c_addr     : std_logic_vector(3 downto 0);

    ------ Register signals begin (this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    --======== SCA controller ========--
    
    g_sca_controllers : for i in 0 to g_NUM_OF_OHs - 1 generate
        i_sca_controller : entity work.sca_controller
            port map(
                reset_i                     => reset_i or (sca_reset and sca_reset_mask(i)),
                gbt_clk_40_i                => ttc_clk_i.clk_40,
                clk_80_i                    => ttc_clk_i.clk_80,
            
                gbt_rx_ready_i              => gbt_rx_ready_i(i * 3),
                gbt_rx_sca_elink_i          => gbt_rx_sca_elinks_i(i),
                gbt_tx_sca_elink_o          => gbt_tx_sca_elinks_o(i),
            
                hard_reset_i                => manual_hard_reset or (ttc_cmds_i.hard_reset and sca_ttc_hr_enable),
            
                user_command_i              => sca_user_command,
                user_command_en_i           => sca_user_command_en and sca_user_command_en_mask(i),
                user_reply_o                => sca_user_reply_arr(i),
                user_reply_valid_o          => sca_user_command_done_arr(i),
            
                adc_monitoring_off_i        => sca_adc_monitor_off_arr(i),
                adc_readings_o              => sca_adc_readings_arr(i),
            
                jtag_enabled_i              => jtag_enabled_mask(i),
                jtag_cmd_length_i           => unsigned(jtag_cmd_length),
                jtag_tdo_i                  => jtag_tdo,
                jtag_tms_i                  => jtag_tms,
                jtag_tdi_o                  => jtag_tdi_arr(i),
                jtag_shift_tdo_en_i         => jtag_shift_tdo_en,
                jtag_shift_tms_en_i         => jtag_shift_tms_en,
                jtag_shift_tdi_en_i         => jtag_shift_tdi_en_arr(i),
                jtag_shift_done_o           => jtag_shift_done_arr(i),            
                jtag_shift_msb_first_i      => jtag_shift_msb_first,
                
                jtag_exec_on_every_tdo_i    => jtag_exec_on_every_tdo,
                jtag_no_length_update_i     => jtag_no_length_update,
                jtag_shift_tdo_async_i      => jtag_shift_tdo_async,
                                    
                ready_o                     => sca_ready_arr(i),
                critical_error_o            => sca_critical_error_arr(i),
                not_ready_cnt_o             => sca_not_ready_cnt_arr(i),
                rx_err_cnt_o                => open, --sca_rx_err_cnt,
                rx_seq_num_err_cnt_o        => open, --sca_seq_num_err_cnt,
                rx_crc_err_cnt_o            => open, --sca_crc_err_cnt,
                trans_timeout_cnt_o         => open, --sca_tr_timeout_cnt,
                trans_fail_cnt_o            => open, --sca_tr_fail_cnt,
                trans_done_cnt_o            => open, --sca_tr_done_cnt,
                last_sca_error_o            => open, --sca_last_sca_error,
                tx_raw_last_cmd_o           => open, --sca_tx_raw_last_cmd,
                rx_raw_last_reply_o         => open, --sca_rx_raw_last_reply,
                rx_last_calc_crc_o          => open  --sca_rx_last_calc_crc
            );
    end generate;

    ------------------- SCA done signal aggregation based on enabled channels -------------------
    
    -- manual command
    process(ttc_clk_i.clk_40)
    begin
        if (rising_edge(ttc_clk_i.clk_40)) then
            if (sca_user_command_en = '1') then
                sca_user_command_done_latch <= (others => '0');
            else
                sca_user_command_done_latch <= sca_user_command_done_latch or sca_user_command_done_arr;
            end if;
            
            if (sca_user_command_done_latch = sca_user_command_en_mask(g_NUM_OF_OHs - 1 downto 0)) then
                sca_user_command_done_all <= '1';
                sca_user_command_done_latch <= (others => '0');
            else
                sca_user_command_done_all <= '0';
            end if;
        end if;
    end process; 

    -- JTAG command
    process(ttc_clk_i.clk_40)
    begin
        if (rising_edge(ttc_clk_i.clk_40)) then
            if ((jtag_shift_tdo_en = '1') or (jtag_shift_tms_en = '1')) then
                jtag_shift_done_latch <= (others => '0');
            else
                jtag_shift_done_latch <= jtag_shift_done_latch or jtag_shift_done_arr;
            end if;
            
            if (jtag_shift_done_latch = jtag_enabled_mask(g_NUM_OF_OHs - 1 downto 0)) then
                jtag_shift_done_all <= '1';
                jtag_shift_done_latch <= (others => '0');
            else
                jtag_shift_done_all <= '0';
            end if;
        end if;
    end process; 

    
    --======== GBTx IC ========--
    
    i_ic_controller : entity work.gbtx_ic_controller
--        generic map(
--            g_GBTX_I2C_ADDRESS => x"1"
--        )
        port map(
            reset_i           => reset_i,
            gbt_clk_i         => ttc_clk_i.clk_40,
            gbtx_i2c_address  => ic_gbtx_i2c_addr,
            gbt_rx_ic_elink_i => ic_rx_elink,
            gbt_tx_ic_elink_o => ic_tx_elink,
            ic_rw_address_i   => ic_address,
            ic_w_data_i       => ic_write_data,
            ic_rw_length_i    => ic_rw_length,
            ic_write_req_i    => ic_write_req,
            ic_write_done_o   => ic_write_done,
            ic_read_req_i     => ic_read_req
        );
    
    ic_rx_elink <= gbt_rx_ic_elinks_i(to_integer(unsigned(ic_link_select)));
    g_ic_tx_generate: for i in 0 to g_NUM_OF_OHs * 3 - 1 generate
        gbt_tx_ic_elinks_o(i) <= ic_tx_elink when to_integer(unsigned(ic_link_select)) = i else (others => '1'); 
    end generate;
    
    --===============================================================================================
    -- this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py (do not edit) 
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_SLOW_CONTROL_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_SLOW_CONTROL_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_SLOW_CONTROL_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => ipb_clk_i,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => ttc_clk_i.clk_40,
           regs_read_arr_i        => regs_read_arr,
           regs_write_arr_o       => regs_write_arr,
           read_pulse_arr_o       => regs_read_pulse_arr,
           write_pulse_arr_o      => regs_write_pulse_arr,
           regs_read_ready_arr_i  => regs_read_ready_arr,
           regs_write_done_arr_i  => regs_write_done_arr,
           individual_addrs_arr_i => regs_addresses,
           regs_defaults_arr_i    => regs_defaults,
           writable_regs_i        => regs_writable_arr
      );

    -- Addresses
    regs_addresses(0)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0000";
    regs_addresses(1)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0001";
    regs_addresses(2)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0002";
    regs_addresses(3)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0003";
    regs_addresses(4)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0100";
    regs_addresses(5)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0101";
    regs_addresses(6)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0102";
    regs_addresses(7)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1000";
    regs_addresses(8)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1001";
    regs_addresses(9)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1002";
    regs_addresses(10)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1003";
    regs_addresses(11)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1004";
    regs_addresses(12)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1005";
    regs_addresses(13)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2000";
    regs_addresses(14)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2001";
    regs_addresses(15)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2002";
    regs_addresses(16)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2003";
    regs_addresses(17)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2004";
    regs_addresses(18)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2005";
    regs_addresses(19)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2006";
    regs_addresses(20)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2007";
    regs_addresses(21)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2008";
    regs_addresses(22)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2009";
    regs_addresses(23)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"200a";
    regs_addresses(24)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2500";
    regs_addresses(25)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2501";
    regs_addresses(26)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2502";
    regs_addresses(27)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2503";
    regs_addresses(28)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2504";
    regs_addresses(29)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2505";
    regs_addresses(30)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3000";
    regs_addresses(31)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3001";
    regs_addresses(32)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3002";
    regs_addresses(33)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3003";
    regs_addresses(34)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3004";
    regs_addresses(35)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3005";
    regs_addresses(36)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"3006";
    regs_addresses(37)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"4000";
    regs_addresses(38)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"4001";
    regs_addresses(39)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"4002";

    -- Connect read signals
    regs_read_arr(2)(REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT) <= sca_ttc_hr_enable;
    regs_read_arr(3)(REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_LSB) <= sca_reset_mask;
    regs_read_arr(4)(REG_SLOW_CONTROL_SCA_STATUS_READY_MSB downto REG_SLOW_CONTROL_SCA_STATUS_READY_LSB) <= sca_ready_arr;
    regs_read_arr(5)(REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_MSB downto REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_LSB) <= sca_critical_error_arr;
    regs_read_arr(6)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_LSB) <= sca_not_ready_cnt_arr(0);
    regs_read_arr(7)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB) <= sca_user_command_en_mask;
    regs_read_arr(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB) <= sca_user_command.channel;
    regs_read_arr(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB) <= sca_user_command.command;
    regs_read_arr(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB) <= sca_user_command.length;
    regs_read_arr(9)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB) <= sca_user_command.data;
    regs_read_arr(11)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(0).channel;
    regs_read_arr(11)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(0).error;
    regs_read_arr(11)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(0).length;
    regs_read_arr(12)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(0).data;
    regs_read_arr(13)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB) <= sca_adc_monitor_off_arr;
    regs_read_arr(14)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_LSB) <= sca_adc_readings_arr(0)(0);
    regs_read_arr(14)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_LSB) <= sca_adc_readings_arr(0)(1);
    regs_read_arr(15)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_LSB) <= sca_adc_readings_arr(0)(2);
    regs_read_arr(15)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_LSB) <= sca_adc_readings_arr(0)(3);
    regs_read_arr(16)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_LSB) <= sca_adc_readings_arr(0)(4);
    regs_read_arr(16)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_LSB) <= sca_adc_readings_arr(0)(5);
    regs_read_arr(17)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_LSB) <= sca_adc_readings_arr(0)(6);
    regs_read_arr(17)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_LSB) <= sca_adc_readings_arr(0)(7);
    regs_read_arr(18)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(0)(8);
    regs_read_arr(18)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(0)(9);
    regs_read_arr(19)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_LSB) <= sca_adc_readings_arr(0)(10);
    regs_read_arr(19)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(0)(11);
    regs_read_arr(20)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(0)(12);
    regs_read_arr(20)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(0)(13);
    regs_read_arr(21)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(0)(14);
    regs_read_arr(21)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(0)(15);
    regs_read_arr(22)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(0)(16);
    regs_read_arr(22)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(0)(17);
    regs_read_arr(23)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(0)(18);
    regs_read_arr(23)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(0)(19);
    regs_read_arr(24)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB) <= jtag_enabled_mask;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT) <= jtag_shift_msb_first;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT) <= jtag_exec_on_every_tdo;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT) <= jtag_no_length_update;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT) <= jtag_shift_tdo_async;
    regs_read_arr(26)(REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB) <= jtag_cmd_length;
    regs_read_arr(29)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_LSB) <= jtag_tdi_arr(0);
    regs_read_arr(30)(REG_SLOW_CONTROL_IC_ADDRESS_MSB downto REG_SLOW_CONTROL_IC_ADDRESS_LSB) <= ic_address;
    regs_read_arr(31)(REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB downto REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB) <= ic_rw_length;
    regs_read_arr(32)(REG_SLOW_CONTROL_IC_WRITE_DATA_MSB downto REG_SLOW_CONTROL_IC_WRITE_DATA_LSB) <= ic_write_data;
    regs_read_arr(35)(REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB downto REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB) <= ic_gbtx_i2c_addr;
    regs_read_arr(36)(REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_MSB downto REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_LSB) <= ic_link_select;
    regs_read_arr(37)(REG_SLOW_CONTROL_VFAT3_CRC_ERROR_CNT_MSB downto REG_SLOW_CONTROL_VFAT3_CRC_ERROR_CNT_LSB) <= vfat3_sc_status_i.crc_error_cnt;
    regs_read_arr(37)(REG_SLOW_CONTROL_VFAT3_PACKET_ERROR_CNT_MSB downto REG_SLOW_CONTROL_VFAT3_PACKET_ERROR_CNT_LSB) <= vfat3_sc_status_i.packet_error_cnt;
    regs_read_arr(38)(REG_SLOW_CONTROL_VFAT3_BITSTUFFING_ERROR_CNT_MSB downto REG_SLOW_CONTROL_VFAT3_BITSTUFFING_ERROR_CNT_LSB) <= vfat3_sc_status_i.bitstuff_error_cnt;
    regs_read_arr(38)(REG_SLOW_CONTROL_VFAT3_TIMEOUT_ERROR_CNT_MSB downto REG_SLOW_CONTROL_VFAT3_TIMEOUT_ERROR_CNT_LSB) <= vfat3_sc_status_i.timeout_error_cnt;
    regs_read_arr(39)(REG_SLOW_CONTROL_VFAT3_AXI_STROBE_ERROR_CNT_MSB downto REG_SLOW_CONTROL_VFAT3_AXI_STROBE_ERROR_CNT_LSB) <= vfat3_sc_status_i.axi_strobe_error_cnt;
    regs_read_arr(39)(REG_SLOW_CONTROL_VFAT3_TRANSACTION_CNT_MSB downto REG_SLOW_CONTROL_VFAT3_TRANSACTION_CNT_LSB) <= vfat3_sc_status_i.transaction_cnt;

    -- Connect write signals
    sca_ttc_hr_enable <= regs_write_arr(2)(REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT);
    sca_reset_mask <= regs_write_arr(3)(REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_LSB);
    sca_user_command_en_mask <= regs_write_arr(7)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB);
    sca_user_command.channel <= regs_write_arr(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB);
    sca_user_command.command <= regs_write_arr(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB);
    sca_user_command.length <= regs_write_arr(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB);
    sca_user_command.data <= regs_write_arr(9)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB);
    sca_adc_monitor_off_arr <= regs_write_arr(13)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB);
    jtag_enabled_mask <= regs_write_arr(24)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB);
    jtag_shift_msb_first <= regs_write_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT);
    jtag_exec_on_every_tdo <= regs_write_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT);
    jtag_no_length_update <= regs_write_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT);
    jtag_shift_tdo_async <= regs_write_arr(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT);
    jtag_cmd_length <= regs_write_arr(26)(REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB);
    jtag_tms <= regs_write_arr(27)(REG_SLOW_CONTROL_SCA_JTAG_TMS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TMS_LSB);
    jtag_tdo <= regs_write_arr(28)(REG_SLOW_CONTROL_SCA_JTAG_TDO_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDO_LSB);
    ic_address <= regs_write_arr(30)(REG_SLOW_CONTROL_IC_ADDRESS_MSB downto REG_SLOW_CONTROL_IC_ADDRESS_LSB);
    ic_rw_length <= regs_write_arr(31)(REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB downto REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB);
    ic_write_data <= regs_write_arr(32)(REG_SLOW_CONTROL_IC_WRITE_DATA_MSB downto REG_SLOW_CONTROL_IC_WRITE_DATA_LSB);
    ic_gbtx_i2c_addr <= regs_write_arr(35)(REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB downto REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB);
    ic_link_select <= regs_write_arr(36)(REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_MSB downto REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_LSB);

    -- Connect write pulse signals
    sca_reset <= regs_write_pulse_arr(0);
    manual_hard_reset <= regs_write_pulse_arr(1);
    sca_user_command_en <= regs_write_pulse_arr(10);
    jtag_shift_tms_en <= regs_write_pulse_arr(27);
    jtag_shift_tdo_en <= regs_write_pulse_arr(28);
    ic_write_req <= regs_write_pulse_arr(33);
    ic_read_req <= regs_write_pulse_arr(34);

    -- Connect write done signals
    regs_write_done_arr(10) <= sca_user_command_done_all;
    regs_write_done_arr(27) <= jtag_shift_done_all;
    regs_write_done_arr(28) <= jtag_shift_done_all;
    regs_write_done_arr(33) <= ic_write_done;

    -- Connect read pulse signals
    jtag_shift_tdi_en_arr(0) <= regs_read_pulse_arr(29);

    -- Connect read ready signals
    regs_read_ready_arr(29) <= jtag_shift_done_arr(0);

    -- Defaults
    regs_defaults(2)(REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT) <= REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_DEFAULT;
    regs_defaults(3)(REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_LSB) <= REG_SLOW_CONTROL_SCA_CTRL_SCA_RESET_ENABLE_MASK_DEFAULT;
    regs_defaults(7)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_DEFAULT;
    regs_defaults(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_DEFAULT;
    regs_defaults(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_DEFAULT;
    regs_defaults(8)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_DEFAULT;
    regs_defaults(9)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_DEFAULT;
    regs_defaults(13)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB) <= REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_DEFAULT;
    regs_defaults(24)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_DEFAULT;
    regs_defaults(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_DEFAULT;
    regs_defaults(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_DEFAULT;
    regs_defaults(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_DEFAULT;
    regs_defaults(25)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_DEFAULT;
    regs_defaults(26)(REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_DEFAULT;
    regs_defaults(27)(REG_SLOW_CONTROL_SCA_JTAG_TMS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TMS_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_TMS_DEFAULT;
    regs_defaults(28)(REG_SLOW_CONTROL_SCA_JTAG_TDO_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDO_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_TDO_DEFAULT;
    regs_defaults(30)(REG_SLOW_CONTROL_IC_ADDRESS_MSB downto REG_SLOW_CONTROL_IC_ADDRESS_LSB) <= REG_SLOW_CONTROL_IC_ADDRESS_DEFAULT;
    regs_defaults(31)(REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB downto REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB) <= REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_DEFAULT;
    regs_defaults(32)(REG_SLOW_CONTROL_IC_WRITE_DATA_MSB downto REG_SLOW_CONTROL_IC_WRITE_DATA_LSB) <= REG_SLOW_CONTROL_IC_WRITE_DATA_DEFAULT;
    regs_defaults(35)(REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB downto REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB) <= REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_DEFAULT;
    regs_defaults(36)(REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_MSB downto REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_LSB) <= REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_DEFAULT;

    -- Define writable regs
    regs_writable_arr(2) <= '1';
    regs_writable_arr(3) <= '1';
    regs_writable_arr(7) <= '1';
    regs_writable_arr(8) <= '1';
    regs_writable_arr(9) <= '1';
    regs_writable_arr(13) <= '1';
    regs_writable_arr(24) <= '1';
    regs_writable_arr(25) <= '1';
    regs_writable_arr(26) <= '1';
    regs_writable_arr(27) <= '1';
    regs_writable_arr(28) <= '1';
    regs_writable_arr(30) <= '1';
    regs_writable_arr(31) <= '1';
    regs_writable_arr(32) <= '1';
    regs_writable_arr(35) <= '1';
    regs_writable_arr(36) <= '1';

    --==== Registers end ============================================================================
        
end slow_control_arch;
