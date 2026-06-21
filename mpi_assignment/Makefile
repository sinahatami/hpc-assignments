CC = gcc
MPICC = mpicc
CFLAGS = -O3
LDFLAGS = -lm

TARGET_SEQ = pi_sequential
TARGET_MPI = pi_mpi

SRC_SEQ = pi_sequential.c
SRC_MPI = pi_mpi.c

all: $(TARGET_SEQ) $(TARGET_MPI)

$(TARGET_SEQ): $(SRC_SEQ)
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

$(TARGET_MPI): $(SRC_MPI)
	$(MPICC) $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGET_SEQ) $(TARGET_MPI)

.PHONY: all clean
