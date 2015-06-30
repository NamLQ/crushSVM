
additive.dist.fun = function () {
	# given a distance matrix? three of them?
	K (x, y) = 0.5 * ( d(x,0) + d(0, y) - d(x,y) )
}


multiplikative.dist.fun = function (gamma = 1.0) {
	# given a distance matrix? three of them?
	K (x, y) = exp (-gamma * d(x,y))
}


# how to specify 'crude' distance
# how to specify 'accurate' distance?
# is this needed for our non-image case?


#' @param	dist.fun 		this is a function to convert dissimilarities to similarities 

svmknn.train = function (kerneldist.fun = NULL, svm.parameter = NULL, ... ) {
	# save training examples
	
	# add distance function to object
	trainObj["dist.fun"] = dist.fun
	
	# create object for the predictor
	trainObj = makeS3Obj (trainObj)
	
	return (trainObj)
}


svmknn.predict = function (x) {
	# compute distances to all training examples
	
	# pick k best
	
	# check if labels are same or not
	{
		# if so, we can exit
	}
	
	# convert distances to kernel
	K = dist.fun ()
	
	# apply svm with specified kernel
	trainSVM (..., kernel = K) 
	
	# obtain classifier
	
	# classify test points
	
	return ()
}

