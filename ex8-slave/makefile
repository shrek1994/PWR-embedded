GHDL := ghdl
TEST_BENCH := \
	slave_tb

OBJ := $(TEST_BENCH:_tb=)
STOP_TIME := 1ms

all: $(TEST_BENCH)
	@#@echo "napisac SPRAWKO !!!"

$(TEST_BENCH): %_tb : % %.vhd
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

vhdl_txt: vhdl_txt.vhd
	$(GHDL) -a $@.vhd

pack: pack.vhd
	ghdl -a $@.vhd

%: %.vhd vhdl_txt pack
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@

clean:
	rm -f *.o *.vcd $(TEST_BENCH) $(OBJ) work-obj93.cf

.PHONY: all clean
