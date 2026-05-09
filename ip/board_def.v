// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
// board specific definitions

// clock_speed.v has NUM_CLK_PER_US. The value is determined by .tcl (_high.tcl or _low.tcl)
//`define NUM_CLK_PER_US         250 // 250MHz clock for ultrascale+ FPGA
//`define NUM_CLK_PER_US         200 // 200MHz clock for fast FPGA, like -2 and above grade Zynq7000
//`define NUM_CLK_PER_US         100 // 100MHz clock for slow FPGA, like -1 grade Zynq7000

// RF isolation: rf-c keeps rf-a behavior and locally pipelines AXI-Lite write data
// inside route-dominant OpenWiFi control slaves instead of broad interconnect slicing.
`ifdef OW_PROFILE_NB10_RF_C
`ifndef OW_PROFILE_NB10_RF_A
`define OW_PROFILE_NB10_RF_A 1
`endif
`ifndef OW_AXI_LITE_LOCAL_WRITE_PIPELINE
`define OW_AXI_LITE_LOCAL_WRITE_PIPELINE 1
`endif
`endif

// RF isolation: rf-b keeps rf-a behavior while Vivado inserts AXI-Lite register slices.
`ifdef OW_PROFILE_NB10_RF_B
`ifndef OW_PROFILE_NB10_RF_A
`define OW_PROFILE_NB10_RF_A 1
`endif
`endif

// RF isolation: timing-e baseline with 10 MHz FPGA sample cadence.
`ifdef OW_PROFILE_NB10_RF_A
`ifndef OW_PROFILE_NB10_TIMING_E
`define OW_PROFILE_NB10_TIMING_E 1
`endif
`ifndef OW_SAMPLING_RATE_MHZ
`define OW_SAMPLING_RATE_MHZ    10
`endif
`endif

// Timing-closure isolation: timing-e keeps timing-d and pipelines RX IQ rate-control feedback.
`ifdef OW_PROFILE_NB10_TIMING_E
`ifndef OW_PROFILE_NB10_TIMING_D
`define OW_PROFILE_NB10_TIMING_D 1
`endif
`ifndef OW_RX_IQ_PIPELINE_DATA_COUNT
`define OW_RX_IQ_PIPELINE_DATA_COUNT 1
`endif
`endif

// Timing-closure isolation: timing-d keeps timing-c and re-enables RX IQ rate adaptation.
`ifdef OW_PROFILE_NB10_TIMING_D
`ifndef OW_PROFILE_NB10_TIMING_C
`define OW_PROFILE_NB10_TIMING_C 1
`endif
`ifndef OW_RX_IQ_RATE_ADAPTATION_NONBYPASS
`define OW_RX_IQ_RATE_ADAPTATION_NONBYPASS 1
`endif
`endif

// Timing-closure isolation: timing-c keeps timing-b and adds OW10 RX/TX timing knobs.
`ifdef OW_PROFILE_NB10_TIMING_C
`ifndef OW_PROFILE_NB10_TIMING_B
`define OW_PROFILE_NB10_TIMING_B 1
`endif
`ifndef OW_PHY_RX_START_DELAY_2G_US
`define OW_PHY_RX_START_DELAY_2G_US 48
`endif
`ifndef OW_PHY_RX_START_DELAY_5G_US
`define OW_PHY_RX_START_DELAY_5G_US 50
`endif
`ifndef OW_REL_DECODING_LATENCY_MUL
`define OW_REL_DECODING_LATENCY_MUL 50
`endif
`ifndef OW_TX_IQ_FILL_WAIT_US
`define OW_TX_IQ_FILL_WAIT_US   40
`endif
`endif

// Timing-closure isolation: timing-b keeps timing-a behavior and adds one XPU pipeline cut.
`ifdef OW_PROFILE_NB10_TIMING_B
`ifndef OW_PROFILE_NB10_TIMING_A
`define OW_PROFILE_NB10_TIMING_A 1
`endif
`ifndef OW_XPU_PIPELINE_REL_DECODING_LATENCY
`define OW_XPU_PIPELINE_REL_DECODING_LATENCY 1
`endif
`endif

// Timing-closure isolation: OW10 identity and MAC xIFS constants, stock sample cadence.
`ifdef OW_PROFILE_NB10_TIMING_A
`ifndef OW_PROFILE_ID
`define OW_PROFILE_ID           32'h4F573130  // "OW10"
`endif
`ifndef OW_PROFILE_BW_MHZ
`define OW_PROFILE_BW_MHZ       10
`endif
`ifndef OW_PROFILE_META
`define OW_PROFILE_META         32'h0001000A  // ABI 1, 10 MHz
`endif
`ifndef OW_SAMPLING_RATE_MHZ
`define OW_SAMPLING_RATE_MHZ    20
`endif
`ifndef OW_PREAMBLE_SIGNAL_US
`define OW_PREAMBLE_SIGNAL_US   40
`endif
`ifndef OW_OFDM_SYMBOL_US
`define OW_OFDM_SYMBOL_US       8
`endif
`ifndef OW_SLOT_SHORT_US
`define OW_SLOT_SHORT_US        18
`endif
`ifndef OW_SLOT_LONG_US
`define OW_SLOT_LONG_US         40
`endif
`ifndef OW_SIFS_2G_US
`define OW_SIFS_2G_US           20
`endif
`ifndef OW_SIFS_5G_US
`define OW_SIFS_5G_US           32
`endif
`endif

`ifdef OW_PROFILE_NB10
`ifndef OW_PROFILE_ID
`define OW_PROFILE_ID           32'h4F573130  // "OW10"
`endif
`ifndef OW_PROFILE_BW_MHZ
`define OW_PROFILE_BW_MHZ       10
`endif
`ifndef OW_PROFILE_META
`define OW_PROFILE_META         32'h0001000A  // ABI 1, 10 MHz
`endif
`ifndef OW_PREAMBLE_SIGNAL_US
`define OW_PREAMBLE_SIGNAL_US   40
`endif
`ifndef OW_OFDM_SYMBOL_US
`define OW_OFDM_SYMBOL_US       8
`endif
`ifndef OW_SLOT_SHORT_US
`define OW_SLOT_SHORT_US        18
`endif
`ifndef OW_SLOT_LONG_US
`define OW_SLOT_LONG_US         40
`endif
`ifndef OW_SIFS_2G_US
`define OW_SIFS_2G_US           20
`endif
`ifndef OW_SIFS_5G_US
`define OW_SIFS_5G_US           32
`endif
`ifndef OW_PHY_RX_START_DELAY_2G_US
`define OW_PHY_RX_START_DELAY_2G_US 48
`endif
`ifndef OW_PHY_RX_START_DELAY_5G_US
`define OW_PHY_RX_START_DELAY_5G_US 50
`endif
`ifndef OW_REL_DECODING_LATENCY_MUL
`define OW_REL_DECODING_LATENCY_MUL 50
`endif
`ifndef OW_TX_IQ_FILL_WAIT_US
`define OW_TX_IQ_FILL_WAIT_US   40
`endif
`endif

`ifndef OW_PROFILE_ID
`define OW_PROFILE_ID           32'h4F573230  // "OW20"
`endif
`ifndef OW_PROFILE_BW_MHZ
`define OW_PROFILE_BW_MHZ       20
`endif
`ifndef OW_PROFILE_META
`define OW_PROFILE_META         32'h00010014  // ABI 1, 20 MHz
`endif
`ifndef OW_PREAMBLE_SIGNAL_US
`define OW_PREAMBLE_SIGNAL_US   20
`endif
`ifndef OW_OFDM_SYMBOL_US
`define OW_OFDM_SYMBOL_US       4
`endif
`ifndef OW_SLOT_SHORT_US
`define OW_SLOT_SHORT_US        9
`endif
`ifndef OW_SLOT_LONG_US
`define OW_SLOT_LONG_US         20
`endif
`ifndef OW_SIFS_2G_US
`define OW_SIFS_2G_US           10
`endif
`ifndef OW_SIFS_5G_US
`define OW_SIFS_5G_US           16
`endif
`ifndef OW_PHY_RX_START_DELAY_2G_US
`define OW_PHY_RX_START_DELAY_2G_US 24
`endif
`ifndef OW_PHY_RX_START_DELAY_5G_US
`define OW_PHY_RX_START_DELAY_5G_US 25
`endif
`ifndef OW_REL_DECODING_LATENCY_MUL
`define OW_REL_DECODING_LATENCY_MUL 25
`endif
`ifndef OW_TX_IQ_FILL_WAIT_US
`define OW_TX_IQ_FILL_WAIT_US   20
`endif
`ifdef OW_PROFILE_NB10_TIMING_A
`ifndef OW_RX_IQ_RATE_ADAPTATION_NONBYPASS
`ifndef OW_RX_IQ_RATE_ADAPTATION_BYPASS
`define OW_RX_IQ_RATE_ADAPTATION_BYPASS 1
`endif
`endif
`endif
`ifndef OW_PROFILE_NB10
`ifndef OW_RX_IQ_RATE_ADAPTATION_NONBYPASS
`ifndef OW_RX_IQ_RATE_ADAPTATION_BYPASS
`define OW_RX_IQ_RATE_ADAPTATION_BYPASS 1
`endif
`endif
`endif

`ifndef OW_SAMPLING_RATE_MHZ
`define OW_SAMPLING_RATE_MHZ    `OW_PROFILE_BW_MHZ
`endif

`define SAMPLING_RATE_MHZ       `OW_SAMPLING_RATE_MHZ
`define ASSUMED_COUNTER_CLK_MHZ 10  // 10MHz is assumed in SW/driver for sub us resolutuion FPGA counters
`define NUM_CLK_PER_SAMPLE     ((`NUM_CLK_PER_US)/`SAMPLING_RATE_MHZ)
`define COUNT_TOP_1M           ((`NUM_CLK_PER_US)-1)
`define COUNT_SCALE            ((`NUM_CLK_PER_US)/(`ASSUMED_COUNTER_CLK_MHZ))
