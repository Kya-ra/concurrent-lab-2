# CSU33014 Lab 2 Report

Áine Hyndman \- 23373899  
Matthew Poole \- 23373470  
Kyara McWilliam \- 23375183

## Introduction

When attempting to train large neural networks, efficiency becomes a massive problem that developers must work to solve. An inefficient model results in more resources needed to improve the model, large energy consumption and ultimately becomes a massive time sink.

This poses the problem of how we, as developers, can make neural networks faster and more efficient. One such method of making a model more efficient is parallelisation. Utilising multiple threads in order to make the most efficient use of resources. We will aim to parallelise the given model using OpenMP (OMP) and pthreads, discuss the results, and analyse why this is an effective optimisation technique.

## Strategies

### Parallelisation

#### PThreads

For our PThreads approach, we implemented the convolution routine for the pthreads. The code splits the total number of kernels across NTHREADS. For each thread, it stores the pointers to the image, kernels and output arrays. It also assigns a range of kernels for the thread to process. The subroutine creates the thread using pthread\_create and waits for them to finish using pthread\_join. Each thread loops over the kernels assigned to it. 

For each kernel, it loops over every pixel in the image by width (w) and height (h). It computes the dot product of the kernel with the corresponding image patch. It stores the result in the output array for that kernel and pixel. The output then stores the convolution of the m-th kernel at pixel (w, h).

#### OpenMP

For our OpenMP approach, we used the \#pragma omp parallel for directive to distribute loop iterations across the available thread pool. The OpenMP scheduler does this using a fork-join approach, where the master thread forks a team of worker threads to complete the task for the duration of the parallel process. Splitting the iterations of the for loop among the currently available threads

We maintained data integrity by using the private(h,w,x,y,c) clause, which prevents these variables from being shared by multiple threads simultaneously and ensures that each thread maintains its own stack space for these variables. Not doing this can lead to incorrect convolution results and unpredictable behaviour. 

#### Drawbacks

OpenMP keeps a thread pool constantly active in the background of any program that uses it; as a result, smaller tasks can end up taking more time to execute when OpenMP is utilised, as the overhead required to manage the thread pool can be more time-intensive than the code being run. (This can be seen in test case 1 in Figure 1\)

Pthreads avoids this, but is far more tedious to write and debug when compared to OpenMP. It also introduces the risk of deadlock since everything is done manually by the programmer, and in large-scale programs such as neural networks, it can be difficult to spot every potential issue

### Additional optimisation

In our OpenMP approach, we also added the collapse(3) clause to transform the nested loops for width, height and channels into a single large iteration space M, which gives the OpenMP scheduler a significant increase in the number of iterations it can distribute among threads, preventing thread starvation from occurring. This also results in better efficiency as it allows the compiler more opportunity to utilise vectorisation, as there are more instances where SIMD instructions can be used.

In our Pthread approach, we reduced thread management by creating threads per function call and reusing them. We also divided the work across kernels. We also accessed the kernels sequentially by looping over x and y

## Execution Times

By utilising parallelisation, we saw notable performance improvements in the majority of test cases, with OpenMP producing better results across all test cases except test 1\. Where the overhead of launching and managing threads was more expensive than the computation itself, Pthreads consistently produced better results in all cases. In our tests, we found improvements ranging from 4.76x to 31.25x when utilising OpenMP and from 2.53x to 8.4x when utilising pthreads.

\[ Figure 1 \] Sample test case results

This indicates that in very small data sets and minimal threads, pthreads would be the preferred method; in the majority of other cases, it is much better to use OpenMP, as it shows to be up to 4x faster than pthreads in test cases with larger datasets. 

## Conclusion

Based on the evidence shown above, there is clear evidence to show that utilising pthreads and OpenMP for parallelisation provides a large improvement in making the model we were given faster and more efficient. Providing up to a 31.25x improvement on non-parallelised methods in our test cases. 

As neural networks and machine learning progress and employ even more complex techniques, we will have to make improvements to the efficiency of our programs, or we will run out of the hardware needed to do so. This is where parallelisation and other methods of optimisation will prove even more effective as time progresses

## Citations

[https://www.geeksforgeeks.org/c/c-parallel-for-loop-in-openmp/](https://www.geeksforgeeks.org/c/c-parallel-for-loop-in-openmp/)  
[https://learn.microsoft.com/en-us/cpp/parallel/openmp/reference/openmp-clauses?view=msvc-170](https://learn.microsoft.com/en-us/cpp/parallel/openmp/reference/openmp-clauses?view=msvc-170)  
[https://learn.microsoft.com/en-us/cpp/parallel/openmp/reference/openmp-clauses\#collapse](https://learn.microsoft.com/en-us/cpp/parallel/openmp/reference/openmp-clauses#collapse)  
[https://www.openmp.org/wp-content/uploads/openmp-examples-4.5.0.pdf](https://www.openmp.org/wp-content/uploads/openmp-examples-4.5.0.pdf)  
[https://www.geeksforgeeks.org/c/multithreading-in-c/](https://www.geeksforgeeks.org/c/multithreading-in-c/)  
[https://www.geeksforgeeks.org/c/thread-functions-in-c-c/](https://www.geeksforgeeks.org/c/thread-functions-in-c-c/)  
[https://pubs.opengroup.org/onlinepubs/7908799/xsh/pthread.h.html](https://pubs.opengroup.org/onlinepubs/7908799/xsh/pthread.h.html)

Outputs for graphed data

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 16 16 1 32 32  
Student pthreads conv time: 1715 microseconds  
Student openmp conv time: 9523 microseconds  
Control conv time: 5351 microseconds

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 16 16 1 2048 2048  
Student pthreads conv time: 1371319 microseconds  
Student openmp conv time: 296409 microseconds  
Control conv time: 6658430 microseconds

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 16 16 7 32 32  
Student pthreads conv time: 20018 microseconds  
Student openmp conv time: 10675 microseconds  
Control conv time: 50694 microseconds

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 16 16 7 2048 2048  
Student pthreads conv time: 21200320 microseconds  
Student openmp conv time: 6334710 microseconds  
Control conv time: 176721952 microseconds

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 512 512 1 32 32  
Student pthreads conv time: 499942 microseconds  
Student openmp conv time: 108829 microseconds  
Control conv time: 2353443 microseconds

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 512 512 7 32 32  
Student pthreads conv time: 7622018 microseconds  
Student openmp conv time: 1488627 microseconds  
Control conv time: 23717192 microseconds

kyaramcw@stoker:\~/Documents/Concurrent/lab2$ ./a.out 256 256 3 256 256  
Student pthreads conv time: 13162878 microseconds  
Student openmp conv time: 3139204 microseconds  
Control conv time: 96123042 microseconds