TARGETS=kademlia-test
MLTON=../../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

%:	%.mlb .%.d
	$(MLTON) -const 'Exn.keepHistory true' $<
#	$(MLTON) -target x86_64-linux-gnu $<
#	$(MLTON) -target i586-mingw32msvc $<
#	$(MLTON) $<
.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
