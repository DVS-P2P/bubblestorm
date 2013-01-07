MLTON := ../../csupport/mlton
OPTS  := -inline-nonrec-small 100 -inline-leafa-size 30 -inline-nonrec-product 640 -max-function-size 40000

all:	32 64
	strip -s test-cusp.*.{32,64}
clean:
	rm -f test-cusp.*.{32,64}

32:	test-cusp.aes.32 test-cusp.mac.32 test-cusp.crc.32
64:	test-cusp.aes.64 test-cusp.mac.64 test-cusp.crc.64

test-cusp.%.32:
	echo "WHAT $*" > $@
	$(MLTON) $(OPTS) -mlb-path-map $@ -target i486-linux-gnu -output $@ test.mlb

test-cusp.%.64:
	echo "WHAT $*" > $@
	$(MLTON) $(OPTS) -mlb-path-map $@ -target x86_64-linux-gnu -output $@ test.mlb

demo:
	$(MLTON) $(OPTS) demo.mlb
