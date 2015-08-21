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
	library(checkmate)

	
		library(devtools)
	load_all ("../SVMBridge")

	solver = "LIBSVM"
	addSVMPackage (method = solver, verbose = FALSE)
	findSVMSoftware (solver, searchPath = "../svm_large_scale/software/", verbose = TRUE)


	D = SVMBridge::readSparseData  (filename = "../lab/data/mnist/mnist.train")
	T =  SVMBridge::readSparseData (filename = "../lab/data/mnist/mnist.test")

# # convert iris to matrix
# 	x = as.matrix(iris[,1:4])
# 	y = as.vector(as.numeric(iris[,5]))
# 	# make sure its binary
# 	y = replace(y, y == 2, -1)
# 	y = replace(y, y == 3, -1)
# 

# cascade SVM, will yield a libsvm model 
	s = cascadesvm (X = D$X, Y = D$Y, k = 16, epochs = 4, gamma = 1, verbose = TRUE)
#	print(s)
		testObj =  testSVM(
				method = "LIBSVM",
				testDataX = T$X, 
				testDatay = T$Y, 
				model = s$model$model,
				predictionsFile = "./tmp/predictions.txt",
				verbose = FALSE,
		)  

#	print (testObj)
	
	stop ("finished demo.")

# budgeted SVM
	s = bsgd (x, y, gamma = 1, epochs = 3, budget = 500)

	
