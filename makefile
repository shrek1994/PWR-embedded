

slave_tb: slave_tb.vhd slave_tb
	@echo "napisac SPRAWKO !!!"
	ghdl -a $@.vhd
	ghdl -e $@
	ghdl -r $@ --vcd=$@.vcd --stop-time=300ns

%_tb: %_tb.vhd %
	ghdl -a $@.vhd
	ghdl -e $@
	ghdl -r $@ --vcd=$@.vcd --stop-time=1ms

vhdl_txt: vhdl_txt.vhd
	ghdl -a $@.vhd

%: %.vhd vhdl_txt
	ghdl -a $@.vhd
	ghdl -e $@


clean:
	rm -f *.o *.vcd slave slave_tb work-obj93.cf 

.PHONY: slave_tb
