TARGETS=csupport-linux32.a csupport-win32.a

AES_X64=aes128-block-3 aes128-constants aes128-expand-2
AES_X86=aes128-block   aes128-table     aes128-expand

POLY1305_X64=poly1305      poly1305-constants      poly1305_offs
POLY1305_X86=poly1305_ppro poly1305_ppro_constants poly1305_offs

MISC=signals copy crc32 icmp dup2

CURVE25519_X64=add sub mulC contract expand mul sqr powers
CURVE25519_X86=\
	curve25519_athlon_init       curve25519_athlon_const \
	curve25519_athlon_fromdouble curve25519_athlon_todouble \
	curve25519_athlon_mult       curve25519_athlon_square \
	curve25519_athlon_mainloop_wes

LINUX64=\
	$(patsubst %,%.linux64.o,$(AES_X64)) \
	$(patsubst %,%.linux64.o,$(POLY1305_X64)) \
	$(patsubst %,%.linux64.o,$(CURVE25519_X64)) \
	$(patsubst %,%.linux64.o,$(MISC))

DARWIN64=\
	$(patsubst %,%.darwin64.o,$(AES_X64)) \
	$(patsubst %,%.darwin64.o,$(POLY1305_X64)) \
	$(patsubst %,%.darwin64.o,$(CURVE25519_X64)) \
	$(patsubst %,%.darwin64.o,$(MISC))

WIN64=\
	$(patsubst %,%.win64.o,$(AES_X64)) \
	$(patsubst %,%.win64.o,$(POLY1305_X64)) \
	$(patsubst %,%.win64.o,$(CURVE25519_X64)) \
	$(patsubst %,%.win64.o,$(MISC))

LINUX32=\
	$(patsubst %,%.linux32.o,$(AES_X86)) \
	$(patsubst %,%.linux32.o,$(POLY1305_X86)) \
	$(patsubst %,%.linux32.o,$(CURVE25519_X86)) \
	$(patsubst %,%.linux32.o,$(MISC))

DARWIN32=\
	$(patsubst %,%.darwin32.o,$(AES_X86)) \
	$(patsubst %,%.darwin32.o,$(POLY1305_X86)) \
	$(patsubst %,%.darwin32.o,$(CURVE25519_X86)) \
	$(patsubst %,%.darwin32.o,$(MISC))

WIN32=\
	$(patsubst %,%.win32.o,$(AES_X86)) \
	$(patsubst %,%.win32.o,$(POLY1305_X86)) \
	$(patsubst %,%.win32.o,$(CURVE25519_X86)) \
	$(patsubst %,%.win32.o,$(MISC))

ARM=\
	$(patsubst %,%.arm.o,$(MISC))

nothing:
	@echo Pick a target: linux darwin mingw arm

linux:	linux/libbs-asm-amd64.a linux/libbs-asm-x86.a
darwin:	darwin/libbs-asm-amd64.a darwin/libbs-asm-x86.a
mingw:	mingw/libbs-asm-x86.a mingw/libbs-asm-amd64.a
arm:	linux/libbs-asm-arm.a

linux/libbs-asm-amd64.a:	$(LINUX64)
	rm -f $@
	ar crs $@ $^

darwin/libbs-asm-amd64.a:	$(DARWIN64)
	rm -f $@
	ar crs $@ $^

mingw/libbs-asm-amd64.a:	$(WIN64)
	rm -f $@
	x86_64-w64-mingw32-ar crs $@ $^

linux/libbs-asm-x86.a:	$(LINUX32)
	rm -f $@
	ar crs $@ $^

darwin/libbs-asm-x86.a:	$(DARWIN32)
	rm -f $@
	ar crs $@ $^

mingw/libbs-asm-x86.a:	$(WIN32)
	rm -f $@
	i586-mingw32msvc-ar crs $@ $^

linux/libbs-asm-arm.a:	$(ARM)
	rm -f $@
	arm-linux-androideabi-ar crs $@ $^

%.arm.o: %.c
	arm-linux-androideabi-gcc -Wall -O2 -c $< -o $@

clean:
	rm -f $(LINUX64) $(LINUX32) $(DARWIN64) $(DARWIN32) $(WIN32) $(WIN64)

# Used to reduce the size of a release tarball
tidy:
	rm -f *.gz *.bz2
	for i in */*.s */*/*.s; do \
		grep -v '^$$\|^#' < "$$i" > "$$i.tmp"; \
		mv "$$i.tmp" "$$i"; \
	done
	mkdir tmp
	cp $(wildcard $(patsubst %,curve25519-20050915/%.s,$(CURVE25519_X86))) tmp
	rm curve25519-20050915/*
	mv tmp/* curve25519-20050915
	cp $(wildcard $(patsubst %,poly1305aes-20050218/%.s,$(POLY1305_X86))) tmp
	cp poly1305aes-20050218/poly1305_ppro.h tmp
	rm poly1305aes-20050218/*
	mv tmp/* poly1305aes-20050218
	rmdir tmp

PARTS=powtrick powq inv loop
curve25519-wes-amd64/linux/powers.s:	$(patsubst %,curve25519-wes-amd64/linux/%.s,$(PARTS))
	cat $^ >$@
curve25519-wes-amd64/mingw/powers.s:	$(patsubst %,curve25519-wes-amd64/mingw/%.s,$(PARTS))
	cat $^ >$@

%.linux32.o:	poly1305aes-20050218/%.s
	sed 's/#LINUX //' < $< | gcc -m32 -o $@ -c -x assembler -
%.linux32.o:	curve25519-20050915/%.s
	sed 's/#LINUX //' < $< | gcc -m32 -o $@ -c -x assembler -
%.linux32.o:	aes128-mmx/%.s
	sed 's/#LINUX //' < $< | gcc -m32 -o $@ -c -x assembler -
%.linux32.o:	%.c
	gcc -m32 -fPIC -Wall -O2 -c $< -o $@

%.darwin32.o:	poly1305aes-20050218/%.s
	sed 's/#DARWIN //' < $< | gcc -m32 -o $@ -c -x assembler -
%.darwin32.o:	curve25519-20050915/%.s
	sed 's/#DARWIN //' < $< | gcc -m32 -o $@ -c -x assembler -
%.darwin32.o:	aes128-mmx/%.s
	sed 's/#DARWIN //' < $< | gcc -m32 -o $@ -c -x assembler -
%.darwin32.o:	%.c
	gcc -m32 -fPIC -Wall -O2 -c $< -o $@

%.win32.o:	poly1305aes-20050218/%.s
	sed 's/#MINGW //' < $< | i586-mingw32msvc-gcc -o $@ -c -x assembler -
%.win32.o:	curve25519-20050915/%.s
	sed 's/#MINGW //' < $< | i586-mingw32msvc-gcc -o $@ -c -x assembler -
%.win32.o:	aes128-mmx/%.s
	sed 's/#MINGW //' < $< | i586-mingw32msvc-gcc -o $@ -c -x assembler -
%.win32.o:	%.c
	i586-mingw32msvc-gcc -Wall -O2 -c $< -o $@

%.linux64.o:	curve25519-wes-amd64/linux/%.s
	gcc -m64 -o $@ -c $<
%.linux64.o:	poly1305aes-wes-amd64/linux/%.s
	gcc -m64 -o $@ -c $<
%.linux64.o:	poly1305aes-wes-amd64/%.s
	sed 's/^#LINUX //' < $< | gcc -m64 -o $@ -c -x assembler -
%.linux64.o:	%.c
	gcc -m64 -fPIC -Wall -O2 -c $< -o $@

%.darwin64.o:	curve25519-wes-amd64/linux/%.s
	gcc -m64 -o $@ -c $<
%.darwin64.o:	poly1305aes-wes-amd64/linux/%.s
	gcc -m64 -o $@ -c $<
%.darwin64.o:	poly1305aes-wes-amd64/%.s
	sed 's/^#DARWIN //' < $< | gcc -m64 -o $@ -c -x assembler -
%.darwin64.o:	%.c
	gcc -m64 -fPIC -Wall -O2 -c $< -o $@

%.win64.o:	curve25519-wes-amd64/mingw/%.s
	x86_64-w64-mingw32-gcc -m64 -o $@ -c $<
%.win64.o:	poly1305aes-wes-amd64/mingw/%.s
	x86_64-w64-mingw32-gcc -m64 -o $@ -c $<
%.win64.o:	poly1305aes-wes-amd64/%.s
	sed 's/^#MINGW //' < $< | x86_64-w64-mingw32-gcc -m64 -o $@ -c -x assembler -
%.win64.o:	%.c
	x86_64-w64-mingw32-gcc -m64 -Wall -O2 -c $< -o $@
