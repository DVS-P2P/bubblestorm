PROJECT_ROOT=../../..
MLTON=${PROJECT_ROOT}/csupport/mlton

UNAME := $(shell uname -s)

# OS-specific configuration
ifeq ($(UNAME),Linux)
TARGETS := libbubblestorm.so
# libbubblestorm.a
else
ifeq ($(UNAME),Darwin)
TARGETS := libbubblestorm.dylib
else
TARGETS := bubblestorm.dll
endif
endif

all:	$(TARGETS)

clean:
	rm -f $(TARGETS) libbubblestorm.h .*.d

# debug
# MLFLAGS = -drop-pass 'deepFlatten' -verbose 2 -profile-val true -profile-branch true -const "Exn.keepHistory true"
# non-debug
MLFLAGS = -drop-pass 'deepFlatten' -verbose 2

%.a:	%.mlb .%.d
	$(MLTON) -export-header $*.h ${MLFLAGS} -format archive $< ../common/libmain.c

%.so:	%.mlb .%.d
	$(MLTON) -export-header $*.h ${MLFLAGS} -format library $< ../common/libmain.c

%.dylib: %.mlb .%.d
	$(MLTON) -export-header $*.h ${MLFLAGS} -link-opt "-L. -lsqlite3"  -format library $< ../common/libmain.c

%.dll:	lib%.mlb .lib%.d
	$(MLTON) -export-header lib$*.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format library $< ../common/libmain.c

.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
