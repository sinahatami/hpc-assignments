CXX = g++
MPICXX = mpicxx
NVCC = nvcc
CXXFLAGS = -O3 -std=c++11
OMPFLAGS = -fopenmp
NVCCFLAGS = -O3 -std=c++11

TARGETS = serial_bellman_ford openmp_bellman_ford mpi_bellman_ford cuda_bellman_ford

all: $(TARGETS)

serial_bellman_ford: serial_bellman_ford.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

openmp_bellman_ford: openmp_bellman_ford.cpp
	$(CXX) $(CXXFLAGS) $(OMPFLAGS) $< -o $@

mpi_bellman_ford: mpi_bellman_ford.cpp
	$(MPICXX) $(CXXFLAGS) $< -o $@

cuda_bellman_ford: cuda_bellman_ford.cu
	$(NVCC) $(NVCCFLAGS) $< -o $@

clean:
	rm -f $(TARGETS) output.txt

.PHONY: all clean
