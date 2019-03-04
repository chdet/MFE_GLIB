
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name glib_v3_basic -dir "C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/prj/glib_v3_basic/planAhead_run_2" -part xc6vlx130tff1156-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/prj/glib_v3_basic/glib_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/prj/glib_v3_basic} {ipcore_dir} {../../src/user/modules/gbt_bank/xilinx_v6/gbt_rx/rx_dpram} {../../src/user/modules/gbt_bank/xilinx_v6/gbt_tx/tx_dpram} {../../ip} {../../src/system/cdce/cdce_phase_mon_v2/dpram} {../../src/system/ethernet/ipcore_dir/basex} {../../src/system/ethernet/ipcore_dir/sgmii} {../../src/system/mem/sram} {../../src/system/pcie/sys_pcie/ezdma2_ipbus_int/cores/ezdma2_ctrl_dpram} {../../src/system/pcie/sys_pcie/ezdma2_ipbus_int/cores/ipbus_ctrl_dpram} {../../src/system/pcie/sys_pcie/ezdma2_ipbus_int/cores/slv_rd_fifo} {../../src/system/pcie/sys_pcie/ezdma2_ipbus_int/cores/slv_wr_fifo} {../../src/system/cdce/cdce_phase_mon_v2/pll} {../../src/system/pll} }
add_files [list {ipcore_dir/fifo_1.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_1M.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/fifo_2.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../../src/user/modules/gbt_bank/xilinx_v6/gbt_rx/rx_dpram/xlx_v6_rx_dpram.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../../src/user/modules/gbt_bank/xilinx_v6/gbt_tx/tx_dpram/xlx_v6_tx_dpram.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../../ip/sync_fifo_gth_40.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../../src/system/cdce/cdce_phase_mon_v2/dpram/ttclk_distributed_dpram.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {../../src/system/ethernet/ipcore_dir/basex/v6_emac_v2_3_basex.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_fabric_clk.ucf" [current_fileset -constrset]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/system/sys/system.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/system/sys/system_clk.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_fabric_clk.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_floorplanning.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_mgt_amc.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_mgt_fmc1.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_mgt_refclk.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_mgt_sfp.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {C:/Users/Charles/Documents/Vivado/glib_v3.r3497/fw/fpga/src/user/ucf/user_timingclosure.ucf}] -fileset [get_property constrset [current_run]]
link_design
