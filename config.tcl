# Design Name
set ::env(DESIGN_NAME) "FPU"

# Project Files
set ::env(DESIGN_DIR) [file dirname [file normalize [info script]]]
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/**/*.v]

# Timing
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) 10
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

# Floorplanning
set ::env(FP_SIZING) "relative"
set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) 0.45

# Optimization Strategy
set ::env(SYNTH_STRATEGY) "DELAY 0"
set ::env(SYNTH_MAX_FANOUT) 10

# Power Grid
set ::env(FP_PDN_VPITCH) 180
set ::env(FP_PDN_HPITCH) 180