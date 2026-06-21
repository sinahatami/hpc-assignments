# High Performance Computing (HPC) Assignments

![C](https://img.shields.io/badge/Language-C-blue.svg)
![CUDA](https://img.shields.io/badge/Framework-CUDA-green.svg)
![OpenMP](https://img.shields.io/badge/Framework-OpenMP-blue.svg)
![MPI](https://img.shields.io/badge/Framework-MPI-orange.svg)
![University](https://img.shields.io/badge/University-Genoa-red.svg)

This repository contains the assignments and homework code for the **High Performance Computing** course at the **University of Genoa**. The projects demonstrate the use of parallel programming models including **CUDA**, **OpenMP**, and **MPI** to accelerate computationally intensive algorithms.

## 📋 Table of Contents
- [1. CUDA Assignment (Heat Equation)](#1-cuda-assignment-heat-equation)
- [2. OpenMP Assignment (Discrete Fourier Transform)](#2-openmp-assignment-discrete-fourier-transform)
- [3. MPI Assignment (Pi Calculation)](#3-mpi-assignment-pi-calculation)
- [Prerequisites](#prerequisites)

---

## 1. CUDA Assignment (Heat Equation)
**Folder:** `cuda_assignment/`

### Description
This assignment implements a parallelized solution to the 2D Heat Equation using Finite Difference Methods. It compares the execution time of a sequential CPU implementation against a parallelized GPU implementation using CUDA.

### Implementation Details
- Uses **CUDA** for massive parallelization on the GPU.
- Utilizes **Shared Memory** to optimize memory access patterns during the 5-point stencil derivative computation.
- Avoids out-of-bounds global memory accesses by properly mapping grid/block threads to global matrix indices.

### Compilation and Execution
```bash
cd cuda_assignment
make
./cuda_homework 1000 1000  # Dimensions of the 2D array
```

---

## 2. OpenMP Assignment (Discrete Fourier Transform)
**Folder:** `openmp_assignment/`

### Description
This project implements the Discrete Fourier Transform (DFT) and Inverse Discrete Fourier Transform (IDFT). It parallelizes the intensive nested loops using OpenMP to significantly decrease execution time.

### Implementation Details
- Parallelized using `#pragma omp parallel for` constructs.
- Properly scopes private vs. shared variables to avoid data race conditions.

### Compilation and Execution
```bash
cd openmp_assignment
make
./dftw
```

---

## 3. MPI Assignment (Pi Calculation)
**Folder:** `mpi_assignment/`

### Description
Calculates the value of $\pi$ (Pi) using numerical integration by approximating the area under the curve $f(x) = \frac{4}{1 + x^2}$ from $0$ to $1$.

### Implementation Details
- **Sequential Version:** (`pi_sequential.c`) Computes the integral sequentially. Uses `long long int` to gracefully handle an extremely high number of intervals ($100 \times 10^9$) without integer overflow.
- **MPI Version:** (`pi_mpi.c`) Divides the integral range across multiple processes using Message Passing Interface (MPI). It utilizes `MPI_Reduce` to efficiently aggregate the partial sums computed by each node into the final $\pi$ value.

### Compilation and Execution
```bash
cd mpi_assignment

# Compile both versions
make

# Run sequential version
./pi_sequential

# Run MPI version
mpirun -np 4 ./pi_mpi  # Run with 4 processes
```

---

## 🛠️ Prerequisites
To compile and run all the assignments in this repository, you will need:
- **GCC** with OpenMP support (`-fopenmp` flag)
- **CUDA Toolkit** (for `nvcc` and GPU execution)
- **MPI Implementation** (e.g., OpenMPI or MPICH for `mpicc` and `mpirun`)
- **Make** (for building the projects)

## 🚀 Building All Projects
You can build all the assignments at once using the provided Makefile at the root directory:
```bash
make
```

To clean all compiled executables:
```bash
make clean
```

---
*University of Genoa - High Performance Computing*
