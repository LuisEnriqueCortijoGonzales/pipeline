#TOOL INPUT
SRC = *.v

COMPILER = iverilog
SIMULATOR = vvp

#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v

#TOOL OUTPUT
COUTPUT = compiler.out

###############################################################################
simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT)

$(COUTPUT): $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TESTBENCH) $(SRC)

clean:
	rm *.vcd
	rm *.out
