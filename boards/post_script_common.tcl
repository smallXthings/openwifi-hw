# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2025 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# common operations for all boards at the end of openwifi.tcl

open_bd_design {./src/system.bd}

if {$BOARD_NAME!="rfsoc4x2"} {
  set_property CONFIG.FREQ_HZ 40000000 [get_bd_pins /util_ad9361_divclk/clk_out]
}

set FSIGHT_OPENWIFI_PHY_PROFILE "ow-stock-20"
if {[info exists ::env(FSIGHT_OPENWIFI_PHY_PROFILE)] && [string trim $::env(FSIGHT_OPENWIFI_PHY_PROFILE)] ne ""} {
  set FSIGHT_OPENWIFI_PHY_PROFILE [string trim $::env(FSIGHT_OPENWIFI_PHY_PROFILE)]
}

proc fsight_set_bd_config {cell_name config_name config_value} {
  set cell [get_bd_cells -quiet $cell_name]
  if {$cell eq ""} {
    error "fsight_set_bd_config could not find BD cell '$cell_name'"
  }
  set prop "CONFIG.$config_name"
  if {[catch {set_property $prop $config_value $cell} msg]} {
    error "fsight_set_bd_config failed setting $prop=$config_value on $cell_name: $msg"
  }
  puts "post_script_common.tcl set $prop=$config_value on $cell_name"
}

set FSIGHT_OPENWIFI_AXI_REGSLICE 0
if {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10-rf-b"} {
  set FSIGHT_OPENWIFI_AXI_REGSLICE 1
  puts "post_script_common.tcl enabling rf-b AXI-Lite register slices"
}
foreach mi {M00 M01 M02 M03 M04 M05 M06 M07} {
  fsight_set_bd_config /openwifi_ip/axi_interconnect_1 ${mi}_HAS_REGSLICE $FSIGHT_OPENWIFI_AXI_REGSLICE
}

update_compile_order -fileset sources_1

report_ip_status -name ip_status 
upgrade_ip [get_ips  {system_rx_intf_0_0 system_tx_intf_0_0 system_openofdm_tx_0_0 system_xpu_0_0 system_side_ch_0_0}] -log ip_upgrade.log
export_ip_user_files -of_objects [get_ips {system_rx_intf_0_0 system_tx_intf_0_0 system_openofdm_tx_0_0 system_xpu_0_0 system_side_ch_0_0}] -no_script -sync -force -quiet
report_ip_status -name ip_status 

save_bd_design
