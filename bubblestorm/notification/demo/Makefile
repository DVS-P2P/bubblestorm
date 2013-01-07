TARGETS=notified notifier
MLTON=../../../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

%:	%.mlb .%.d
	$(MLTON) -drop-pass 'deepFlatten' -profile-val true -profile-branch true -verbose 2 -const 'Exn.keepHistory true' $<
# 	$(MLTON) -drop-pass 'deepFlatten' -verbose 1 $<
.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
