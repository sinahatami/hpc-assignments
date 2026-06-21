CC = nvcc
CFLAGS = -O3

TARGET = cuda_homework
SRC = cuda_homework.cu

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGET)

.PHONY: all clean
