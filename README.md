## crushSVM

crushSVM is a simple library for several (binary) Support Vector Machine variants like
DC-SVM, Support Cluster Machines etc. 


### Features

The following SVMs are (more or less complete) implemented in crushSVM:

- Instance weighted C-SVM
- Budgeted SGD
- Support Cluster Machine
- Hierarchical Support Cluster Machine
- Divide-and-Conquer SVM
- Clustered SVM



### Status

It is in pre-alpha status and will stay there for quite a while.


### Usage

The package can be loaded by 

> library(devtools)
load_all(".")
cpsp((x, y, gamma = 0.5, C = 1.0, epsilon = 1e-7)



## Compiling 

As a CRAN package, crushSVM will compile by itself. 



### Authors

Aydin Demircioglu


### Credits

crushSVM builds on a lot of R technology. Thanks to you all.


### License

GPL 3.0 for the R package, different submodules might have weaker licenses.

