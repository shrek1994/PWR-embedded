all: ram_tb pc_tb

pc_tb: pc_tb.vhd pc
	ghdl -a $@.vhd
	ghdl -e $@
	ghdl -r $@ --vcd=$@.vcd --stop-time=1ms

ram_tb: ram_tb.vhd ram
	ghdl -a $@.vhd
	ghdl -e $@
	ghdl -r $@ --vcd=$@.vcd --stop-time=1ms

vhdl_txt: vhdl_txt.vhd
	ghdl -a $@.vhd

%: %.vhd vhdl_txt
	ghdl -a $@.vhd
	ghdl -e $@


clean:
	rm -f *.o *.vcd pc pc_tb ram ram_tb work-obj93.cf

.PHONY: ram_tb
