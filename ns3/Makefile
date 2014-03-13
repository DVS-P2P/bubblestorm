TARGETS=libsim-ns3.so
MLTON=../csupport/mlton
# NS3_INCLUDE_DIR=../../../ns-3-dev/src
# NS3_LIB_DIR=../../../ns-3-dev/build/debug

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

# bs-sim:	libsim-ns3.so $(NS3_LIB_DIR)/libns3.so 
# 	g++ -I$(NS3_INCLUDE_DIR) -L$(NS3_LIB_DIR) -lns3 bs-sim.cc bs-app.cc bs-event.cc

# bs-sim:	wscript libsim-ns3.so
# 	./waf
# 
# run:	libsim-ns3.so
# 	LD_LIBRARY_PATH=`pwd` ./waf --run bs-sim
# 
# dbg:	libsim-ns3.so
# 	LD_LIBRARY_PATH=`pwd` ./waf --run bs-sim --command-template="gdb --args %s"

# default compile options
# MLFLAGS=-drop-pass 'deepFlatten'
# for useful stack traces
MLFLAGS=@MLton gc-summary -- -profile-val true -profile-branch true -verbose 2 -drop-pass 'deepFlatten' -const 'Exn.keepHistory true'
# for profiling
# use mlprof -show-lines true simulator mlmon.out after running the simulator
# the database name doesn't get parsed correctly with profiling, 
# use the default database instead of a command line parameter
# MLFLAGS=-profile time -profile-stack true

%.so:	%.mlb .%.d
	$(MLTON) ${MLFLAGS} -mlb-path-map virtual-runtime -export-header $*.h -format library $<
.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -mlb-path-map virtual-runtime -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
