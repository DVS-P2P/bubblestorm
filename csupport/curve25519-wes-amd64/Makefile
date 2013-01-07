TARGET=linux
CC=gcc

curve25519-wes.a:	curve25519-wes.o add.o sub.o mulC.o contract.o expand.o mul.o sqr.o powers.o
	rm -f $@
	ar crs $@ $^
	ranlib $@

$(TARGET)/powers.s: $(TARGET)/powtrick.s $(TARGET)/powq.s $(TARGET)/inv.s $(TARGET)/loop.s
	cat $^ >$@

%.o:	$(TARGET)/%.s
	$(CC) -m64 -o $@ -c $<

%.o:	%.c
	$(CC) -m64 -O2 -Wall -o $@ -c $<
