

# 
	library(devtools)
	load_all(".")

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

	writeSparseData (x,y, filename = "./tmp/testOutput.sparse")
	e = readSparseData (filename = "./tmp/testOutput.sparse", normalizeLabels = FALSE, verbose = TRUE)
	print (head(e))