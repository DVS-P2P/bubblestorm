PROJECT_ROOT=../../..
MLTON=${PROJECT_ROOT}/csupport/mlton

SQLITE_NAME=sqlite-amalgamation-3071401
SQLITE_ARCHIVE=${SQLITE_NAME}.zip
SQLITE_URL=http://www.sqlite.org/${SQLITE_ARCHIVE}

UNAME := $(shell uname -s)

TARGETS := libbubblestorm.so libcusp.so

all:	$(TARGETS)

clean:
	rm -f $(TARGETS) libbubblestorm.h .*.d
	rm -rf libsqlite3.so $(SQLITE_NAME) $(SQLITE_ARCHIVE)

# SQLite3
$(SQLITE_ARCHIVE):
	wget $(SQLITE_URL)
$(SQLITE_NAME)/sqlite3.c:	$(SQLITE_ARCHIVE)
	unzip $<
	touch $@
libsqlite3.so:	$(SQLITE_NAME)/sqlite3.c
	arm-linux-androideabi-gcc -shared -o $@ $<
	arm-linux-androideabi-strip $@

# debug
#MLFLAGS = -target arm-linux-androideabi -drop-pass 'deepFlatten' -verbose 2 -profile-val true -profile-branch true -const "Exn.keepHistory true"
# non-debug
MLFLAGS = -target arm-linux-androideabi -drop-pass 'deepFlatten' -verbose 2

libbubblestorm.a:	../bubblestorm/libbubblestorm.mlb .libbubblestorm.d libsqlite3.so
	$(MLTON) -export-header libbubblestorm.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format archive -output $@ $<

libbubblestorm.so:	../bubblestorm/libbubblestorm.mlb .libbubblestorm.d libsqlite3.so
	$(MLTON) -export-header libbubblestorm.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format library -output $@ $<
	arm-linux-androideabi-strip $@

.libbubblestorm.d:	../bubblestorm/libbubblestorm.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

libcusp.a:	../cusp/libcusp.mlb .libcusp.d libsqlite3.so
	$(MLTON) -export-header libcusp.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format archive -output $@ $<

libcusp.so:	../cusp/libcusp.mlb .libcusp.d libsqlite3.so
	$(MLTON) -export-header libcusp.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format library -output $@ $<
	arm-linux-androideabi-strip $@

.libcusp.d:	../cusp/libcusp.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

# lib%.a:	$(wildcard $(subst X,%,../X/libX.mlb)) .lib%.d libsqlite3.so
# 	$(MLTON) -export-header $*.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format archive -output $@ $<
# 
# lib%.so:	$(wildcard $(subst X,%,../X/libX.mlb)) .lib%.d libsqlite3.so
# 	$(MLTON) -export-header $*.h ${MLFLAGS} -link-opt "-L. -lsqlite3" -format library -output $@ $<
# 	arm-linux-androideabi-strip $@
# 
# .lib%.d:	../%/lib%.mlb
# 	@echo Analyzing dependencies for $<
# 	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
# 	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
