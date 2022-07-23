#include <stdint.h>
#include <cuda_runtime.h>

__global__ void vectorAdd(const int32_t *A, const int32_t *B, int32_t *C, uint64_t numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < numElements) {
        C[i] = A[i] + B[i];
    }
}

#ifdef __cplusplus
extern "C" {
#endif
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements)
{
    // Error code to check return values for CUDA calls
    cudaError_t err = cudaSuccess;
    
    // compute numElements
    int size = numElements * sizeof(int32_t);

    // Verify that allocations succeeded
    if (h_A == NULL || h_B == NULL || h_C == NULL) {
        return false;
    }

    // Allocate the device input vector A
    int32_t *d_A = NULL;
    err = cudaMalloc((void **)&d_A, size);
    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to allocate device vector A (error code %s)!\n",
        //    cudaGetErrorString(err));
        return false;
    }

    // Allocate the device input vector B
    int32_t *d_B = NULL;
    err = cudaMalloc((void **)&d_B, size);
    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to allocate device vector B (error code %s)!\n",
        //    cudaGetErrorString(err));
        return false;
    }


    // Allocate the device input vector C
    int32_t *d_C = NULL;
    err = cudaMalloc((void **)&d_C, size);
    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to allocate device vector C (error code %s)!\n",
        //    cudaGetErrorString(err));
        return false;
    }

    // Copy the host input vectors A and B in host memory to the device input
    // vectors in
    // device memory
    err = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        //fprintf(stderr,
        //    "Failed to copy vector A from host to device (error code %s)!\n",
        //    cudaGetErrorString(err));
        return false;
    }

    err = cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        //fprintf(stderr,
        //    "Failed to copy vector B from host to device (error code %s)!\n",
        //    cudaGetErrorString(err));
        return false;
    }

    // Launch the Vector Add CUDA Kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (numElements + threadsPerBlock - 1) / threadsPerBlock;
    //printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid,
    //     threadsPerBlock);
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);
    err = cudaGetLastError();

    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n",
        //     cudaGetErrorString(err));
        return false;
    }

    // Copy the device result vector in device memory to the host result vector
    // in host memory.
    // printf("Copy output data from the CUDA device to the host memory\n");
    err = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        // fprintf(stderr,
        //     "Failed to copy vector C from device to host (error code %s)!\n",
        //     cudaGetErrorString(err));
        return false;
    }

    // Free device global memory
    err = cudaFree(d_A);
    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to free device vector A (error code %s)!\n",
        //     cudaGetErrorString(err));
        return false;
    }
    err = cudaFree(d_B);
    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to free device vector B (error code %s)!\n",
        //     cudaGetErrorString(err));
        return false;
    }
    err = cudaFree(d_C);
    if (err != cudaSuccess) {
        // fprintf(stderr, "Failed to free device vector C (error code %s)!\n",
        //     cudaGetErrorString(err));
        return false;
    }

    return true;
}
#ifdef __cplusplus
}
#endif