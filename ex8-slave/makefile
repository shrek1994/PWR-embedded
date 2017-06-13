

slave_tb: slave_tb.vhd slave vhdl_txt pack
	@echo "napisac SPRAWKO !!!"
	ghdl -a $@.vhd
	ghdl -e $@
	ghdl -r $@ --vcd=$@.vcd --stop-time=1ms

%_tb: %_tb.vhd %
	ghdl -a $@.vhd
	ghdl -e $@
	ghdl -r $@ --vcd=$@.vcd --stop-time=1ms

vhdl_txt: vhdl_txt.vhd
	ghdl -a $@.vhd

pack: pack.vhd
	ghdl -a $@.vhd

%: %.vhd vhdl_txt pack
	ghdl -a $@.vhd
	ghdl -e $@


clean:
	rm -f *.o *.vcd slave slave_tb work-obj93.cf

.PHONY: slave_tb
