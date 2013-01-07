
CPP_BASE_DIR = ../..
C_BASE_DIR = $(CPP_BASE_DIR)/../c

COMPILER = g++
CXXFLAGS = -Wall -O0 -g
CXXFLAGS += -I$(CPP_BASE_DIR) -I$(C_BASE_DIR) -L$(C_BASE_DIR)/bubblestorm -Wall -O2

ARCH = $(shell uname -m)

TARGETS = node
# node-sim

all: $(TARGETS)

node: node.cpp main.cpp ../libbubblestormcpp.a
	$(COMPILER) $(CXXFLAGS) -c main.cpp
	$(COMPILER) $(CXXFLAGS) main.o ../libbubblestormcpp.a -o node -lgmp -lm -lsqlite3 -lbubblestorm

# node-sim: node.cpp
#	$(COMPILER) $(CXXFLAGS) -DBS_SIM -c node.cpp -o node.o
#	ar rcs node-sim.a node.o

clean:
	rm -f *.o *.a $(TARGETS)
