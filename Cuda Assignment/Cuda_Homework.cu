


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include "cuda_runtime.h"



// Simple define to index into a 1D array from 2D space
#define I2D(num, c, r) ((r)*(num)+(c))
/*
 * `step_kernel_ref` is currently a direct copy of the CPU reference solution
 * `step_kernel_mod` below. Accelerate it to run as a CUDA kernel.
 */
#define BLOCK_SIZE_X 32
#define BLOCK_SIZE_Y 32

__global__ void step_kernel_mod(int ni, int nj, float fact, float* temp_in, float* temp_out)
{
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  int j = blockIdx.y * blockDim.y + threadIdx.y;

  // Allocate shared memory
  __shared__ float shared_temp[BLOCK_SIZE_X + 2][BLOCK_SIZE_Y + 2];

  // Shared memory indices
  int si = threadIdx.x + 1;
  int sj = threadIdx.y + 1;

  // Copy data to shared memory
  if (i < ni && j < nj) {
    shared_temp[si][sj] = temp_in[I2D(ni, i, j)];
  }

  // Load boundary data
  if (threadIdx.x == 0 && i > 0 && j < nj) {
    shared_temp[si - 1][sj] = temp_in[I2D(ni, i - 1, j)];
  }
  if (threadIdx.x == blockDim.x - 1 && i < ni - 1 && j < nj) {
    shared_temp[si + 1][sj] = temp_in[I2D(ni, i + 1, j)];
  }
  if (threadIdx.y == 0 && j > 0 && i < ni) {
    shared_temp[si][sj - 1] = temp_in[I2D(ni, i, j - 1)];
  }
  if (threadIdx.y == blockDim.y - 1 && j < nj - 1 && i < ni) {
    shared_temp[si][sj + 1] = temp_in[I2D(ni, i, j + 1)];
  }

  __syncthreads();  // Synchronize threads to ensure data is loaded into shared memory

  // Conditioning to avoid out-of-bounds error
  if ((i > 0 && i < ni - 1) && (j > 0 && j < nj - 1)) {
    int i00 = I2D(ni, i, j);

    // Evaluate derivatives using shared memory
    float d2tdx2 = shared_temp[si - 1][sj] - 2 * shared_temp[si][sj] + shared_temp[si + 1][sj];
    float d2tdy2 = shared_temp[si][sj - 1] - 2 * shared_temp[si][sj] + shared_temp[si][sj + 1];

    // Update temperatures
    temp_out[i00] = shared_temp[si][sj] + fact * (d2tdx2 + d2tdy2);
  }
}

void step_kernel_ref(int ni, int nj, float fact, float* temp_in, float* temp_out)
{
  int i00, im10, ip10, i0m1, i0p1;
  float d2tdx2, d2tdy2;

  // loop over all points in domain (except boundary)
  for ( int j=1; j < nj-1; j++ ) {
    for ( int i=1; i < ni-1; i++ ) {
      // find indices into linear memory
      // for central point and neighbours
      i00 = I2D(ni, i, j);
      im10 = I2D(ni, i-1, j);
      ip10 = I2D(ni, i+1, j);
      i0m1 = I2D(ni, i, j-1);
      i0p1 = I2D(ni, i, j+1);

      // evaluate derivatives
      d2tdx2 = temp_in[im10]-2*temp_in[i00]+temp_in[ip10];
      d2tdy2 = temp_in[i0m1]-2*temp_in[i00]+temp_in[i0p1];

      // update temperatures
      temp_out[i00] = temp_in[i00]+fact*(d2tdx2 + d2tdy2);
    }
  }
}




int main(int argc, char **argv)
{
  if(argc < 3){
    printf("\nPlease insert dimension of 2D array (e.g. 1000  1000)\n");
    return;
  }
  int istep;
  int nstep = 200; // number of time steps

  // Specify our 2D dimensions
  const int ni = atoi(argv[1]);
  const int nj = atoi(argv[2]);
  printf("\ninput matrix dimensions: %d x %d\n", ni, nj);
  float tfac = 8.418e-5; // thermal diffusivity of silver

  float *temp1_ref, *temp2_ref, *temp_tmp, *temp1_mod, *temp2_mod, *dev_temp1, *dev_temp2, *dev_tmp;

  const int  size = ni * nj * sizeof(float);

  temp1_ref = (float*)malloc(size);
  temp2_ref = (float*)malloc(size);
  temp1_mod = (float*)malloc(size);
  temp2_mod = (float*)malloc(size);


  cudaMalloc((void**)&dev_temp1, size);
  cudaMalloc((void**)&dev_temp2, size);



  // Initialize with random data
  for( int i = 0; i < ni*nj; ++i) {
    temp1_ref[i] = temp2_ref[i] = temp1_mod[i] = temp2_mod[i] = (float)rand()/(float)(RAND_MAX/100.0f);
  }

    // for smaller numbers we will execute on cpu. 
  if(ni <= 10000){
  //Execute the CPU-only reference version
    time_t time1 = clock();
    for (istep=0; istep < nstep; istep++) {
      step_kernel_ref(ni, nj, tfac, temp1_ref, temp2_ref);

      // swap the temperature pointers
      temp_tmp = temp1_ref;
      temp1_ref = temp2_ref;
      temp2_ref= temp_tmp;
    }
    double runtime = (clock() - time1) / (double) CLOCKS_PER_SEC;
    printf("CPU Version, Elapsed time (s) = %.2lf\n", runtime);

  }

  // Time Measurement in CUDA
  cudaEvent_t start, end;
  cudaEventCreate(&start);
  cudaEventCreate(&end);
  float elapsedTime;
  // Define the number of blocks and threads per blocks
  dim3 threads(32, 32);
  dim3 blocks ((ni + threads.x-1)/threads.x, (nj + threads.y-1)/threads.y );

  cudaEventRecord(start, 0);
  //Copy the from host to device.
    cudaMemcpy(dev_temp1, temp1_mod, size, cudaMemcpyHostToDevice);
    cudaMemcpy(dev_temp2, temp2_mod, size, cudaMemcpyHostToDevice);
    for (istep=0; istep < nstep; istep++) {

      step_kernel_mod<<<blocks, threads>>>(ni, nj, tfac, dev_temp1, dev_temp2);
      // swap the temperature pointers
      dev_tmp = dev_temp1;
      dev_temp1 = dev_temp2;
      dev_temp2= dev_tmp;

    }
    //copy from device to host
    cudaMemcpy(temp1_mod, dev_temp1, size, cudaMemcpyDeviceToHost);

  cudaEventRecord(end, 0);
  cudaEventSynchronize(end);
  cudaEventElapsedTime(&elapsedTime, start, end);
  printf("GPU Version, Elapsed time (s) = %.2lf\n", elapsedTime/1000);
  cudaEventDestroy(start);
  cudaEventDestroy(end);

  if(ni <= 10000){
    float maxError = 0;
    // Output should always be stored in the temp1 and temp1_ref at this point
    for( int i = 0; i < ni*nj; ++i ) {
      if (abs(temp1_mod[i]-temp1_ref[i]) > maxError) { maxError = abs(temp1_mod[i]-temp1_ref[i]); }
    }

    // Check and see if our maxError is greater than an error bound
    if (maxError > 0.0005f)
      printf("Problem! The Max Error of %.5f is NOT within acceptable bounds.\n", maxError);
    else
      printf("The Max Error of %.5f is within acceptable bounds.\n", maxError);
  }


// Free the allocated memory.
  free( temp1_ref );
  free( temp2_ref );
  free( temp1_mod );
  free( temp2_mod );
  cudaFree(dev_temp1);
  cudaFree(dev_temp2);

  return 0;
}
