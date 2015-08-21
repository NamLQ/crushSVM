CXX ?= g++
CC ?= gcc
CFLAGS = -Wall -Wconversion -O3 -fPIC
LIBS = blas/blas.a
SHVER = 1
OS = $(shell uname)
#LIBS = -lblas


R_INC = /usr/share/R/include
RCPP_INC = $(R_HOME)/library/Rcpp/include


all: llsvm  

llsvm: llsvm-train.o svm.o 
	$(CXX) $(CFLAGS) -o llsvm llsvm.cpp llsvm-train.o llsvm-predict.o svm.o $(LIBS)

llsvm-predict.o: llsvm-predict.c
	$(CXX) $(CFLAGS) -c -I$(R_INC) -I$(RCPP_INC) -o llsvm-predict.o llsvm-predict.c

llsvm-train.o: llsvm-train.c
	$(CXX) $(CFLAGS) -c -I$(R_INC) -I$(RCPP_INC) -o llsvm-train.o llsvm-train.c 

svm.o: svm.cpp svm.h
	$(CXX) $(CFLAGS) -c -o svm.o svm.cpp

clean:
	rm -f *~ llsvm-train.o llsvm-predict.o 
