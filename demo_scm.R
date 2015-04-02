

# 
	library(devtools)
	load_all(".")

	library(microbenchmark)
	library(e1071)
	library(BBmisc)
	library(mlr)
	
	# make sure things work from Rscript also
	library(methods)

# set Kpos, Kminus
	Kpos = 5
	Kneg = 10
	
# convert iris to matrix
	x = as.matrix(iris[,1:4])
	y = as.vector(as.numeric(iris[,5]))
	# make sure its binary
	y = replace(y, y == 2, 0)
	y = replace(y, y == 3, 0)

	posEx = as.data.frame(subset(x, y == 1))
	negEx = as.data.frame(subset(x, y == 0))
	

# cluster pos ex
	cluster.task = makeClusterTask(data = posEx)
	cluster.lrn = makeLearner("cluster.SimpleKMeans", N = Kpos)
	clusterModelPos = train(cluster.lrn, task = cluster.task)
	clusteringPos = predict(clusterModelPos, newdata=posEx)

# cluster neg ex
	cluster.task = makeClusterTask(data = negEx)
	cluster.lrn = makeLearner("cluster.SimpleKMeans", N = Kneg)
	clusterModelNeg = train(cluster.lrn, task = cluster.task)
	clusteringNeg = predict(clusterModelNeg, newdata=negEx)
	
# now for each do X
	#clusteringNeg$data
	
	# em clustering in mlr
#	cluster.task = makeClusterTask(data = negEx)
	#cluster.lrn = makeLearner("cluster.EM", N = Kneg)
	
	weights = 
	sharksvm (x, y, weights = weights, type = "CSVM", verbose = TRUE, C = 1, gamma = 1)
	