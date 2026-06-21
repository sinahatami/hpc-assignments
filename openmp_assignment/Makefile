CC = gcc
CFLAGS = -fopenmp -O3
LDFLAGS = -lm

TARGET = dftw
SRC = dftw.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
