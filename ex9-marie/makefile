GHDL := ghdl
TEST_BENCH := \
	ram_tb \
	pc_tb \
	acc_register_tb \
	controller_tb \
	alu_tb

OBJ := $(TEST_BENCH:_tb=)

all: $(TEST_BENCH)

$(TEST_BENCH): %_tb : % %.vhd
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=1ms

vhdl_txt: vhdl_txt.vhd
	$(GHDL) -a $@.vhd

%: %.vhd vhdl_txt
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@

clean:
	rm -f *.o *.vcd $(TEST_BENCH) $(OBJ) work-obj93.cf

.PHONY: all clean
