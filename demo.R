#!/usr/bin/Rscript

# 
	library(devtools)
	load_all(".")

	# make sure things work from Rscript also
	library(methods)

	
# convert iris to matrix
	x = as.matrix(iris[,1:4])
	y = as.vector(as.numeric(iris[,5]))
	# make sure its binary
	y = replace(y, y == 2, 0)
	y = replace(y, y == 3, 0)

# budgeted SVM
	s = bsgd (x, y, gamma = 1, epochs = 3, budget = 500)

	
