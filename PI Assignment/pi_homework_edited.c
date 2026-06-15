#include <stdio.h>
#include <mpi.h>

#define PI25DT 3.141592653589793238462643

#define INTERVALS 100000000000

int main(int argc, char **argv) {
    int i, intervals = INTERVALS;
    double x, dx, f, sum, pi;
    double time2;
    int num_procs, my_rank, chunk_size, start, end;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    if (my_rank == 0) {
        printf("Number of intervals: %d\n", intervals);
    }
    
    // determine chunk size and start/end indices for each process
    chunk_size = (intervals + num_procs - 1) / num_procs;
    start = my_rank * chunk_size + 1;
    end = (my_rank + 1) * chunk_size;
    if (end > intervals) {
        end = intervals;
    }

    // perform computation
    sum = 0.0;
    dx = 1.0 / (double) intervals;
    for (i = start; i <= end; i++) {
        x = dx * ((double) (i - 0.5));
        f = 4.0 / (1.0 + x*x);
        sum = sum + f;
    }

    // combine partial results using MPI reduction operation
    MPI_Reduce(&sum, &pi, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

    // compute elapsed time and print results from rank 0
    if (my_rank == 0) {
        time2 = MPI_Wtime();
        pi = dx*pi;
        printf("Computed PI %.24f\n", pi);
        printf("The true PI %.24f\n\n", PI25DT);
        printf("Elapsed time (s) = %.2lf\n", time2);
    }

    MPI_Finalize();
    return 0;
}


