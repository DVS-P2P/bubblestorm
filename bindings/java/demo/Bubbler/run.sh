#!/bin/bash
SWT_LIB=/usr/share/swt-3.5/lib/swt.jar
BINDINGS_BASE="../../.."
BINDINGS_JAVA_BASE="../.."
export LD_LIBRARY_PATH="${BINDINGS_BASE}/c/bubblestorm:${BINDINGS_JAVA_BASE}/bubblestorm"
java -cp bin:lib/commons-cli-1.2.jar:${BINDINGS_JAVA_BASE}/common/bin:${BINDINGS_JAVA_BASE}/cusp/bin:${BINDINGS_JAVA_BASE}/bubblestorm/bin:${SWT_LIB} net.bubblestorm.bubbler.Bubbler $*
