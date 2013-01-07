
CPP_BASE_DIR = ..
C_BASE_DIR = $(CPP_BASE_DIR)/../c

COMPILER = g++
CXXFLAGS = -Wall -O0 -g
CXXFLAGS += -I$(CPP_BASE_DIR) -I$(C_BASE_DIR) -L$(C_BASE_DIR)/cusp

all:	libcuspcpp.a libcuspcpp-sim.a
# docs

clean:
	rm -rf *.o *.a html latex

docs:	Doxyfile
	rm -rf html latex
	doxygen $<
	make -C latex

libcuspcpp.a:	cusp.cpp cusp.h cusp-base.cpp cusp-base.h ../common/bscommon.cpp ../common/bscommon.h
	$(COMPILER) $(CXXFLAGS) -c cusp.cpp -o cusp.o
	ar rcs libcuspcpp.a cusp.o

# The simulator does not allow to control the main loop, so the main loop functions are not compiled for the simulator version
libcuspcpp-sim.a:	cusp.cpp cusp.h cusp-base.cpp cusp-base.h ../common/bscommon.cpp ../common/bscommon.h
	$(COMPILER) $(CXXFLAGS) -DBS_SIM -c cusp.cpp -o cusp-sim.o
	ar rcs libcuspcpp-sim.a cusp-sim.o
