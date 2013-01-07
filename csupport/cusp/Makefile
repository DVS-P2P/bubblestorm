ifeq ($(findstring MINGW,$(shell uname -s)), MINGW)
TARGETS=cusp-icmp-svc cusp-icmp-svc-test
else
TARGETS=cusp-icmp-send cusp-icmp-recv
endif

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) $(TARGETS:%=%.exe) *.o

cusp-icmp-recv:	cusp-icmp-recv.o icmp-packet.o my-ip-address.o
	gcc -Wall -O2 -o $@ $^

cusp-icmp-send:	cusp-icmp-send.o icmp-packet.o
	gcc -Wall -O2 -o $@ $^

cusp-icmp-svc:	cusp-icmp-svc.o cusp-icmp-svc-win.o icmp-packet.o
	gcc -Wall -O2 -o $@ $^ -lws2_32

cusp-icmp-svc-test:	cusp-icmp-svc.o cusp-icmp-svc-test.o icmp-packet.o
	gcc -Wall -O2 -o $@ $^ -lws2_32

# Service configuration for Windows needs administrator privileges!
service-install:	cusp-icmp-svc
	sc.exe create CUSP-ICMP binpath= "$(CURDIR)/cusp-icmp-svc.exe"
	sc.exe start CUSP-ICMP

service-uninstall:
	sc.exe stop CUSP-ICMP
	sc.exe delete CUSP-ICMP

%.o:	%.c
	gcc -Wall -O2 -c -o $@ $<
