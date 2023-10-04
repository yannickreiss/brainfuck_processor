CHDL		=	ghdl
FLAGS		=	--std=08
STOP		=	9000ns

all:	tb/tb_bfpu.vhd src/bfpu.vhd
	$(CHDL) -a $(FLAGS) src/alu.vhd src/branch.vhd src/cellMemory.vhd src/instructionMemory.vhd src/memoryPointer.vhd src/programCounter.vhd src/bfpu.vhd tb/tb_bfpu.vhd
	$(CHDL) -e $(FLAGS) bfpu_tb
	$(CHDL) -r $(FLAGS) bfpu_tb --wave=bpfu.ghw --stop-time=$(STOP)

clean:
	find . -name '*.o' -exec rm -r {} \;
	find . -name '*.cf' -exec rm -r {} \;
	find . -name '*.ghw' -exec rm -r {} \;
	find . -name '*_tb' -exec rm -r {} \;
