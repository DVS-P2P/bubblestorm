
CPP_BASE_DIR = ..
C_BASE_DIR = $(CPP_BASE_DIR)/../c

COMPILER = g++
CXXFLAGS = -Wall -O0 -g
CXXFLAGS += -I$(CPP_BASE_DIR) -I$(C_BASE_DIR) -L$(C_BASE_DIR)/bubblestorm

all:	libbubblestormcpp.a libbubblestormcpp-sim.a
# docs

clean:
	rm -rf *.o *.a html latex

docs:	Doxyfile
	rm -rf html latex
	doxygen $<
	make -C latex

libbubblestormcpp.a:	bubblestorm.cpp bubblestorm.h ../cusp/cusp-base.cpp ../cusp/cusp-base.h ../common/bscommon.cpp ../common/bscommon.h
	$(COMPILER) $(CXXFLAGS) -c bubblestorm.cpp -o bubblestorm.o
	ar rcs libbubblestormcpp.a bubblestorm.o

libbubblestormcpp-sim.a:	bubblestorm.cpp bubblestorm.h ../cusp/cusp-base.cpp ../cusp/cusp-base.h ../common/bscommon.cpp ../common/bscommon.h
	$(COMPILER) $(CXXFLAGS) -DBS_SIM -DSTATIC_LINK_BUBBLESTORM -c bubblestorm.cpp -o bubblestorm-sim.o
	ar rcs libbubblestormcpp-sim.a bubblestorm-sim.o