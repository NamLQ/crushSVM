

# 
	library(devtools)
	load_all(".")

	library(microbenchmark)
	library(e1071)
	library(BBmisc)

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

	
	
	
# 08/15 svm
#	s = ssvm (x, y, gamma = 0.585568587668891, epsilon = 1e-6)

# 	writeSparseData (x,y, filename = "./tmp/testOutput.sparse")
# 	e = readSparseData (filename = "./tmp/testOutput.sparse", normalizeLabels = FALSE, verbose = TRUE)
# 	
# 	messagef("Testing Reading, e1071 vs swarmsvm, 5 times")
# 	t = microbenchmark( read.matrix.csr("../lab/data/poker/poker.combined.scaled"), times = 5)
# 	messagef("e1071:")	
# 	print (t)
# 	t = microbenchmark( readSparseData (filename = "../lab/data/poker/poker.combined.scaled"), times = 5)
# 	messagef("swarmsvm:")	
# 	print(t)
# 
# 	messagef("Testing Writing, e1071 vs swarmsv, 3 times")
# 	t = microbenchmark( write.matrix.csr(x, "tmp/poker.combined.scaled", y), times = 30)
# 	messagef("e1071:")	
# 	print (t)
# 	t = microbenchmark( writeSparseData (x, y, filename = "tmp/poker.combined.scaled"), times = 30)
# 	messagef("swarmsvm:")	
# 	print(t)
