GHDL := ghdl
TEST_BENCH := \
	ram_tb \
	pc_tb \
	acc_register_tb \
	alu_tb \
	controller_tb \
	main_line_tb

INTEGRATION_TESTS := \
	ram_pc_tb \
	ram_pc_acc_tb \
	alu_acc_tb \
	factorial_tb

OBJ := $(TEST_BENCH:_tb=)
STOP_TIME := 1ms

all: $(TEST_BENCH) $(INTEGRATION_TESTS)
	@#@echo "napisac SPRAWKO !!!"

factorial_tb: % : %.vhd ram pc controller alu acc_register
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

alu_acc_tb: % : %.vhd alu acc_register
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

ram_pc_tb: % : %.vhd ram pc
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

ram_pc_acc_tb: % : %.vhd ram pc acc_register
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

$(TEST_BENCH): %_tb : % %.vhd
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@
	$(GHDL) -r $@ --vcd=$@.vcd --stop-time=$(STOP_TIME)

vhdl_txt: vhdl_txt.vhd
	$(GHDL) -a $@.vhd

utills: utills.vhd
	$(GHDL) -a $@.vhd

%: %.vhd vhdl_txt utills
	$(GHDL) -a $@.vhd
	$(GHDL) -e $@

clean:
	rm -f *.o *.vcd $(TEST_BENCH) $(INTEGRATION_TESTS) $(OBJ) work-obj93.cf

.PHONY: all clean
