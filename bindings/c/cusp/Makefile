PROJECT_ROOT=../../..
MLTON=${PROJECT_ROOT}/csupport/mlton

UNAME := $(shell uname -s)

# OS-specific configuration
ifeq ($(UNAME),Linux)
TARGETS := libcusp.so
# libcusp.a
else
ifeq ($(UNAME),Darwin)
TARGETS := libcusp.dylib
else
TARGETS := cusp.dll
endif
endif

all:	$(TARGETS)

clean:
	rm -f $(TARGETS) libcusp.h .*.d

# debug
#MLFLAGS = -const 'Exn.keepHistory true' -verbose 2
# non-debug
MLFLAGS = 

%.a:	%.mlb .%.d
	$(MLTON) -export-header $*.h ${MLFLAGS} -format archive $< ../common/libmain.c

%.so:	%.mlb .%.d
	$(MLTON) -export-header $*.h ${MLFLAGS} -format library $< ../common/libmain.c

%.dylib: %.mlb .%.d
	$(MLTON) -export-header $*.h ${MLFLAGS} -format library $< ../common/libmain.c

%.dll:	lib%.mlb .lib%.d
	$(MLTON) -export-header lib$*.h ${MLFLAGS} -link-opt "-L." -format library $< ../common/libmain.c

.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
