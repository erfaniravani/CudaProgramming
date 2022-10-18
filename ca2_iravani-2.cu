#include <iostream>
#include <time.h>
#include <stdlib.h>
#include <iostream>
#include <time.h>
#include <stdlib.h>
#include <bits/stdc++.h>
#define THREAD_NUMBER 128
#define SIZE 227

using namespace std;
__global__ void parallel_func(int *arr, int *GX, int *GY, int* d_final_arr){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int gx_arr[SIZE*SIZE];
    int gy_arr[SIZE*SIZE];
    if(i < SIZE*SIZE){
      if((i % SIZE == 0) | (i % SIZE == SIZE - 1) | (i < SIZE) | (i > SIZE*(SIZE-1))){
          d_final_arr[i] = 0;
          gy_arr[i] = 0;
          gx_arr[i] = 0;
      }
      else{
          gx_arr[i] = arr[i]*GX[4] + arr[i+1]*GX[5] + arr[i-1]*GX[3] +
                      arr[i - SIZE]*GX[1] + arr[i - SIZE - 1]*GX[0] + arr[i - SIZE + 1]*GX[2] +
                      arr[i + SIZE]*GX[7] + arr[i + SIZE - 1]*GX[6] + arr[i + SIZE + 1]*GX[8];
          gy_arr[i] = arr[i]*GY[4] + arr[i+1]*GY[5] + arr[i-1]*GY[3] +
                      arr[i - SIZE]*GY[1] + arr[i - SIZE - 1]*GY[0] + arr[i - SIZE + 1]*GY[2] +
                      arr[i + SIZE]*GY[7] + arr[i + SIZE - 1]*GY[6] + arr[i + SIZE + 1]*GY[8];
          
      }
      d_final_arr[i] = gy_arr[i] + gx_arr[i];
    }
    return;
}

__global__ void enhanced_parallel_func(int *arr, int *GX, int *GY, int* d_final_arr){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < SIZE*SIZE){
      if((i % SIZE == 0) | (i % SIZE == SIZE - 1) | (i < SIZE) | (i > SIZE*(SIZE-1))){
          d_final_arr[i] = 0;
      }
      else{
          d_final_arr[i] = arr[i]*(GX[4]+GY[4]) + arr[i+1]*(GX[5]+GY[5]) + arr[i-1]*(GX[3]+GY[3]) +
                  arr[i - SIZE]*(GX[1]+GY[1]) + arr[i - SIZE - 1]*(GX[0]+GY[0]) + arr[i - SIZE + 1]*(GX[2]+GY[2]) +
                  arr[i + SIZE]*(GX[7]+GY[7]) + arr[i + SIZE - 1]*(GX[6]+GY[6]) + arr[i + SIZE + 1]*(GX[8]+GY[8]);
                      
          
      }
    }
    return;
}


void init(int* arr, int* gx_arr, int* gy_arr, int* final_arr, int* GX, int* GY){
    GX[0] = -1; GX[1] = 0; GX[2] = -1;
    GX[3] = -2; GX[4] = 0; GX[5] = 2;
    GX[6] = -1; GX[7] = 0; GX[8] = -1; 
    GY[0] = -1; GY[1] = -2; GY[2] = -1;
    GY[3] = 0;  GY[4] = 0;  GY[5] = 0;
    GY[6] = 1;  GY[7] = 2;  GY[8] = 1; 
    srand(time(NULL));
    for(int i = 0; i < (SIZE*SIZE); i++){
        int num = rand()%(5-0 + 1) + 0;
        arr[i] = num;
        gx_arr[i] = 0;
        gy_arr[i] = 0;
        final_arr[i] = 0;
    }
}

void serial(int* arr, int* gx_arr, int* gy_arr, int* final_arr, int* GX, int* GY){
    for(int i = SIZE; i < SIZE*(SIZE-1); i++){
        if((i % SIZE == 0) | (i % SIZE == SIZE - 1)){
            continue;
        }
        else{
            gx_arr[i] = arr[i]*GX[4] + arr[i+1]*GX[5] + arr[i-1]*GX[3] +
                        arr[i - SIZE]*GX[1] + arr[i - SIZE - 1]*GX[0] + arr[i - SIZE + 1]*GX[2] +
                        arr[i + SIZE]*GX[7] + arr[i + SIZE - 1]*GX[6] + arr[i + SIZE + 1]*GX[8];
            gy_arr[i] = arr[i]*GY[4] + arr[i+1]*GY[5] + arr[i-1]*GY[3] +
                        arr[i - SIZE]*GY[1] + arr[i - SIZE - 1]*GY[0] + arr[i - SIZE + 1]*GY[2] +
                        arr[i + SIZE]*GY[7] + arr[i + SIZE - 1]*GY[6] + arr[i + SIZE + 1]*GY[8];
        }
        final_arr[i] = gy_arr[i] + gx_arr[i];
    }
}

int main(){
    
    int* GX = (int*) malloc(sizeof(int) * 9);
    int* GY = (int*) malloc(sizeof(int) * 9);
    int* arr = (int*) malloc(sizeof(int) * SIZE * SIZE);
    int* gx_arr = (int*) malloc(sizeof(int) * SIZE * SIZE);
    int* gy_arr = (int*) malloc(sizeof(int) * SIZE * SIZE);
    int* final_arr = (int*) malloc(sizeof(int) * SIZE * SIZE);
    int* h_parallel = (int*) malloc(sizeof(int) * SIZE * SIZE);

    clock_t serial_start, serial_end;
    clock_t parallel_start, parallel_end;

    init(arr, gx_arr, gy_arr, final_arr, GX, GY);

    serial_start = clock();
    serial(arr, gx_arr, gy_arr, final_arr, GX, GY);
    serial_end = clock();
    cout << "serial runtime = " << serial_end - serial_start << endl;
    
    
    //cuda
    dim3 block(THREAD_NUMBER);
    dim3 grid((SIZE*SIZE + block.x - 1) / block.x);
    cout << "grid = " << grid.x << "  block = " << block.x << endl;
    int* d_arr; 
    int* d_gx; 
    int* d_gy; 
    int* d_final_arr; 

    cudaMalloc((int**)&d_arr, sizeof(int) * SIZE * SIZE);
    cudaMalloc((int**)&d_gx, sizeof(int) * 9);
    cudaMalloc((int**)&d_gy, sizeof(int) * 9);
    cudaMalloc((int**)&d_final_arr, sizeof(int) * SIZE * SIZE);

    parallel_start = clock();

    cudaMemcpy(d_arr, arr, sizeof(int)*SIZE*SIZE, cudaMemcpyHostToDevice);
    cudaMemcpy(d_gx, GX, sizeof(int)*9, cudaMemcpyHostToDevice);
    cudaMemcpy(d_gy, GY, sizeof(int)*9, cudaMemcpyHostToDevice);

    enhanced_parallel_func <<<grid,block>>> (d_arr, d_gx, d_gy, d_final_arr);
    cudaMemcpy(h_parallel, d_final_arr, sizeof(int)*SIZE*SIZE, cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();
    parallel_end = clock();

    int gg = 1;
    for(int i = 0; i < SIZE*SIZE ; i++){
        if(h_parallel[i] != final_arr[i]){
            gg = 0;
        }
    }
    cout << endl;
    cout << "parallel and serial --> " << gg << endl;
    cout << "parallel runtime = " << parallel_end-parallel_start << endl;

    free(GX);
    free(GY);
    free(arr);
    free(gx_arr);
    free(gy_arr);
    free(final_arr);
    cudaFree(d_arr);
    cudaFree(d_gx);
    cudaFree(d_gy);
    cudaFree(d_final_arr);
    cudaFree(h_parallel);
    return 0;
}