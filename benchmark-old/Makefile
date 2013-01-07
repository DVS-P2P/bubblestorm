TARGETS=kv-fading kv-managed kv-durable kv-kademlia
MLTON=../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

%:	%.mlb .%.d
#	$(MLTON) @MLton gc-summary -- -link-opt "-lsqlite3" -profile-val true -profile-branch true -verbose 2 -drop-pass 'deepFlatten' -const 'Exn.keepHistory true' $<
	$(MLTON) -link-opt "-lsqlite3" -drop-pass 'deepFlatten' -verbose 1 $<
.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
