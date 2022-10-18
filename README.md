# CudaProgramming

## Arrays
Gx & Gy arrays are used to store Soble masks.
arr is used to store the initial data.
gx_arr & gy_arr are used to store the results of the convolution.
final_arr stores the results of the serial part and h_parallel stores the results of the parallel part.
## Results
32 threads in a grid:

![an](https://github.com/erfaniravani/CudaProgramming/blob/e74cbf424feca6d5b967df812e7ff4893306e8e6/Screen%20Shot%202022-10-18%20at%201.41.41%20PM.png)

128 threads in a grid:

![moz](https://github.com/erfaniravani/CudaProgramming/blob/4bd14c0071214b61c56b6f60659c3aa19d6c11c5/Screen%20Shot%202022-10-18%20at%201.47.20%20PM.png)

1024 threads in a grid:

![hoz](https://drive.google.com/file/d/1kW-A6YlGeppRR5dTCjTyOoCAZ4X8DPyx/view?usp=sharing)
