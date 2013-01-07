TARGETS=cusp-test reader sendzeros two-streams
MLTON=../../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

%:	%.mlb .%.d
   # for stack traces:
#	$(MLTON) -const 'Exn.keepHistory true' $<

   # 64 bit
#	$(MLTON) -target x86_64-linux-gnu $<

   # 32 bit
#	$(MLTON) -target x86 $<

   # 32 bit Windows
#	$(MLTON) -target i586-mingw32msvc $<

   # performance optimized
	$(MLTON) -inline-nonrec-small 100 -inline-leafa-size 30 -inline-nonrec-product 640 -max-function-size 40000 $<

.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
