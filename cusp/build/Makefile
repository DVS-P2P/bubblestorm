SVN  = https://www.dvs.tu-darmstadt.de/svn/projects/BubbleStorm/Middleware/trunk
REV  = $(HEAD)
DATE = $(shell date +%Y%m%d)

HEAD := $(shell svn info "$(SVN)" | grep ^Revision | cut -d" " -f2)
PACKAGE = cusp-r$(REV)-$(DATE)

SRC_PACKAGE   = $(PACKAGE).src.tar.gz
DOCS_PACKAGE  = $(PACKAGE).docs.tar.gz
LIN32_PACKAGE = $(PACKAGE).linux-32.tar.gz
LIN64_PACKAGE = $(PACKAGE).linux-64.tar.gz
WIN32_PACKAGE = $(PACKAGE).windows-32.tar.gz
WIN64_PACKAGE = $(PACKAGE).windows-64.tar.gz

BIN_PACKAGE   = $(PACKAGE)/build/include/cusp.h

all:	$(SRC_PACKAGE) $(DOCS_PACKAGE) \
	$(LIN32_PACKAGE) $(LIN64_PACKAGE) \
	$(WIN32_PACKAGE) $(WIN64_PACKAGE)

$(SRC_PACKAGE):
	test -d "$(PACKAGE)" || mkdir "$(PACKAGE)"
	for i in csupport util crypto system cusp sqlite; do \
		svn export -r "$(REV)" "$(SVN)/$$i" "$(PACKAGE)/$$i"; \
	done
	make -C "$(PACKAGE)/csupport" tidy
	tar cvzf "$@" "$(PACKAGE)"

$(DOCS_PACKAGE):	$(SRC_PACKAGE)
	test  -d "$(PACKAGE)/docs" || \
	mkdir -p "$(PACKAGE)/docs"
	make -C "$(PACKAGE)/cusp/cbindings" docs
	mv "$(PACKAGE)/cusp/cbindings/latex/refman.pdf" "$(PACKAGE)/docs/cusp.pdf"
	mv "$(PACKAGE)/cusp/cbindings/html" "$(PACKAGE)/docs/cusp"
	tar cvzf "$@" "$(PACKAGE)/docs"

$(BIN_PACKAGE):	$(SRC_PACKAGE)
	test  -d "$(PACKAGE)/build" || \
	mkdir -p "$(PACKAGE)/build"
	cp -a "$(PACKAGE)/cusp/cbindings/demo"    "$(PACKAGE)/build"
	cp -a "$(PACKAGE)/cusp/cbindings/include" "$(PACKAGE)/build"

$(LIN32_PACKAGE):	$(BIN_PACKAGE)
	test  -d "$(PACKAGE)/build/linux-32/static" || \
	mkdir -p "$(PACKAGE)/build/linux-32/static"
	test  -d "$(PACKAGE)/build/linux-32/dynamic" || \
	mkdir -p "$(PACKAGE)/build/linux-32/dynamic"
	echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb
	cd "$(PACKAGE)/build/linux-32/static" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target i486-linux-gnu \
			-format archive \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	cd "$(PACKAGE)/build/linux-32/dynamic" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target i486-linux-gnu \
			-format library \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	tar cvzf "$@" \
		"$(PACKAGE)/build/linux-32" \
		"$(PACKAGE)/build/demo" \
		"$(PACKAGE)/build/include"

$(LIN64_PACKAGE):	$(BIN_PACKAGE)
	test  -d "$(PACKAGE)/build/linux-64/static" || \
	mkdir -p "$(PACKAGE)/build/linux-64/static"
	test  -d "$(PACKAGE)/build/linux-64/dynamic" || \
	mkdir -p "$(PACKAGE)/build/linux-64/dynamic"
	cd "$(PACKAGE)/build/linux-64/static" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target x86_64-linux-gnu \
			-format archive \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	cd "$(PACKAGE)/build/linux-64/dynamic" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target x86_64-linux-gnu \
			-format library \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	tar cvzf "$@" \
		"$(PACKAGE)/build/linux-64" \
		"$(PACKAGE)/build/demo" \
		"$(PACKAGE)/build/include"

$(WIN32_PACKAGE):	$(BIN_PACKAGE)
	test  -d "$(PACKAGE)/build/windows-32/static" || \
	mkdir -p "$(PACKAGE)/build/windows-32/static"
	test  -d "$(PACKAGE)/build/windows-32/dynamic" || \
	mkdir -p "$(PACKAGE)/build/windows-32/dynamic"
	cd "$(PACKAGE)/build/windows-32/static" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target i586-mingw32msvc \
			-format archive \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	cd "$(PACKAGE)/build/windows-32/dynamic" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target i586-mingw32msvc \
			-format library \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	tar cvzf "$@" \
		"$(PACKAGE)/build/windows-32" \
		"$(PACKAGE)/build/demo" \
		"$(PACKAGE)/build/include"

$(WIN64_PACKAGE):	$(BIN_PACKAGE)
	test  -d "$(PACKAGE)/build/windows-64/static" || \
	mkdir -p "$(PACKAGE)/build/windows-64/static"
	test  -d "$(PACKAGE)/build/windows-64/dynamic" || \
	mkdir -p "$(PACKAGE)/build/windows-64/dynamic"
	cd "$(PACKAGE)/build/windows-64/static" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target amd64-mingw32msvc \
			-format archive \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	cd "$(PACKAGE)/build/windows-64/dynamic" && \
		echo "../../../cusp/cbindings/libcusp.mlb" > libcusp.mlb && \
		../../../csupport/mlton \
			-target amd64-mingw32msvc \
			-format library \
			-export-header ../../include/libcusp.h \
			libcusp.mlb && \
		rm -f libcusp.mlb
	tar cvzf "$@" \
		"$(PACKAGE)/build/windows-64" \
		"$(PACKAGE)/build/demo" \
		"$(PACKAGE)/build/include"
