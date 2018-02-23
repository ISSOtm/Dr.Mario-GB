

.PHONY: all compare clean rebuild


CFLAGS = -E -h
LFLAGS = -dt



all: "Dr. Mario (V1.0).gb"


compare: all
	sha1sum -c sums.sha1


clean:
	rm -f *.gb
	rm -f *.o

rebuild: clean all


"Dr. Mario (V1.0).gb": main.o memory.o
	rgblink -o $@ -m $(@:.gb=.map) -n $(@:.gb=.sym) $(LFLAGS) $^

%.o: %.asm constants.asm
	rgbasm -o $@ $(CFLAGS) $<

