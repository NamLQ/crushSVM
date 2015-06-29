## CrushSVM

CrushSVM is a simple library for several (binary) Support Vector Machine variants like
DC-SVM, Support Cluster Machines etc. 


### Features

The following SVMs are (more or less complete) implemented in CrushSVM:

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

The data has  to be binary, with 0-1 labels. There is no check for that currently.
Obviously the whole thing might have many bugs, for now it seems to work with my setup.


## Compiling 

As a CRAN package, it will compile CrushSVM by itself. But there are two
system dependencies, the user must install themselves.


### Boost

As Shark build upon Boost, you will also need a recent Boost version.
Unluckily, later versions of Boost have certain misbehaviour (or bugs)
with respect to serializiation. To our knowledge, Boost 1.55 should work
fine and any version after 1.58.  Your distribution should have corresponding
packages, if not, refer to the Boost homepage for a detailed tutorial on how
to compile and install Boost.


### Shark

To compile Shark, download the latest source code from the Shark homepage.
Different from the usual compilation, CrushSVM will need Shark 
Shark to be compiled with the -fPIC flag! For this, add

> set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

to the top of the CMakeLists.txt file. Only then compile Shark. 
Install it locally so that CrushSVM (RCpp respectively) can find it.




### Authors

Aydin Demircioglu


### Credits

-CrushSVM was forked from the very old rShark project https://github.com/eddelbuettel/rshark. The whole package structure has been developed by Shane Conway and Dirk Eddelbuettel. 


### License

GPL 3.0 for the R package, Shark 3.0 itself is license under the LGPL

