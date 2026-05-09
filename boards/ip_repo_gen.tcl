# // Author: Xianjun Jiao
# // SPDX-FileCopyrightText: 2022 UGent
# // SPDX-License-Identifier: AGPL-3.0-or-later

# https://adaptivesupport.amd.com/s/article/000034290?language=en_US
set_param gui.addressMap 0

# Set board specific variables
set BOARD_NAME [lindex [split [exec pwd] /] end]
puts "ip_repo_gen.tcl BOARD_NAME $BOARD_NAME"
source ../../ip/parse_board_name.tcl

# ------------------setup ip_repo directory and board files---------------------
exec rm -rf ip_repo
exec mkdir ip_repo
exec cp ../../ip/board_def.v ./ip_repo/ -f

set FSIGHT_OPENWIFI_PHY_PROFILE "ow-stock-20"
if {[info exists ::env(FSIGHT_OPENWIFI_PHY_PROFILE)]} {
  set FSIGHT_OPENWIFI_PHY_PROFILE [string trim $::env(FSIGHT_OPENWIFI_PHY_PROFILE)]
}
if {$FSIGHT_OPENWIFI_PHY_PROFILE eq ""} {
  set FSIGHT_OPENWIFI_PHY_PROFILE "ow-stock-20"
}
set FSIGHT_OPENWIFI_RX_IQ_BYPASS "0"
if {[info exists ::env(FSIGHT_OPENWIFI_RX_IQ_BYPASS)]} {
  set FSIGHT_OPENWIFI_RX_IQ_BYPASS [string tolower [string trim $::env(FSIGHT_OPENWIFI_RX_IQ_BYPASS)]]
}
if {$FSIGHT_OPENWIFI_RX_IQ_BYPASS eq ""} {
  set FSIGHT_OPENWIFI_RX_IQ_BYPASS "0"
}
if {$FSIGHT_OPENWIFI_RX_IQ_BYPASS ni {"0" "1" "false" "true"}} {
  error "Unsupported FSIGHT_OPENWIFI_RX_IQ_BYPASS '$FSIGHT_OPENWIFI_RX_IQ_BYPASS'. Expected 0/1 or false/true."
}
puts "ip_repo_gen.tcl FSIGHT_OPENWIFI_PHY_PROFILE $FSIGHT_OPENWIFI_PHY_PROFILE"
puts "ip_repo_gen.tcl FSIGHT_OPENWIFI_RX_IQ_BYPASS $FSIGHT_OPENWIFI_RX_IQ_BYPASS"
set board_def_preamble {}
if {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10"} {
  lappend board_def_preamble {`define OW_PROFILE_NB10 1}
  if {$FSIGHT_OPENWIFI_RX_IQ_BYPASS in {"1" "true"}} {
    lappend board_def_preamble {`define OW_RX_IQ_RATE_ADAPTATION_BYPASS 1}
  }
} elseif {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10-timing-a"} {
  lappend board_def_preamble {`define OW_PROFILE_NB10_TIMING_A 1}
  lappend board_def_preamble {`define OW_RX_IQ_RATE_ADAPTATION_BYPASS 1}
} elseif {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10-timing-b"} {
  lappend board_def_preamble {`define OW_PROFILE_NB10_TIMING_B 1}
  lappend board_def_preamble {`define OW_RX_IQ_RATE_ADAPTATION_BYPASS 1}
} elseif {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10-timing-c"} {
  lappend board_def_preamble {`define OW_PROFILE_NB10_TIMING_C 1}
  lappend board_def_preamble {`define OW_RX_IQ_RATE_ADAPTATION_BYPASS 1}
} elseif {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10-timing-d"} {
  lappend board_def_preamble {`define OW_PROFILE_NB10_TIMING_D 1}
} elseif {$FSIGHT_OPENWIFI_PHY_PROFILE eq "ow-nb-10-timing-e"} {
  lappend board_def_preamble {`define OW_PROFILE_NB10_TIMING_E 1}
} elseif {$FSIGHT_OPENWIFI_PHY_PROFILE ne "ow-stock-20"} {
  error "Unsupported FSIGHT_OPENWIFI_PHY_PROFILE '$FSIGHT_OPENWIFI_PHY_PROFILE'. Expected ow-stock-20, ow-nb-10, ow-nb-10-timing-a, ow-nb-10-timing-b, ow-nb-10-timing-c, ow-nb-10-timing-d, or ow-nb-10-timing-e."
}
if {[llength $board_def_preamble] > 0} {
  set fd [open "./ip_repo/board_def.v" r]
  set board_def_body [read $fd]
  close $fd
  set fd [open "./ip_repo/board_def.v" w]
  foreach line $board_def_preamble {
    puts $fd $line
  }
  puts -nonewline $fd $board_def_body
  close $fd
}
set ::env(FSIGHT_OPENWIFI_BOARD_DEF) [file normalize "./ip_repo/board_def.v"]

# -----------generate git rev info------------------------
set  fd  [open  "./ip_repo/openwifi_hw_git_rev.v"  w]
set HASHCODE [exec ../../get_git_rev.sh]
puts $fd "`define OPENWIFI_HW_GIT_REV (32'h$HASHCODE)"
close $fd
# ----end of generate generate git rev info---------------

# -----------generate has_side_ch_flag.v------------------
# if you want NO side_ch, please use set has_side_ch 0
set has_side_ch 1 
set  fd  [open  "./ip_repo/has_side_ch_flag.v"  w]
if {$has_side_ch > 0} {
  puts $fd "`define HAS_SIDE_CH 1"
} else {
  puts $fd "`define NO_SIDE_CH 1"
}
close $fd
# ----end of generate has_side_ch_flag.v------------------

# ---------generate fpga_scale.v---------------------------
set  fd  [open  "./ip_repo/fpga_scale.v"  w]
if {$fpga_size_flag == 0} {
  puts $fd "`define SIDE_CH_LESS_BRAM 1"
}
close $fd
# ---------end of generate fpga_scale.v--------------------

# --------generate clock_speed.v for xpu/tx_intf/rx_intf---
set NUM_CLK_PER_US 100
set  fd  [open  "./ip_repo/clock_speed.v"  w]
puts $fd "`define NUM_CLK_PER_US $NUM_CLK_PER_US"
if {$fpga_size_flag == 0} {
  puts $fd "`define SMALL_FPGA 1"
}
close $fd
# --end of generate clock_speed.v for xpu/tx_intf/rx_intf--

# ---------generate spi_command.v---------------------------
# set grounded_rf_port 1 for port control, set 0 for lo control
set grounded_rf_port 0
set  fd  [open  "./ip_repo/spi_command.v"  w]
if {$grounded_rf_port == 1} {
  puts $fd "`define SPI_HIGH 24'hC22001"
  puts $fd "`define SPI_LOW 24'hC02001"
} else {
  puts $fd "`define SPI_HIGH 24'h088A01"
  puts $fd "`define SPI_LOW 24'h008A01"
}
close $fd
# ---------end of generate spi_command.v--------------------

# ------------------end of setup ip_repo directory and board files--------------

# --------------------------------generate ip repo------------------------------
set ip_name_list "openofdm_rx openofdm_tx rx_intf tx_intf xpu side_ch"
# loop and generate all ip
set i 0
foreach ip_name $ip_name_list {
  puts "$ip_name is item number $i in list ip_name_list"

  set ip_tcl_filename $ip_name\.tcl
  if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
  exec rm -rf project_1
  if {$ip_name != "openofdm_rx"} {
    exec cp ./ip_repo/openwifi_hw_git_rev.v ../../ip/$ip_name/src/ -f
    exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
    exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
    exec cp ./ip_repo/spi_command.v ../../ip/$ip_name/src/ -f
    exec cp ./ip_repo/fpga_scale.v ../../ip/$ip_name/src/ -f
    exec cp ./ip_repo/has_side_ch_flag.v ../../ip/$ip_name/src/ -f
    exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
  }
  set current_dir [pwd]
  set argv [list $ip_tcl_filename $current_dir/../../ip/$ip_name $current_dir/ip_repo/$ip_name $BOARD_NAME]
  source ../package_ip_complex.tcl
  if {$ip_name == "openofdm_rx"} {
    exec cat ./ip_config/$ip_name\_pre_def.v >> ./ip_repo/$ip_name/src/$ip_name\_pre_def.v
  }
  exec rm -rf ./ip_repo/$ip_name/xgui

  incr i
}

# https://adaptivesupport.amd.com/s/article/000034290?language=en_US
set_param gui.addressMap 0

# launch openwifi synth and impl
source ../openwifi.tcl

# set ip_name openofdm_rx
# set ip_tcl_filename $ip_name\.tcl
# if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
# exec rm -rf project_1
# set current_dir [pwd]
# set argv [list $ip_tcl_filename $current_dir/../../ip/$ip_name $current_dir/ip_repo/$ip_name $BOARD_NAME]
# source ../package_ip_complex.tcl
# exec cat ./ip_config/$ip_name\_pre_def.v >> ./ip_repo/$ip_name/src/$ip_name\_pre_def.v
# exec rm -rf ./ip_repo/$ip_name/xgui

# set ip_name openofdm_tx
# if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
# exec rm -rf project_1
# exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
# set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
# source ../package_ip.tcl
# exec rm -rf ./ip_repo/$ip_name/xgui

# set ip_name rx_intf
# if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
# exec rm -rf project_1
# exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
# set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
# source ../package_ip.tcl
# exec rm -rf ./ip_repo/$ip_name/xgui

# set ip_name tx_intf
# if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
# exec rm -rf project_1
# exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
# set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
# source ../package_ip.tcl
# exec rm -rf ./ip_repo/$ip_name/xgui

# set ip_name xpu
# if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
# exec rm -rf project_1
# exec cp ./ip_repo/openwifi_hw_git_rev.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_repo/board_def.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_repo/clock_speed.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_repo/spi_command.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
# set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
# source ../package_ip.tcl
# exec rm -rf ./ip_repo/$ip_name/xgui

# set ip_name side_ch
# if {[file exists ./ip_config/$ip_name\_pre_def.v]==0} {file mkdir ip_config; exec echo "" > ./ip_config/$ip_name\_pre_def.v}
# exec rm -rf project_1
# exec cp ./ip_repo/fpga_scale.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_repo/has_side_ch_flag.v ../../ip/$ip_name/src/ -f
# exec cp ./ip_config/$ip_name\_pre_def.v ../../ip/$ip_name/src/ -f
# set argv [list $part_string ../../ip/$ip_name/src/ ./ip_repo/$ip_name $BOARD_NAME]
# source ../package_ip.tcl
# exec rm -rf ./ip_repo/$ip_name/xgui
# ---------------------------------end of generate ip repo-----------------------

# exit
