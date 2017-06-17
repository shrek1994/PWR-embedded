GHDL := ghdl
TEST_BENCH := \
	ram_tb \
	pc_tb \
	acc_register_tb \
	controller_tb \
	alu_tb \
	main_line_tb

OBJ := $(TEST_BENCH:_tb=)
STOP_TIME := 1ms

all: $(TEST_BENCH)

$(TEST_BENCH): %_tb : % %.vhd
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

vhdl_txt: vhdl_txt.vhd
	$(GHDL) -a $@.vhd

dataType_pkg: dataType_pkg.vhd
	$(GHDL) -a $@.vhd

%: %.vhd vhdl_txt dataType_pkg
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@

clean:
	rm -f *.o *.vcd $(TEST_BENCH) $(OBJ) work-obj93.cf

.PHONY: all clean
