#!/usr/bin/Rscript

# 
	library(devtools)
	load_all(".")

	build_vignettes(".")
	document(".")
    
    library(Rcpp)
	compileAttributes()

        # run tests
        #devtools::test()
#       devtools::check()

	
	# make sure things work from Rscript also
	library(methods)

	
		library(devtools)
	load_all ("../SVMBridge")

	solver = "LIBSVM"
	addSVMPackage (method = solver, verbose = FALSE)
	findSVMSoftware (solver, searchPath = "../svm_large_scale/software/", verbose = TRUE)


	
# convert iris to matrix
	x = as.matrix(iris[,1:4])
	y = as.vector(as.numeric(iris[,5]))
	# make sure its binary
	y = replace(y, y == 2, -1)
	y = replace(y, y == 3, -1)

# cascade SVM
	s = cascadesvm (X = x, Y = y, k = 8, nloops = 2, gamma = 1, epochs = 3, budget = 500, verbose = TRUE)
	
	stop ("finished demo.")

# budgeted SVM
	s = bsgd (x, y, gamma = 1, epochs = 3, budget = 500)

	
