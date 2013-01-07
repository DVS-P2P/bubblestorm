TARGETS=kv-coordinator kv-fading kv-managed kv-durable kv-lookup kv-kademlia
MLTON=../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

%:	%.mlb .%.d
#	$(MLTON) @MLton gc-summary -- -link-opt "-lsqlite3" -profile-val true -profile-branch true -verbose 2 -drop-pass 'deepFlatten' -const 'Exn.keepHistory true' -output $@ $<
	$(MLTON) -link-opt "-lsqlite3" -drop-pass 'deepFlatten' -verbose 1 -output $@ $<
	strip $@

# exlipcit 32/64 bit builds (e.g., for live testbed experiments)
%.32:	%.mlb .%.d
	$(MLTON) -link-opt "-lsqlite3" -drop-pass 'deepFlatten' -verbose 1 -target i486-linux-gnu -output $@ $<
	strip $@
%.64:	%.mlb .%.d
	$(MLTON) -link-opt "-lsqlite3" -drop-pass 'deepFlatten' -verbose 1 -target x86_64-linux-gnu -output $@ $<
	strip $@

.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@files=$$(cat $@.tmp); for i in $${files##*:}; do if [ ! -f $$i ]; then echo Missing: $$i; fi; done
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
