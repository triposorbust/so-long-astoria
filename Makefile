CC = gcc

CCFLAGS = -Isrc -I/usr/include -I/usr/lib/gcc/i686-linux-gnu/4.6/include -Wall -x objective-c
LDFLAGS = -Lbin -L/usr/lib/i386-linux-gnu -L/usr/lib/gcc/i686-linux-gnu/4.6 -lobjc -lX11 -lm

OBJECT = bin/Displayer.o bin/BHTree.o bin/Simulation.o bin/Simulation+Render.o \
         bin/main.o
TARGET = bin/solong
SYMLNK = ./solong

all: $(TARGET)

$(TARGET): $(OBJECT)
	@ $(CC) -o $@ $^ $(LDFLAGS)
	@ ln -sf $(TARGET) $(SYMLNK)

bin/main.o: main.m
	@ $(CC) $(CCFLAGS) -o $@ -c $<

bin/%.o: src/%.m src/%.h
	@ $(CC) $(CCFLAGS) -o $@ -c $<

bin/%.o: src/%.c src/%.h
	@ $(CC) $(CCFLAGS) -o $@ -c $<

.PHONY: clean
clean:
	@ rm -f $(OBJECT)
	@ rm -f $(TARGET)
	@ rm -f $(SYMLNK)
