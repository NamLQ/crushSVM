
cpsp = function (X, Y, C, eps, budget, kernel) {

	# sanity check
	
	# initialize
	deltaBar = 0
	psiBar = 0
	psiHat = 0
	H = 0
	B = 0
	m = 0
	

	while (TRUE == TRUE) {
		H = matrix ()
		
		alpha = argmax()
		
		xi = 1/C * (alpha * deltaBar )

		removeInactive (psiBar, deltaBar, alpha)
		
		m = m + 1
		psiBar = 1/(2*n) (w)
		deltaBar = 1/(2*n) ()
		
		# do we want to extend the basis
		if (length(B) < budget) {
			extendBasis (B, psiBar_m)
		}

		# project down
		for (i in seq(1,k)) {
			psiHat = project (psiBar, B)
		}
		
		# check for stopping condition
		if ( K(w, PsiBar_m) >= DeltaBar_m - xi - eps ) 
			break
	}
	
	# create return object
# 	svmPackage = BBmisc::makeS3Obj(c("cpsp", "CPSP"),
# 							method = method,
# 							trainingBinary = trainingBinary
# 					)
	return (l)
}


