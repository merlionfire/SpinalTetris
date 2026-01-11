#-----------------------------------------------------------------------------
#
# Filename    : Makefile
#
# Created by  : Tetris Core Testbench
#
# Description : Compile and simulate using Synopsys VCS with Verdi support
#
#-----------------------------------------------------------------------------

PROJ = tetris_core
TB_TOP = testbench

# Compiler and simulation tools
VCS = vcs
VERDI = verdi
URG = urg

# File lists
RTL_FILES = -f filelist.f
#TB_FILES = testbench.sv ${XILINX}/glbl.v ${XILINX}/unisims/RAMB16_S9.v  
TB_FILES = testbench.sv ps2_key_driver.sv ps2_scoreboard.sv
ALL_FILES = $(RTL_FILES) $(TB_FILES)

# Compilation options
VCS_COMP_OPTS = -full64 \
                -v  \
                -sverilog \
                +v2k \
                -timescale=1ns/1ps \
                -debug_access+all \
                -kdb \
                -lca \
                -LDFLAGS -Wl,--no-as-needed \
                +vcs+lic+wait \
                +define+SIM \
                -l compile.log

# Simulation options
SIM_OPTS = +define+SIM \
           +incdir+../rtl \
           -l sim.log

# Code coverage options
COV_OPTS = -cm line+cond+fsm+tgl+branch+assert \
           -cm_dir $(PROJ).vdb

# Coverage report options
COV_REPORT_DIR = $(PROJ)_cov_report

# Verdi FSDB dumping support
VERDI_OPTS = -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
             $(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a

# Build directory
SIMV = simv

#-----------------------------------------------------------------------------
# Targets
#-----------------------------------------------------------------------------

default: help

# Compile the design with VCS
comp:
	@echo "=============================================="
	@echo "Compiling with VCS..."
	@echo "=============================================="
	$(VCS) $(VCS_COMP_OPTS) $(VERDI_OPTS) $(COV_OPTS) \
	       $(ALL_FILES) \
	       -o $(SIMV) \
#	       -top $(TB_TOP)
	@echo "Compilation complete!"

# Compile without coverage
comp_no_cov:
	@echo "=============================================="
	@echo "Compiling with VCS (no coverage)..."
	@echo "=============================================="
	$(VCS) $(VCS_COMP_OPTS) $(VERDI_OPTS) \
	       $(ALL_FILES) \
	       -o $(SIMV) \
	       -top $(TB_TOP)
	@echo "Compilation complete!"

# Run simulation
run:
	@echo "=============================================="
	@echo "Running simulation..."
	@echo "=============================================="
	./$(SIMV) $(SIM_OPTS)
	@echo "Simulation complete!"

# Run simulation in GUI mode
run_gui:
	@echo "=============================================="
	@echo "Running simulation in GUI mode..."
	@echo "=============================================="
	./$(SIMV) -gui $(SIM_OPTS) &

# Compile and run
all: comp run

# Open Verdi with FSDB waveform
verdi:
	@echo "=============================================="
	@echo "Opening Verdi..."
	@echo "=============================================="
	$(VERDI) ${ALL_FILES} \
            -ssf cosim_verdi.fsdb \
            -rcFile /home/merlionfire/Verdi/novas.rc  \
            -guiConf /home/merlionfire/Verdi/novas.conf \
            -top $(TB_TOP) \
            -nologo &

# Open Verdi with source code (no FSDB yet)
verdi_src:
	@echo "=============================================="
	@echo "Opening Verdi with source..."
	@echo "=============================================="
	$(VERDI) -sverilog \
	         $(ALL_FILES) \
	         -top $(TB_TOP) \
	         -nologo &

# Generate coverage report in text format
cov_report:
	@echo "=============================================="
	@echo "Generating coverage report..."
	@echo "=============================================="
	$(URG) -dir $(PROJ).vdb \
	       -report $(COV_REPORT_DIR) \
	       -format both
	@echo "Coverage report generated in $(COV_REPORT_DIR)/"

# Generate coverage report and open in browser
cov_report_view: cov_report
	@echo "Opening coverage report in browser..."
	@if [ -f $(COV_REPORT_DIR)/index.html ]; then \
		xdg-open $(COV_REPORT_DIR)/index.html 2>/dev/null || \
		open $(COV_REPORT_DIR)/index.html 2>/dev/null || \
		echo "Please manually open $(COV_REPORT_DIR)/index.html"; \
	fi

# Clean build artifacts
clean:
	@echo "=============================================="
	@echo "Cleaning build artifacts..."
	@echo "=============================================="
	rm -rf $(SIMV) $(SIMV).daidir csrc
	rm -rf *.log *.vpd *.fsdb *.vdb
	rm -rf verdiLog novas* *_cov_report
	rm -rf DVEfiles urgReport
	rm -rf *.key AN.DB
	@echo "Clean complete!"

# Help information
help:
	@echo "=============================================="
	@echo "            MAKEFILE HELP"
	@echo "=============================================="
	@echo "comp            : Compile design with VCS (with coverage)"
	@echo "comp_no_cov     : Compile design with VCS (no coverage)"
	@echo "----------------------------------------------"
	@echo "run             : Run simulation in batch mode"
	@echo "run_gui         : Run simulation with DVE GUI"
	@echo "----------------------------------------------"
	@echo "all             : Compile and run simulation"
	@echo "----------------------------------------------"
	@echo "verdi           : Open Verdi with FSDB waveform"
	@echo "verdi_src       : Open Verdi with source code"
	@echo "----------------------------------------------"
	@echo "cov_report      : Generate coverage report"
	@echo "cov_report_view : Generate and view coverage report"
	@echo "----------------------------------------------"
	@echo "clean           : Remove all build artifacts"
	@echo "----------------------------------------------"
	@echo "help            : Print this help information"
	@echo "=============================================="

.PHONY: default comp comp_no_cov run run_gui all verdi verdi_src \
        cov_report cov_report_view clean help
