#' cascade SVM
#'
#' we do not restrict the number of subsets. in case at any point there is an uneven
#' number of splits we combine all of them normally (two by two), except for the last 
#' three subsets. these we combine directly.
#' 
#' FIXME: -stratified sampling, 
#' 
#'
#'	@param 	X		training input
#' @param	Y		labels
#' @param	k		number of initial subsets. 
#' @param	epochs 	number of epochs to run
#'
#' @return			svm models, containing: -final model (libsvm model), -?
#' @export
cascadesvm = function (X, Y, k, epochs  = 1, train.param = NULL, verbose = FALSE, ...) {
	# sanity check
	checkmate::assertInt(k, na.ok = FALSE, lower = 2, upper = floor(nrow(X)/2))
	checkmate::assertInt(epochs, na.ok = FALSE, lower = 1)
	
	# check for k
	depth = as.integer(log2(k))
	
	# reset old data
	oldData = c()
	
	# start cascade
	for (l in 1:epochs) {
		
		if (verbose == TRUE) cat ("LOOP ", l, "\n\n")
		
		# hard split of data into k subsets,
		# we need stratified sampling here, if we do not do it that way
		# we directly run into troubles. so we implicitely assume the
		# number of elements in the smaller class is larger than k.
		currentSplits = list()
		perm = sample (nrow(X))
		batchSize = floor(nrow(X)/k)
		for (c in 1:k) {
			lowerindex = (c-1)*batchSize + 1
			upperindex = c*batchSize 
			if (c == k) 
				upperindex = nrow(X)
#			cat (lowerindex, upperindex,"\n")
			currentSplits[[c]] = perm[lowerindex:upperindex]
		}

		# recheck for stratified splitting. 
		for (s in 1:length(currentSplits)) {
			if (length(unique(Y[currentSplits[[s]]])) == 1) {
				stop ("Cluster with one label occured. But we applied stratified sampling! Something is wrong. Check data or code.")
			}
		}
		
		# add old data to each split
		for (s in 1:length(currentSplits)) {
			currentSplits[[s]] = unique( c( currentSplits[[s]], oldData))
		}
		if (verbose == TRUE) {print ("adding old data"); print (currentSplits)}

		# now process the cascade
		for (d in 1:depth) {
			if (verbose == TRUE) cat("training depth", d, "\n")
			if (verbose == TRUE) print (currentSplits)
			
			# train svm on subsets
			models = list()
			for (m in 1:length(currentSplits)) {
				# need to test, if cluster only contains one single label.
				# in this case, we DO X.
				if (length(unique(Y[currentSplits[[m]]])) == 1) {
					stop ("Cluster with one label occured. This can never happen, if the inital clustering did not had any. Please re-check that.")
				} else {
					models[[m]] = cascadetrainSVM (X = X[currentSplits[[m]],], 
						Y = Y[currentSplits[[m]]],
						C = cost,
						gamma = gamma,
						...
					)
				}
			}

			# join the found support vectors
			if (verbose == TRUE) cat ("Joining Support Vectors.\n")
			newSplits = list()
			for (m in seq(1, floor(length(currentSplits)/2))) {
				# localgetSVs will give the indices of the support vectors relative to our subset, 
				# so need to convert it back 
				indA = localgetSVs(models[[2*m - 1]], X, currentSplits[[2*m - 1]])
				indB = localgetSVs(models[[2*m ]], X, currentSplits[[2*m]])
				newSplits[[m]] = unique ( c( indA, indB) )
			}
			
			# join last three splits if uneven
			if ((length(currentSplits) %% 2) == 1) {
				indA = localgetSVs( models[[length(currentSplits)]], X, currentSplits[[length(currentSplits)]])
				newSplits[[length(newSplits)]] = unique ( c( newSplits[[length(newSplits)]], indA ))
			}

			if (verbose == TRUE) print ("new splits")
			if (verbose == TRUE) print (newSplits)
			# update splits for next level
			currentSplits = newSplits
		}
		
		# finally we only have one split over
		oldData = localgetSVs(models[[1]], X, currentSplits[[1]])
	}
	
	# create results
	result = BBmisc::makeS3Obj (	"crushSVM.cascadesvm",
		model = models[[1]],
		k = k
	)

	return (result)
}


			# TODO: warm restart
			
dummygetSVs = function (model, set) {
	indA = set[unlist(model)]
	return (indA)
}

dummytrainSVM = function (X, Y, ...) {
	n = nrow(X)
	if (is.null(n)) stop ("ops. no data.")
	l = floor(n/2)
	if (l < 0)
		l = n
	r = seq(1,l)
	return (r)
}



cascadetrainSVM = function (X, Y, verbose = FALSE,  ...) {

	# need to check if svm is initialized already?
	# use e1071
	
	if (verbose == TRUE) messagef("\n======= Training now")
	trainObj =  SVMBridge::trainSVM(
			method = solver,
			trainDataX = X, 
			trainDatay = Y, 
			cost = 1, 
			gamma = 1, 
			epsilon = 0.01, 
			readModelFile = TRUE,
			verbose = verbose
	)  

	return (trainObj)
}



cascadetrainSVMORg = function (X, Y, verbose = FALSE,  ...) {

	# need to check if svm is initialized already?
	
	if (verbose == TRUE) messagef("\n======= Training now")
	trainObj =  SVMBridge::trainSVM(
			method = solver,
			trainDataX = X, 
			trainDatay = Y, 
			cost = 1, 
			gamma = 1, 
			epsilon = 0.01, 
			readModelFile = TRUE,
			verbose = verbose
	)  

	return (trainObj)
}


localgetSVs = function (model, data, set) {
	# we need a reverse search :/
	# TODO: replace witih a apply cascade. MAKE FASTER.
	indexSet = c()
	for (r in 1:nrow(model$model$X)) {
		cr = which(apply(data[set,], 1, function(x,y) { all(as.numeric(x)==as.numeric(y))}, model$model$X[r,]))
		if (is.null(cr) == TRUE) {
			stop ("Severe programming error. Could not find the given support vector in the original data set. Received NULL")
		} 
		if (length(cr) > 1) {
			# not unique, we take the first
			cr = cr[1] 
		} 
		if (length(cr) == 0) {
			stop ("Severe programming error. Could not find the given support vector in the original data set.")
		}
		indexSet = c (indexSet, set[cr])
	}
	return (indexSet)
}



rowsUnique = function (data) {
	# we need a reverse search :/
	# TODO: replace witih a apply cascade. MAKE FASTER.
	for (r in 1:nrow(data)) {
		cr = which(apply(data, 1, function(x,y) { all(as.numeric(x)==as.numeric(y))}, data[r,]))
		if (is.null(cr) == TRUE) {
			stop ("Severe programming error. Could not find the given support vector in the original data set. Received NULL")
		} 
		if (length(cr) > 1) {
			# not unique, we take the first
			cr = cr[1] 
		} 
		if (length(cr) == 0) {
			stop ("Severe programming error. Could not find the given support vector in the original data set.")
		}
	}
	return (0)
}


