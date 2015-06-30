#' cascade SVM
#'
#' we do not restrict the number of subsets. in case at any point there is an uneven
#' number of splits we combine all of them normally (two by two), except for the last 
#' three subsets. these we combine directly.
#' 
#'	@param 	X		training input
#' @param	Y		labels
#' @param	k		number of subsets. 
#'
#' @return			svm models, containing: -final model (libsvm model), -?
#' @export
cascadesvm = function (X, Y, k, nloops = 1, verbose = FALSE, ...) {
	# sanity check
	
	# check for k
	depth = as.integer(log2(k))
	
	# reset old data
	oldData = c()
	
	# start cascade
	for (l in 1:nloops) {
		
		if (verbose == TRUE) cat ("LOOP ", l, "\n\n")
		
		# hard split of data into k subsets
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
				models[[m]] = dummy (X = X[currentSplits[[m]],], 
					Y = Y[currentSplits[[m]],],
					C = cost,
					gamma = gamma,
					...
				)
			}

			# join the found support vectors
			newSplits = list()
			for (m in seq(1, floor(length(currentSplits)/2))) {
				# getSVs will give the indices of the support vectors relative to our subset, 
				# so need to convert it back 
				indA = getSVs(models[[2*m - 1]], currentSplits[[2*m - 1]])
				indB = getSVs(models[[2*m ]], currentSplits[[2*m]])
				newSplits[[m]] = unique ( c( indA, indB) )
			}
			
			# join last three splits if uneven
			if ((length(currentSplits) %% 2) == 1) {
				indA = getSVs( models[[length(currentSplits)]], currentSplits[[length(currentSplits)]])
				newSplits[[length(newSplits)]] = unique ( c( newSplits[[length(newSplits)]], indA ))
			}

			print ("new splits")
			print (newSplits)
			# update splits for next level
			currentSplits = newSplits
		}
		
		# finally we only have one split over
		oldData = getSVs(models[[1]], currentSplits[[1]])
	}
	
	# create results
	result = BBmisc::makeS3Obj (	"crushSVM.cascadesvm",
		k = k
	)

	return (result)
}


			# TODO: warm restart
			
getSVs = function (model, set) {
	indA = set[unlist(model)]
	return (indA)
}

dummy = function (X, Y, ...) {
	n = nrow(X)
	if (is.null(n)) stop ("ops. no data.")
	l = floor(n/2)
	if (l < 0)
		l = n
	r = seq(1,l)
	return (r)
}
