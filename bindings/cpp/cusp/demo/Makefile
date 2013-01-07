
CPP_BASE_DIR = ../..
C_BASE_DIR = $(CPP_BASE_DIR)/../c

COMPILER = g++
CXXFLAGS = -Wall -O0 -g
CXXFLAGS += -I$(CPP_BASE_DIR) -I$(C_BASE_DIR) -L$(C_BASE_DIR)/cusp -Wall -O2

ARCH = $(shell uname -m)

TARGETS = client server

all: $(TARGETS)

client: client.o ../libcuspcpp.a
	$(COMPILER) $(CXXFLAGS) client.o ../libcuspcpp.a -o client -lcusp -lgmp -lm -lsqlite3

server: server.o ../libcuspcpp.a
	$(COMPILER) $(CXXFLAGS) server.o ../libcuspcpp.a -o server -lcusp -lgmp -lm -lsqlite3

clean:
	rm -f *.o $(TARGETS)

%.o: %.cpp
	$(COMPILER) $(CXXFLAGS) -c $< -o $@
